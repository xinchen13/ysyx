`include "./inc/defines.svh"

module soc_top (
/*AUTOINPUT*/
// Beginning of automatic inputs (from unused autoinst inputs)
input logic		sram_arready,		// To arbiter_u0 of arbiter.v
input logic		sram_awready,		// To arbiter_u0 of arbiter.v
input logic [`AXI_RESP_BUS] sram_bresp,		// To arbiter_u0 of arbiter.v
input logic		sram_bvalid,		// To arbiter_u0 of arbiter.v
input logic [`AXI_DATA_BUS] sram_rdata,		// To arbiter_u0 of arbiter.v
input logic [`AXI_RESP_BUS] sram_rresp,		// To arbiter_u0 of arbiter.v
input logic		sram_rvalid,		// To arbiter_u0 of arbiter.v
input logic		sram_wready,		// To arbiter_u0 of arbiter.v
// End of automatics
/*AUTOOUTPUT*/
// Beginning of automatic outputs (from unused autoinst outputs)
output logic [`AXI_ADDR_BUS] sram_araddr,	// From arbiter_u0 of arbiter.v
output logic		sram_arvalid,		// From arbiter_u0 of arbiter.v
output logic [`AXI_ADDR_BUS] sram_awaddr,	// From arbiter_u0 of arbiter.v
output logic		sram_awvalid,		// From arbiter_u0 of arbiter.v
output logic		sram_bready,		// From arbiter_u0 of arbiter.v
output logic		sram_rready,		// From arbiter_u0 of arbiter.v
output logic [`AXI_DATA_BUS] sram_wdata,	// From arbiter_u0 of arbiter.v
output logic [`AXI_WSTRB_BUS] sram_wstrb,	// From arbiter_u0 of arbiter.v
output logic		sram_wvalid,		// From arbiter_u0 of arbiter.v
// End of automatics
    input logic clk,
    input logic rst_n
 );

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
logic [`AXI_ADDR_BUS]	fetch_araddr;		// From xcore_u0 of xcore.v
logic			fetch_arready;		// From arbiter_u0 of arbiter.v
logic			fetch_arvalid;		// From xcore_u0 of xcore.v
logic [`AXI_DATA_BUS]	fetch_rdata;		// From arbiter_u0 of arbiter.v
logic			fetch_rready;		// From xcore_u0 of xcore.v
logic [`AXI_RESP_BUS]	fetch_rresp;		// From arbiter_u0 of arbiter.v
logic			fetch_rvalid;		// From arbiter_u0 of arbiter.v
logic [`AXI_ADDR_BUS]	lsu_araddr;		// From xcore_u0 of xcore.v
logic			lsu_arready;		// From arbiter_u0 of arbiter.v
logic			lsu_arvalid;		// From xcore_u0 of xcore.v
logic [`AXI_ADDR_BUS]	lsu_awaddr;		// From xcore_u0 of xcore.v
logic			lsu_awready;		// From arbiter_u0 of arbiter.v
logic			lsu_awvalid;		// From xcore_u0 of xcore.v
logic			lsu_bready;		// From xcore_u0 of xcore.v
logic [`AXI_RESP_BUS]	lsu_bresp;		// From arbiter_u0 of arbiter.v
logic			lsu_bvalid;		// From arbiter_u0 of arbiter.v
logic [`AXI_DATA_BUS]	lsu_rdata;		// From arbiter_u0 of arbiter.v
logic			lsu_rready;		// From xcore_u0 of xcore.v
logic [`AXI_RESP_BUS]	lsu_rresp;		// From arbiter_u0 of arbiter.v
logic			lsu_rvalid;		// From arbiter_u0 of arbiter.v
logic [`AXI_DATA_BUS]	lsu_wdata;		// From xcore_u0 of xcore.v
logic			lsu_wready;		// From arbiter_u0 of arbiter.v
logic [`AXI_WSTRB_BUS]	lsu_wstrb;		// From xcore_u0 of xcore.v
logic			lsu_wvalid;		// From xcore_u0 of xcore.v
// End of automatics


