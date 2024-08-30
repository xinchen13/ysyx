`include "../inc/defines.svh"

module fetch (
    input logic clk,
    input logic rst_n,

    // from pc_reg
    input logic [`INST_ADDR_BUS] pc,
    input logic pc_valid,

    // to pc_reg
    output logic if_ready,

    // from id
    input logic id_ready,

    // to if_id
    output logic [`INST_DATA_BUS] inst,
    output logic if_valid
);
    logic done;
    assign done = 1'b1;

    assign if_ready = !pc_valid || (done && id_ready);
    assign if_valid = pc_valid & done;

    // DPI-C: pmem_read, pmem_write
    import "DPI-C" function int dpic_pmem_read(input int raddr);

    // sram
    always @ (*) begin
        if (pc_valid) begin
            inst = dpic_pmem_read(pc);
        end
        else begin
            inst = `INST_NOP;
        end
    end


endmodule

