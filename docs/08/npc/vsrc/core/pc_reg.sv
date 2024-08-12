`include "../inc/defines.svh"

module pc_reg (
    input logic clk,
    input logic rst_n,
    input logic [`INST_ADDR_BUS] pc_old,
    output logic [`INST_ADDR_BUS] pc_new
);

    always @ (posedge clk) begin
        if (!rst_n) begin
            pc_new <= `CPU_RESET_ADDR;
        end
        else begin
            pc_new <= pc_old + 32'd4;
        end
    end
endmodule