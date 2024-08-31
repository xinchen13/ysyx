`include "../inc/defines.svh"

module pc_reg (
    input logic clk,
    input logic rst_n,

    // from ex
    input logic [`INST_ADDR_BUS] dnpc,
    input logic dnpc_valid,

    // from fetch
    input logic if_ready,

    // to fetch
    output logic pc_if_valid,
    output logic [`INST_ADDR_BUS] pc
);
    // valid
    always @ (posedge clk) begin
        if (!rst_n) begin
            pc_if_valid <= 1'b1;
        end
        else if (if_ready) begin
            pc_if_valid <= dnpc_valid;
        end
    end

    always @ (posedge clk) begin
        if (!rst_n) begin
            pc <= `CPU_RESET_ADDR;
        end
        else if (dnpc_valid & if_ready) begin
            pc <= dnpc;
        end
    end
endmodule

// module pc_reg (
//     input logic clk,
//     input logic rst_n,

//     // control signals
//     input logic i_valid,
//     output logic i_ready,
//     output logic o_valid,
//     input logic o_ready,

//     // from ex
//     input logic [`INST_ADDR_BUS] dnpc,

//     // to fetch
//     output logic [`INST_ADDR_BUS] fetch_pc

// );

//     // data path
//     logic data_buffer_wren; // EMPTY at start, so don't load.
//     logic [`INST_ADDR_BUS] buffer_pc;
//     // buffer reg
//     always @ (posedge clk) begin
//         if (!rst_n) begin
//             buffer_pc <= `CPU_RESET_ADDR;
//         end
//         else if (data_buffer_wren) begin
//             buffer_pc <= dnpc;
//         end
//     end 
//     logic data_out_wren; // EMPTY at start, so accept data.
//     logic use_buffered_data;
//     logic [`INST_ADDR_BUS] selected_pc;
//     // select data out
//     assign selected_pc = use_buffered_data ? buffer_pc : dnpc;
//     // pipeline reg
//     always @ (posedge clk) begin
//         if (!rst_n) begin
//             fetch_pc <= `CPU_RESET_ADDR;
//         end
//         else if (data_out_wren) begin
//             fetch_pc <= selected_pc;
//         end
//     end


//     // control path: state machine
//     localparam STATE_BITS = 2;
//     localparam [STATE_BITS-1:0] EMPTY = 'd0; // Output and buffer registers empty
//     localparam [STATE_BITS-1:0] BUSY  = 'd1; // Output register holds data
//     localparam [STATE_BITS-1:0] FULL  = 'd2; // Both output and buffer registers hold data
//     // There is no case where only the buffer register would hold data.

//     // No handling of erroneous and unreachable state 3.
//     // We could check and raise an error flag.

//     logic [STATE_BITS-1:0] state;
//     logic [STATE_BITS-1:0] state_next = EMPTY;

//     // ready reg
//     always @ (posedge clk) begin
//         if (!rst_n) begin
//             i_ready <= 1'b1;
//         end
//         else begin
//             i_ready <= (state_next != FULL);
//         end
//     end

//     // valid reg
//     always @ (posedge clk) begin
//         if (!rst_n) begin
//             o_valid <= 1'b0;
//         end
//         else begin
//             o_valid <= (state_next != EMPTY);
//         end
//     end

//     wire insert = (i_valid  == 1'b1) && (i_ready  == 1'b1);
//     wire remove = (o_valid == 1'b1) && (o_ready == 1'b1);

//     // reg load    = 1'b0; // Empty datapath inserts data into output register.
//     // reg flow    = 1'b0; // New inserted data into output register as the old data is removed.
//     // reg fill    = 1'b0; // New inserted data into buffer register. Data not removed from output register.
//     // reg flush   = 1'b0; // Move data from buffer register into output register. Remove old data. No new data inserted.
//     // reg unload  = 1'b0; // Remove data from output register, leaving the datapath empty.

//     wire load    = (state == EMPTY) && (insert == 1'b1) && (remove == 1'b0);
//     wire flow    = (state == BUSY)  && (insert == 1'b1) && (remove == 1'b1);
//     wire fill    = (state == BUSY)  && (insert == 1'b1) && (remove == 1'b0);
//     wire flush   = (state == FULL)  && (insert == 1'b0) && (remove == 1'b1);
//     wire unload  = (state == BUSY)  && (insert == 1'b0) && (remove == 1'b1);

//     always @ (*) begin
//         state_next = (load   == 1'b1) ? BUSY  : state;
//         state_next = (flow   == 1'b1) ? BUSY  : state_next;
//         state_next = (fill   == 1'b1) ? FULL  : state_next;
//         state_next = (flush  == 1'b1) ? BUSY  : state_next;
//         state_next = (unload == 1'b1) ? EMPTY : state_next;
//     end

//     // state reg
//     always @ (posedge clk) begin
//         if (!rst_n) begin
//             state <= EMPTY;
//         end
//         else begin
//             state <= state_next;
//         end
//     end

//     always @ (*) begin
//         data_out_wren     = (load  == 1'b1) || (flow == 1'b1) || (flush == 1'b1);
//         data_buffer_wren  = (fill  == 1'b1);
//         use_buffered_data = (flush == 1'b1);
//     end

// endmodule
