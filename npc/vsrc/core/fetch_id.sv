`include "../inc/defines.svh"

// module fetch_id (
//     input logic clk,
//     input logic rst_n,

//     // from fetch
//     input logic [`INST_ADDR_BUS] if_pc,
//     input logic [`INST_DATA_BUS] if_inst,
//     input logic if_valid,

//     // from id
//     input logic id_ready,

//     // to id
//     output logic [`INST_ADDR_BUS] id_pc,
//     output logic [`INST_DATA_BUS] id_inst,
//     output logic if_id_valid
// );

//     // valid
//     always @ (posedge clk) begin
//         if (!rst_n) begin
//             if_id_valid <= 1'b0;
//         end
//         else if (id_ready) begin
//             if_id_valid <= if_valid;
//         end
//     end

//     // data
//     always @ (posedge clk) begin
//         if (!rst_n) begin
//             id_inst <= `INST_NOP;
//             id_pc   <= `CPU_RESET_ADDR;
//         end
//         else if (if_valid & id_ready) begin
//             id_inst <= if_inst;
//             id_pc   <= if_pc;
//         end
//         else begin
//             // 因为译码和执行写回间没有阻塞，因此握手失败就输出气泡
//             id_inst <= `INST_NOP;
//         end
//     end

// endmodule



module fetch_id (
    input logic clk,
    input logic rst_n,

    // control signals
    input logic i_valid,
    output logic i_ready,
    output logic o_valid,
    input logic o_ready,

    // from fetch
    input logic [`INST_ADDR_BUS] fetch_pc,
    input logic [`INST_DATA_BUS] fetch_inst,

    // to id
    output logic [`INST_ADDR_BUS] id_pc,
    output logic [`INST_DATA_BUS] id_inst

);

    // data path
    logic data_buffer_wren; // EMPTY at start, so don't load.
    logic [`INST_ADDR_BUS] buffer_pc;
    logic [`INST_DATA_BUS] buffer_inst;
    // buffer reg
    always @ (posedge clk) begin
        if (!rst_n) begin
            buffer_pc <= `CPU_RESET_ADDR;
            buffer_inst <= `INST_NOP;
        end
        else if (data_buffer_wren) begin
            buffer_pc <= fetch_pc;
            buffer_inst <= fetch_inst;
        end
    end 
    logic data_out_wren; // EMPTY at start, so accept data.
    logic use_buffered_data;
    logic [`INST_ADDR_BUS] selected_pc;
    logic [`INST_DATA_BUS] selected_inst;
    // select data out
    assign selected_pc = use_buffered_data ? buffer_pc : fetch_pc;
    assign selected_inst = use_buffered_data ? buffer_inst : fetch_inst;
    // pipeline reg
    always @ (posedge clk) begin
        if (!rst_n) begin
            id_pc <= `CPU_RESET_ADDR;
            id_inst <= `INST_NOP;
        end
        else if (data_out_wren) begin
            id_pc <= selected_pc;
            id_inst <= selected_inst;
        end
        else begin
            id_inst <= `INST_NOP; // 因为译码和执行写回间没有阻塞，因此握手失败就输出气泡
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
            o_valid <= 1'b1;
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
