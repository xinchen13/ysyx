`include "../inc/defines.svh"

module pc_reg (
    input logic                     clk,
    input logic                     rst_n,
    input logic                     pipe_flush,
    input logic                     ex_jump,
    input logic [`INST_ADDR_BUS]    ex_dnpc,
    output logic [`INST_ADDR_BUS]   pc_new,
    output logic                    this_valid,
    input logic                     next_ready
);

    always @ (posedge clk) begin
        if (!rst_n) begin
            pc_new <= `CPU_RESET_ADDR;
        end
        else if (ex_jump) begin
            pc_new <= ex_dnpc;
        end
        else if (this_valid & next_ready) begin
            pc_new <= pc_new + 32'd4;
        end
    end

    assign this_valid = ~pipe_flush;

endmodule