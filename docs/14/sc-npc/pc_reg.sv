`include "defines.svh"

module pc_reg (
    input logic clk,
    input logic rst_n,
    input logic [`INST_ADDR_BUS] dnpc,
    output logic [`INST_ADDR_BUS] pc
);

    always @ (posedge clk) begin
        if (!rst_n) begin
            pc <= `CPU_RESET_ADDR;
        end
        else begin
            pc <= dnpc;
        end
    end
endmodule