`include "../inc/defines.svh"

module arbiter (
    input logic clk,
    input logic rst_n,

    // axi-lite interface (connect arbiter & xbar)
    // AR
    output logic [`AXI_ADDR_BUS] arbiter_xbar_araddr,
    output logic arbiter_xbar_arvalid,
    input logic arbiter_xbar_arready,
    // R
    input logic [`AXI_DATA_BUS] arbiter_xbar_rdata,
    input logic [`AXI_RESP_BUS] arbiter_xbar_rresp,
    input logic arbiter_xbar_rvalid,
    output logic arbiter_xbar_rready,
    // AW
    output logic [`AXI_ADDR_BUS] arbiter_xbar_awaddr,
    output logic arbiter_xbar_awvalid,
    input logic arbiter_xbar_awready,
    // W
    output logic [`AXI_DATA_BUS] arbiter_xbar_wdata,
    output logic [`AXI_WSTRB_BUS] arbiter_xbar_wstrb,
    output logic arbiter_xbar_wvalid,
    input logic arbiter_xbar_wready,
    // B
    input logic [`AXI_RESP_BUS] arbiter_xbar_bresp,
    input logic arbiter_xbar_bvalid,
    output logic arbiter_xbar_bready,

    // axi-lite interface (master0: fetch)
    // AR
    input logic [`AXI_ADDR_BUS] m0_araddr,
    input logic m0_arvalid,
    output logic m0_arready,
    // R
    output logic [`AXI_DATA_BUS] m0_rdata,
    output logic [`AXI_RESP_BUS] m0_rresp,
    output logic m0_rvalid,
    input logic m0_rready,
    // AW
    input logic [`AXI_ADDR_BUS] m0_awaddr,
    input logic m0_awvalid,
    output logic m0_awready,
    // W
    input logic [`AXI_DATA_BUS] m0_wdata,
    input logic [`AXI_WSTRB_BUS] m0_wstrb,
    input logic m0_wvalid,
    output logic m0_wready,
    // B
    output logic [`AXI_RESP_BUS] m0_bresp,
    output logic m0_bvalid,
    input logic m0_bready,

    // axi-lite interface (master1: lsu)
    // AR
    input logic [`AXI_ADDR_BUS] m1_araddr,
    input logic m1_arvalid,
    output logic m1_arready,
    // R
    output logic [`AXI_DATA_BUS] m1_rdata,
    output logic [`AXI_RESP_BUS] m1_rresp,
    output logic m1_rvalid,
    input logic m1_rready,
    // AW
    input logic [`AXI_ADDR_BUS] m1_awaddr,
    input logic m1_awvalid,
    output logic m1_awready,
    // W
    input logic [`AXI_DATA_BUS] m1_wdata,
    input logic [`AXI_WSTRB_BUS] m1_wstrb,
    input logic m1_wvalid,
    output logic m1_wready,
    // B
    output logic [`AXI_RESP_BUS] m1_bresp,
    output logic m1_bvalid,
    input logic m1_bready
);
    localparam [1:0] MASTER0 = 2'b00;
    localparam [1:0] MASTER1 = 2'b01;

    logic [1:0] grant;
    logic [1:0] next_grant;

    always @ (posedge clk) begin
        if (!rst_n) begin
            grant <= MASTER0;
        end
        else begin
            grant <= next_grant;
        end
    end

    // lsu > fetch
    always @ (*) begin
        case (grant) 
            MASTER0: begin
                if (m1_awvalid | m1_arvalid) begin
                    next_grant = MASTER1;
                end
            end
            MASTER1: begin
                if (m0_arvalid & ~(m1_awvalid | m1_arvalid)) begin
                    next_grant = MASTER0;
                end
            end
            default: begin
                next_grant = MASTER0;
            end
        endcase
    end

    // slave0 out
    assign arbiter_xbar_araddr = (grant == MASTER0) ? m0_araddr : m1_araddr;
    assign arbiter_xbar_arvalid = (grant == MASTER0) ? m0_arvalid : m1_arvalid;
    assign arbiter_xbar_rready = (grant == MASTER0) ? m0_rready : m1_rready;
    assign arbiter_xbar_awaddr = (grant == MASTER0) ? 'h0 : m1_awaddr;
    assign arbiter_xbar_awvalid = (grant == MASTER0) ? 'b0 : m1_awvalid;
    assign arbiter_xbar_wdata = (grant == MASTER0) ? 'h0 : m1_wdata;
    assign arbiter_xbar_wstrb = (grant == MASTER0) ? 'b0 : m1_wstrb;
    assign arbiter_xbar_wvalid = (grant == MASTER0) ? 'b0 : m1_wvalid;
    assign arbiter_xbar_bready = (grant == MASTER0) ? 'b0 : m1_bready;

    // master0 out
    assign m0_arready = (grant == MASTER0) ? arbiter_xbar_arready : 'b0;
    assign m0_rdata = (grant == MASTER0) ? arbiter_xbar_rdata : 'b0;
    assign m0_rresp = (grant == MASTER0) ? arbiter_xbar_rresp : 'b0;
    assign m0_rvalid = (grant == MASTER0) ? arbiter_xbar_rvalid : 'b0;
    assign m0_awready = (grant == MASTER0) ? arbiter_xbar_awready : 'b0;
    assign m0_wready = 'b0;
    assign m0_bresp = 'b0;
    assign m0_bvalid = 'b0;

    // master1 out
    assign m1_arready = (grant == MASTER1) ? arbiter_xbar_arready : 'b0;
    assign m1_rdata = (grant == MASTER1) ? arbiter_xbar_rdata : 'b0;
    assign m1_rresp = (grant == MASTER1) ? arbiter_xbar_rresp : 'b0;
    assign m1_rvalid = (grant == MASTER1) ? arbiter_xbar_rvalid : 'b0;
    assign m1_awready = (grant == MASTER1) ? arbiter_xbar_awready : 'b0;
    assign m1_wready = (grant == MASTER1) ? arbiter_xbar_wready : 'b0;
    assign m1_bresp = (grant == MASTER1) ? arbiter_xbar_bresp : 'b0;
    assign m1_bvalid = (grant == MASTER1) ? arbiter_xbar_bvalid : 'b0;

endmodule