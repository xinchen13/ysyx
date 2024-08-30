`include "../inc/defines.svh"

module if_id (
    input logic clk,
    input logic rst_n,

    // from fetch
    input logic [`INST_ADDR_BUS] if_pc,
    input logic [`INST_DATA_BUS] if_inst,
    input logic if_valid,

    // from id
    input logic id_ready,

    // to id
    output logic [`INST_ADDR_BUS] id_pc,
    output logic [`INST_DATA_BUS] id_inst,
    output logic if_id_valid
);

    // valid
    always @ (posedge clk) begin
        if (!rst_n) begin
            if_id_valid <= 1'b0;
        end
        else if (id_ready) begin
            if_id_valid <= if_valid;
        end
    end

    // data
    always @ (posedge clk) begin
        if (!rst_n) begin
            id_inst <= `INST_NOP;
            id_pc   <= `CPU_RESET_ADDR;
        end
        else if (if_valid & id_ready) begin
            id_inst <= if_inst;
            id_pc   <= if_pc;
        end
    end

endmodule