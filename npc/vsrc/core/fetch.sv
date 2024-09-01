`include "../inc/defines.svh"

module fetch (
    input logic clk,
    input logic rst_n,

    // from pc_reg
    input logic [`INST_ADDR_BUS] pc,
    input logic prev_valid,

    // to pc_reg
    output logic this_ready,

    // from id
    input logic next_ready,

    // to if_id
    output logic [`INST_DATA_BUS] inst,
    output logic this_valid
);
    logic done;
    assign done = 1'b1;

    assign this_ready = !prev_valid || (done && next_ready);
    assign this_valid = prev_valid & done;

    // DPI-C: pmem_read, pmem_write
    import "DPI-C" function int dpic_pmem_read(input int raddr);

    // sram
    always @ (*) begin
        if (prev_valid) begin
            inst = dpic_pmem_read(pc);
        end
        else begin
            inst = `INST_NOP;
        end
    end

endmodule

