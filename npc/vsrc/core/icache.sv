`include "../inc/defines.svh"

module icache (
    input logic clk,
    input logic rst_n,

    // axi-lite interface: core
    // AR
    input logic [`AXI_ADDR_BUS] raw_fetch_araddr,
    input logic raw_fetch_arvalid,
    output logic raw_fetch_arready,
    // R
    output logic [`AXI_DATA_BUS] raw_fetch_rdata,
    output logic [`AXI_RESP_BUS] raw_fetch_rresp,
    output logic raw_fetch_rvalid,
    input logic raw_fetch_rready,

    // axi-lite interface: bus
    // AR
    output logic [`AXI_ADDR_BUS] fetch_araddr,
    output logic fetch_arvalid,
    input logic fetch_arready,
    // R
    input logic [`AXI_DATA_BUS] fetch_rdata,
    input logic [`AXI_RESP_BUS] fetch_rresp,
    input logic fetch_rvalid,
    output logic fetch_rready
);

    `ifdef ICACHE_ON

    `else
        assign fetch_araddr         = raw_fetch_araddr;
        assign fetch_arvalid        = raw_fetch_arvalid;
        assign raw_fetch_arready    = fetch_arready;
        assign raw_fetch_rdata      = fetch_rdata;
        assign raw_fetch_rresp      = fetch_rresp;
        assign raw_fetch_rvalid     = fetch_rvalid;
        assign fetch_rready         = raw_fetch_rready;
    `endif


endmodule