/*xcore AUTO_TEMPLATE (
    .clk(clk),
    .rst_n(rst_n),
);
*/
xcore xcore_u0 (/*AUTOINST*/
		// Outputs
		.fetch_araddr		(fetch_araddr[`AXI_ADDR_BUS]),
		.fetch_arvalid		(fetch_arvalid),
		.fetch_rready		(fetch_rready),
		.lsu_araddr		(lsu_araddr[`AXI_ADDR_BUS]),
		.lsu_arvalid		(lsu_arvalid),
		.lsu_rready		(lsu_rready),
		.lsu_awaddr		(lsu_awaddr[`AXI_ADDR_BUS]),
		.lsu_awvalid		(lsu_awvalid),
		.lsu_wdata		(lsu_wdata[`AXI_DATA_BUS]),
		.lsu_wstrb		(lsu_wstrb[`AXI_WSTRB_BUS]),
		.lsu_wvalid		(lsu_wvalid),
		.lsu_bready		(lsu_bready),
		// Inputs
		.clk			(clk),			 // Templated
		.rst_n			(rst_n),		 // Templated
		.fetch_arready		(fetch_arready),
		.fetch_rdata		(fetch_rdata[`AXI_DATA_BUS]),
		.fetch_rresp		(fetch_rresp[`AXI_RESP_BUS]),
		.fetch_rvalid		(fetch_rvalid),
		.lsu_arready		(lsu_arready),
		.lsu_rdata		(lsu_rdata[`AXI_DATA_BUS]),
		.lsu_rresp		(lsu_rresp[`AXI_RESP_BUS]),
		.lsu_rvalid		(lsu_rvalid),
		.lsu_awready		(lsu_awready),
		.lsu_wready		(lsu_wready),
		.lsu_bresp		(lsu_bresp[`AXI_RESP_BUS]),
		.lsu_bvalid		(lsu_bvalid)); 


