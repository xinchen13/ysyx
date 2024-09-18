`include "../inc/defines.svh"

module arbiter (
    input logic clk,
    input logic rst_n,

    // axi-lite interface (slave0: sram)
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
            grant <= {1'b0, ~grant[0]};
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
    assign s0_araddr = (grant == MASTER0) ? m0_araddr : m1_araddr;
    assign s0_arvalid = (grant == MASTER0) ? m0_arvalid : m1_arvalid;
    assign s0_rready = (grant == MASTER0) ? m0_rready : m1_rready;
    assign s0_awaddr = (grant == MASTER0) ? 'h0 : m1_awaddr;
    assign s0_awvalid = (grant == MASTER0) ? 'b0 : m1_awvalid;
    assign s0_wdata = (grant == MASTER0) ? 'h0 : m1_wdata;
    assign s0_wstrb = (grant == MASTER0) ? 'b0 : m1_wstrb;
    assign s0_wvalid = (grant == MASTER0) ? 'b0 : m1_wvalid;
    assign s0_bready = (grant == MASTER0) ? 'b0 : m1_bready;

    // master0 out
    assign m0_arready = (grant == MASTER0) ? s0_arready : 'b0;
    assign m0_rdata = (grant == MASTER0) ? s0_rdata : 'b0;
    assign m0_rresp = (grant == MASTER0) ? s0_rresp : 'b0;
    assign m0_rvalid = (grant == MASTER0) ? s0_rvalid : 'b0;
    assign m0_awready = (grant == MASTER0) ? s0_awready : 'b0;
    assign m0_wready = 'b0;
    assign m0_bresp = 'b0;
    assign m0_bvalid = 'b0;

    // master1 out
    assign m1_arready = (grant == MASTER1) ? s0_arready : 'b0;
    assign m1_rdata = (grant == MASTER1) ? s0_rdata : 'b0;
    assign m1_rresp = (grant == MASTER1) ? s0_rresp : 'b0;
    assign m1_rvalid = (grant == MASTER1) ? s0_rvalid : 'b0;
    assign m1_awready = (grant == MASTER1) ? s0_awready : 'b0;
    assign m1_wready = (grant == MASTER1) ? s0_wready : 'b0;
    assign m1_bresp = (grant == MASTER1) ? s0_bresp : 'b0;
    assign m1_bvalid = (grant == MASTER1) ? s0_bvalid : 'b0;

endmodule