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