/*arbiter AUTO_TEMPLATE (
    .clk(clk),
    .rst_n(rst_n),

    .m0_araddr(fetch_araddr),
    .m0_arvalid(fetch_arvalid),
    .m0_arready(fetch_arready),
    .m0_rdata(fetch_rdata[`AXI_DATA_BUS]),
    .m0_rresp(fetch_rresp[`AXI_RESP_BUS]),
    .m0_rvalid(fetch_rvalid),
    .m0_rready(fetch_rready),
    .m0_awaddr(),
    .m0_awvalid(),
    .m0_awready(),
    .m0_wdata(),
    .m0_wstrb(),
    .m0_wvalid(),
    .m0_wready(),
    .m0_bresp(),
    .m0_bvalid(),
    .m0_bready(),

    .m1_araddr(lsu_araddr),
    .m1_arvalid(lsu_arvalid),
    .m1_arready(lsu_arready),
    .m1_rdata(lsu_rdata[`AXI_DATA_BUS]),
    .m1_rresp(lsu_rresp[`AXI_RESP_BUS]),
    .m1_rvalid(lsu_rvalid),
    .m1_rready(lsu_rready),
    .m1_awaddr(lsu_awaddr),
    .m1_awvalid(lsu_awvalid),
    .m1_awready(lsu_awready),
    .m1_wdata(lsu_wdata[`AXI_DATA_BUS]),
    .m1_wstrb(lsu_wstrb),
    .m1_wvalid(lsu_wvalid),
    .m1_wready(lsu_wready),
    .m1_bresp(lsu_bresp[`AXI_RESP_BUS]),
    .m1_bvalid(lsu_bvalid),
    .m1_bready(lsu_bready),

    .s0_araddr(sram_araddr[`AXI_ADDR_BUS]),
    .s0_arvalid(sram_arvalid),
    .s0_arready(sram_arready),
    .s0_rdata(sram_rdata[`AXI_DATA_BUS]),
    .s0_rresp(sram_rresp[`AXI_RESP_BUS]),
    .s0_rvalid(sram_rvalid),
    .s0_rready(sram_rready),
    .s0_awaddr(sram_awaddr[`AXI_ADDR_BUS]),
    .s0_awvalid(sram_awvalid),
    .s0_awready(sram_awready),
    .s0_wdata(sram_wdata[`AXI_DATA_BUS]),
    .s0_wstrb(sram_wstrb[`AXI_WSTRB_BUS]),
    .s0_wvalid(sram_wvalid),
    .s0_wready(sram_wready),
    .s0_bresp(sram_bresp[`AXI_RESP_BUS]),
    .s0_bvalid(sram_bvalid),
    .s0_bready(sram_bready),
);
*/
arbiter arbiter_u0 (/*AUTOINST*/
		    // Outputs
		    .s0_araddr		(sram_araddr[`AXI_ADDR_BUS]), // Templated
		    .s0_arvalid		(sram_arvalid),		 // Templated
		    .s0_rready		(sram_rready),		 // Templated
		    .s0_awaddr		(sram_awaddr[`AXI_ADDR_BUS]), // Templated
		    .s0_awvalid		(sram_awvalid),		 // Templated
		    .s0_wdata		(sram_wdata[`AXI_DATA_BUS]), // Templated
		    .s0_wstrb		(sram_wstrb[`AXI_WSTRB_BUS]), // Templated
		    .s0_wvalid		(sram_wvalid),		 // Templated
		    .s0_bready		(sram_bready),		 // Templated
		    .m0_arready		(fetch_arready),	 // Templated
		    .m0_rdata		(fetch_rdata[`AXI_DATA_BUS]), // Templated
		    .m0_rresp		(fetch_rresp[`AXI_RESP_BUS]), // Templated
		    .m0_rvalid		(fetch_rvalid),		 // Templated
		    .m0_awready		(),			 // Templated
		    .m0_wready		(),			 // Templated
		    .m0_bresp		(),			 // Templated
		    .m0_bvalid		(),			 // Templated
		    .m1_arready		(lsu_arready),		 // Templated
		    .m1_rdata		(lsu_rdata[`AXI_DATA_BUS]), // Templated
		    .m1_rresp		(lsu_rresp[`AXI_RESP_BUS]), // Templated
		    .m1_rvalid		(lsu_rvalid),		 // Templated
		    .m1_awready		(lsu_awready),		 // Templated
		    .m1_wready		(lsu_wready),		 // Templated
		    .m1_bresp		(lsu_bresp[`AXI_RESP_BUS]), // Templated
		    .m1_bvalid		(lsu_bvalid),		 // Templated
		    // Inputs
		    .clk		(clk),			 // Templated
		    .rst_n		(rst_n),		 // Templated
		    .s0_arready		(sram_arready),		 // Templated
		    .s0_rdata		(sram_rdata[`AXI_DATA_BUS]), // Templated
		    .s0_rresp		(sram_rresp[`AXI_RESP_BUS]), // Templated
		    .s0_rvalid		(sram_rvalid),		 // Templated
		    .s0_awready		(sram_awready),		 // Templated
		    .s0_wready		(sram_wready),		 // Templated
		    .s0_bresp		(sram_bresp[`AXI_RESP_BUS]), // Templated
		    .s0_bvalid		(sram_bvalid),		 // Templated
		    .m0_araddr		(fetch_araddr),		 // Templated
		    .m0_arvalid		(fetch_arvalid),	 // Templated
		    .m0_rready		(fetch_rready),		 // Templated
		    .m0_awaddr		(),			 // Templated
		    .m0_awvalid		(),			 // Templated
		    .m0_wdata		(),			 // Templated
		    .m0_wstrb		(),			 // Templated
		    .m0_wvalid		(),			 // Templated
		    .m0_bready		(),			 // Templated
		    .m1_araddr		(lsu_araddr),		 // Templated
		    .m1_arvalid		(lsu_arvalid),		 // Templated
		    .m1_rready		(lsu_rready),		 // Templated
		    .m1_awaddr		(lsu_awaddr),		 // Templated
		    .m1_awvalid		(lsu_awvalid),		 // Templated
		    .m1_wdata		(lsu_wdata[`AXI_DATA_BUS]), // Templated
		    .m1_wstrb		(lsu_wstrb),		 // Templated
		    .m1_wvalid		(lsu_wvalid),		 // Templated
		    .m1_bready		(lsu_bready));		 // Templated

endmodule
// Local Variables:
// verilog-library-directories:("." "./core" "./bus")
// verilog-library-extensions:(".v" ".sv")
// verilog-auto-template-warn-unused: t
// verilog-auto-tieoff-declaration: "assign"
// verilog-auto-unused-ignore-regexp: "^db$"
// verilog-auto-declare-nettype: ""
// End:
