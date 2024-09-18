`include "../inc/defines.svh"

module xbar (
    input logic clk,
    input logic rst_n,

    // axi-lite interface (connect arbiter & xbar)
    // AR
    input logic [`AXI_ADDR_BUS] arbiter_xbar_araddr,
    input logic arbiter_xbar_arvalid,
    output logic arbiter_xbar_arready,
    // R
    output logic [`AXI_DATA_BUS] arbiter_xbar_rdata,
    output logic [`AXI_RESP_BUS] arbiter_xbar_rresp,
    output logic arbiter_xbar_rvalid,
    input logic arbiter_xbar_rready,
    // AW
    input logic [`AXI_ADDR_BUS] arbiter_xbar_awaddr,
    input logic arbiter_xbar_awvalid,
    output logic arbiter_xbar_awready,
    // W
    input logic [`AXI_DATA_BUS] arbiter_xbar_wdata,
    input logic [`AXI_WSTRB_BUS] arbiter_xbar_wstrb,
    input logic arbiter_xbar_wvalid,
    output logic arbiter_xbar_wready,
    // B
    output logic [`AXI_RESP_BUS] arbiter_xbar_bresp,
    output logic arbiter_xbar_bvalid,
    input logic arbiter_xbar_bready,

    // axi-lite interface (s0: sram)
    // AR
    output logic [`AXI_ADDR_BUS] s0_araddr,
    output logic s0_arvalid,
    input logic s0_arready,
    // R
    input logic [`AXI_DATA_BUS] s0_rdata,
    input logic [`AXI_RESP_BUS] s0_rresp,
    input logic s0_rvalid,
    output logic s0_rready,
    // AW
    output logic [`AXI_ADDR_BUS] s0_awaddr,
    output logic s0_awvalid,
    input logic s0_awready,
    // W
    output logic [`AXI_DATA_BUS] s0_wdata,
    output logic [`AXI_WSTRB_BUS] s0_wstrb,
    output logic s0_wvalid,
    input logic s0_wready,
    // B
    input logic [`AXI_RESP_BUS] s0_bresp,
    input logic s0_bvalid,
    output logic s0_bready,

    // axi-lite interface (s1: uart)
    // AR
    output logic [`AXI_ADDR_BUS] s1_araddr,
    output logic s1_arvalid,
    input logic s1_arready,
    // R
    input logic [`AXI_DATA_BUS] s1_rdata,
    input logic [`AXI_RESP_BUS] s1_rresp,
    input logic s1_rvalid,
    output logic s1_rready,
    // AW
    output logic [`AXI_ADDR_BUS] s1_awaddr,
    output logic s1_awvalid,
    input logic s1_awready,
    // W
    output logic [`AXI_DATA_BUS] s1_wdata,
    output logic [`AXI_WSTRB_BUS] s1_wstrb,
    output logic s1_wvalid,
    input logic s1_wready,
    // B
    input logic [`AXI_RESP_BUS] s1_bresp,
    input logic s1_bvalid,
    output logic s1_bready
);

    always @ (*) begin
        if ((arbiter_xbar_araddr == 32'ha00003f8) || (arbiter_xbar_awaddr == 32'ha00003f8)) begin
            s1_araddr = arbiter_xbar_araddr;
            s1_arvalid = arbiter_xbar_arvalid;
            arbiter_xbar_arready = s1_arready;
            arbiter_xbar_rdata = s1_rdata;
            arbiter_xbar_rresp = s1_rresp;
            arbiter_xbar_rvalid = s1_rvalid;
            s1_rready = arbiter_xbar_rready;
            s1_awaddr = arbiter_xbar_awaddr;
            s1_awvalid = arbiter_xbar_awvalid;
            arbiter_xbar_awready = s1_awready;
            s1_wdata = arbiter_xbar_wdata;
            s1_wstrb = arbiter_xbar_wstrb;
            s1_wvalid = arbiter_xbar_wvalid;
            arbiter_xbar_wready = s1_wready;
            arbiter_xbar_bresp = s1_bresp;
            arbiter_xbar_bvalid = s1_bvalid;
            s1_bready = arbiter_xbar_bready;

            s0_araddr = 'b0;
            s0_arvalid = 'b0;
            s0_rready = 'b0;
            s0_awaddr = 'b0;
            s0_awvalid = 'b0;
            s0_wdata = 'b0;
            s0_wstrb = 'b0;
            s0_wvalid = 'b0;
            s0_bready = 'b0;
        end
        else begin
            s0_araddr = arbiter_xbar_araddr;
            s0_arvalid = arbiter_xbar_arvalid;
            arbiter_xbar_arready = s0_arready;
            arbiter_xbar_rdata = s0_rdata;
            arbiter_xbar_rresp = s0_rresp;
            arbiter_xbar_rvalid = s0_rvalid;
            s0_rready = arbiter_xbar_rready;
            s0_awaddr = arbiter_xbar_awaddr;
            s0_awvalid = arbiter_xbar_awvalid;
            arbiter_xbar_awready = s0_awready;
            s0_wdata = arbiter_xbar_wdata;
            s0_wstrb = arbiter_xbar_wstrb;
            s0_wvalid = arbiter_xbar_wvalid;
            arbiter_xbar_wready = s0_wready;
            arbiter_xbar_bresp = s0_bresp;
            arbiter_xbar_bvalid = s0_bvalid;
            s0_bready = arbiter_xbar_bready;

            s1_araddr = 'b0;
            s1_arvalid = 'b0;
            s1_rready = 'b0;
            s1_awaddr = 'b0;
            s1_awvalid = 'b0;
            s1_wdata = 'b0;
            s1_wstrb = 'b0;
            s1_wvalid = 'b0;
            s1_bready = 'b0;
        end
    end




endmodule