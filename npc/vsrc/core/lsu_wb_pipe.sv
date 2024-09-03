`include "../inc/defines.svh"

module lsu_wb_pipe (
    input logic clk,
    input logic rst_n,

    // control signals
    input logic i_valid,
    output logic i_ready,
    output logic o_valid,
    input logic o_ready,

    // from lsu
    input logic [`DATA_BUS] lsu_alu_result,
    input logic [1:0] lsu_reg_wdata_sel,
    input logic [`DATA_BUS] lsu_csr_rdata,
    input logic [`DATA_BUS] lsu_dmem_rdata,
    input logic lsu_reg_wen,
    input logic [`REG_ADDR_BUS] lsu_reg_waddr,

    // to wb
    output logic [`DATA_BUS] wb_alu_result,
    output logic [1:0] wb_reg_wdata_sel,
    output logic [`DATA_BUS] wb_csr_rdata,
    output logic [`DATA_BUS] wb_dmem_rdata,
    output logic wb_reg_wen,
    output logic [`REG_ADDR_BUS] wb_reg_waddr
);

    // data path
    logic data_buffer_wren;
    logic [`DATA_BUS] buffer_alu_result;
    logic [1:0] buffer_reg_wdata_sel;
    logic [`DATA_BUS] buffer_csr_rdata;
    logic [`DATA_BUS] buffer_dmem_rdata;
    logic buffer_reg_wen;
    logic [`REG_ADDR_BUS] buffer_reg_waddr;
    // buffer reg
    always @ (posedge clk) begin
        if (!rst_n) begin
            buffer_alu_result <= `ZERO_WORD;
            buffer_reg_wdata_sel <= 2'b0;
            buffer_csr_rdata <= `ZERO_WORD;
            buffer_dmem_rdata <= `ZERO_WORD;
            buffer_reg_wen <= 1'b0;
            buffer_reg_waddr <= 5'b0;
        end
        else if (data_buffer_wren) begin
            buffer_alu_result <= lsu_alu_result;
            buffer_reg_wdata_sel <= lsu_reg_wdata_sel;
            buffer_csr_rdata <= lsu_csr_rdata;
            buffer_dmem_rdata <= lsu_dmem_rdata;
            buffer_reg_wen <= lsu_reg_wen;
            buffer_reg_waddr <= lsu_reg_waddr;
        end
    end 
    logic data_out_wren; // EMPTY at start, so accept data.
    logic use_buffered_data;
    logic [`DATA_BUS] selected_alu_result;
    logic [1:0] selected_reg_wdata_sel;
    logic [`DATA_BUS] selected_csr_rdata;
    logic [`DATA_BUS] selected_dmem_rdata;
    logic selected_reg_wen;
    logic [`REG_ADDR_BUS] selected_reg_waddr;
    // select data out
    assign selected_alu_result = use_buffered_data ? buffer_alu_result : lsu_alu_result;
    assign selected_reg_wdata_sel = use_buffered_data ? buffer_reg_wdata_sel : lsu_reg_wdata_sel;
    assign selected_csr_rdata = use_buffered_data ? buffer_csr_rdata : lsu_csr_rdata;
    assign selected_dmem_rdata = use_buffered_data ? buffer_dmem_rdata : lsu_dmem_rdata;
    assign selected_reg_wen = use_buffered_data ? buffer_reg_wen : lsu_reg_wen;
    assign selected_reg_waddr = use_buffered_data ? buffer_reg_waddr : lsu_reg_waddr;

    // pipeline reg
    always @ (posedge clk) begin
        if (!rst_n) begin
            wb_alu_result <= `ZERO_WORD;
            wb_reg_wdata_sel <= 2'b0;
            wb_csr_rdata <= `ZERO_WORD;
            wb_dmem_rdata <= `ZERO_WORD;
            wb_reg_wen <= 1'b0;
            wb_reg_waddr <= 5'b0;
        end
        else if (data_out_wren) begin
            wb_alu_result <= selected_alu_result;
            wb_reg_wdata_sel <= selected_reg_wdata_sel;
            wb_csr_rdata <= selected_csr_rdata;
            wb_dmem_rdata <= selected_dmem_rdata;
            wb_reg_wen <= selected_reg_wen;
            wb_reg_waddr <= selected_reg_waddr;
        end
    end


    // control path: state machine
    localparam STATE_BITS = 2;
    localparam [STATE_BITS-1:0] EMPTY = 'd0; // Output and buffer registers empty
    localparam [STATE_BITS-1:0] BUSY  = 'd1; // Output register holds data
    localparam [STATE_BITS-1:0] FULL  = 'd2; // Both output and buffer registers hold data
    // There is no case where only the buffer register would hold data.

    // No handling of erroneous and unreachable state 3.
    // We could check and raise an error flag.

    logic [STATE_BITS-1:0] state;
    logic [STATE_BITS-1:0] state_next = EMPTY;

    // ready reg
    always @ (posedge clk) begin
        if (!rst_n) begin
            i_ready <= 1'b1;
        end
        else begin
            i_ready <= (state_next != FULL);
        end
    end

    // valid reg
    always @ (posedge clk) begin
        if (!rst_n) begin
            o_valid <= 1'b0;
        end
        else begin
            o_valid <= (state_next != EMPTY);
        end
    end

    wire insert = (i_valid  == 1'b1) && (i_ready  == 1'b1);
    wire remove = (o_valid == 1'b1) && (o_ready == 1'b1);

    // reg load    = 1'b0; // Empty datapath inserts data into output register.
    // reg flow    = 1'b0; // New inserted data into output register as the old data is removed.
    // reg fill    = 1'b0; // New inserted data into buffer register. Data not removed from output register.
    // reg flush   = 1'b0; // Move data from buffer register into output register. Remove old data. No new data inserted.
    // reg unload  = 1'b0; // Remove data from output register, leaving the datapath empty.

    wire load    = (state == EMPTY) && (insert == 1'b1) && (remove == 1'b0);
    wire flow    = (state == BUSY)  && (insert == 1'b1) && (remove == 1'b1);
    wire fill    = (state == BUSY)  && (insert == 1'b1) && (remove == 1'b0);
    wire flush   = (state == FULL)  && (insert == 1'b0) && (remove == 1'b1);
    wire unload  = (state == BUSY)  && (insert == 1'b0) && (remove == 1'b1);

    always @ (*) begin
        state_next = (load   == 1'b1) ? BUSY  : state;
        state_next = (flow   == 1'b1) ? BUSY  : state_next;
        state_next = (fill   == 1'b1) ? FULL  : state_next;
        state_next = (flush  == 1'b1) ? BUSY  : state_next;
        state_next = (unload == 1'b1) ? EMPTY : state_next;
    end

    // state reg
    always @ (posedge clk) begin
        if (!rst_n) begin
            state <= EMPTY;
        end
        else begin
            state <= state_next;
        end
    end

    always @ (*) begin
        data_out_wren     = (load  == 1'b1) || (flow == 1'b1) || (flush == 1'b1);
        data_buffer_wren  = (fill  == 1'b1);
        use_buffered_data = (flush == 1'b1);
    end

endmodule
