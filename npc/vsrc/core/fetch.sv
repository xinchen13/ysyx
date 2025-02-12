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
    // to fetch_id
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
    output logic rready,
    // AW
    output logic [`AXI_ADDR_BUS] awaddr,
    output logic awvalid,
    input logic awready,
    // W
    output logic [`AXI_DATA_BUS] wdata,
    output logic [`AXI_WSTRB_BUS] wstrb,
    output logic wvalid,
    input logic wready,
    // B
    input logic [`AXI_RESP_BUS] bresp,
    input logic bvalid,
    output logic bready

);
    // for handshake
    assign araddr = pc;
    assign arvalid = prev_valid;
    assign rready = next_ready;
    assign this_ready = arready;
    assign inst = rdata;
    assign this_valid = rvalid;

endmodule

