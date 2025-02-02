`include "../inc/defines.svh"

module fetch (
    input logic clk,
    input logic rst_n,

    // interface with pc_reg
    input logic [`INST_ADDR_BUS] pc,
    input logic prev_valid,
    output logic this_ready,
    // interface with id
    input logic next_ready,
    output logic [`INST_DATA_BUS] inst,
    output logic this_valid,

    // axi-lite interface (master)
    // AR
    output logic [`AXI_ADDR_BUS] araddr,
    output logic arvalid,
    input logic arready,
    // R
    input logic [`AXI_DATA_BUS] rdata,
    input logic [`AXI_RESP_BUS] rresp,
    input logic rvalid,
    output logic rready

);
    // axi-lite output
    assign araddr = pc;
    assign arvalid = prev_valid;
    assign rready = next_ready;

    // axi-lite input
    assign this_ready = arready;
    assign inst = rdata;
    assign this_valid = rvalid;

endmodule

