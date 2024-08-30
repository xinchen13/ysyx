`include "../inc/defines.svh"

module fetch (
    input logic clk,
    input logic rst_n,
    input logic [`INST_ADDR_BUS] pc,
    output logic [`INST_DATA_BUS] inst,
    output logic valid
);
    // DPI-C: pmem_read, pmem_write
    import "DPI-C" function int dpic_pmem_read(input int raddr);

    // sram
    always @ (*) begin
        inst = dpic_pmem_read(pc);
    end

endmodule

