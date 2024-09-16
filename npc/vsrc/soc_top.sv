`include "../inc/defines.svh"

module soc_top (
    input logic clk,
    input logic rst_n
);

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
logic [`AXI_ADDR_BUS]	fetch_araddr;		// From xcore_u0 of xcore.v
logic			fetch_arready;		// From isram_u0 of isram.v
logic			fetch_arvalid;		// From xcore_u0 of xcore.v
logic [`AXI_DATA_BUS]	fetch_rdata;		// From isram_u0 of isram.v
logic			fetch_rready;		// From xcore_u0 of xcore.v
logic [`AXI_RESP_BUS]	fetch_rresp;		// From isram_u0 of isram.v
logic			fetch_rvalid;		// From isram_u0 of isram.v
logic [`AXI_ADDR_BUS]	lsu_araddr;		// From xcore_u0 of xcore.v
logic			lsu_arready;		// From dsram_u0 of dsram.v
logic			lsu_arvalid;		// From xcore_u0 of xcore.v
logic [`AXI_ADDR_BUS]	lsu_awaddr;		// From xcore_u0 of xcore.v
logic			lsu_awready;		// From dsram_u0 of dsram.v
logic			lsu_awvalid;		// From xcore_u0 of xcore.v
logic			lsu_bready;		// From xcore_u0 of xcore.v
logic [`AXI_RESP_BUS]	lsu_bresp;		// From dsram_u0 of dsram.v
logic			lsu_bvalid;		// From dsram_u0 of dsram.v
logic [`AXI_DATA_BUS]	lsu_rdata;		// From dsram_u0 of dsram.v
logic			lsu_rready;		// From xcore_u0 of xcore.v
logic [`AXI_RESP_BUS]	lsu_rresp;		// From dsram_u0 of dsram.v
logic			lsu_rvalid;		// From dsram_u0 of dsram.v
logic [`AXI_DATA_BUS]	lsu_wdata;		// From xcore_u0 of xcore.v
logic			lsu_wready;		// From dsram_u0 of dsram.v
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


/*isram AUTO_TEMPLATE (
    .clk(clk),
    .rst_n(rst_n),
    .araddr(fetch_araddr),
    .arvalid(fetch_arvalid),
    .arready(fetch_arready),
    .rdata(fetch_rdata[`AXI_DATA_BUS]),
    .rresp(fetch_rresp[`AXI_RESP_BUS]),
    .rvalid(fetch_rvalid),
    .rready(fetch_rready),
    .awaddr(),
    .awvalid(),
    .awready(),
    .wdata(),
    .wstrb(),
    .wvalid(),
    .wready(),
    .bresp(),
    .bvalid(),
    .bready(),
);
*/
isram isram_u0 (/*AUTOINST*/
		// Outputs
		.arready		(fetch_arready),	 // Templated
		.rdata			(fetch_rdata[`AXI_DATA_BUS]), // Templated
		.rresp			(fetch_rresp[`AXI_RESP_BUS]), // Templated
		.rvalid			(fetch_rvalid),		 // Templated
		.awready		(),			 // Templated
		.wready			(),			 // Templated
		.bresp			(),			 // Templated
		.bvalid			(),			 // Templated
		// Inputs
		.clk			(clk),			 // Templated
		.rst_n			(rst_n),		 // Templated
		.araddr			(fetch_araddr),		 // Templated
		.arvalid		(fetch_arvalid),	 // Templated
		.rready			(fetch_rready),		 // Templated
		.awaddr			(),			 // Templated
		.awvalid		(),			 // Templated
		.wdata			(),			 // Templated
		.wstrb			(),			 // Templated
		.wvalid			(),			 // Templated
		.bready			());			 // Templated


/*dsram AUTO_TEMPLATE (
    .clk(clk),
    .rst_n(rst_n),
    .araddr(lsu_araddr),
    .arvalid(lsu_arvalid),
    .arready(lsu_arready),
    .rdata(lsu_rdata[`AXI_DATA_BUS]),
    .rresp(lsu_rresp[`AXI_RESP_BUS]),
    .rvalid(lsu_rvalid),
    .rready(lsu_rready),
    .awaddr(lsu_awaddr),
    .awvalid(lsu_awvalid),
    .awready(lsu_awready),
    .wdata(lsu_wdata),
    .wstrb(lsu_wstrb),
    .wvalid(lsu_wvalid),
    .wready(lsu_wready),
    .bresp(lsu_bresp[`AXI_RESP_BUS]),
    .bvalid(lsu_bvalid),
    .bready(lsu_bready),
);
*/
dsram dsram_u0 (/*AUTOINST*/
		// Outputs
		.arready		(lsu_arready),		 // Templated
		.rdata			(lsu_rdata[`AXI_DATA_BUS]), // Templated
		.rresp			(lsu_rresp[`AXI_RESP_BUS]), // Templated
		.rvalid			(lsu_rvalid),		 // Templated
		.awready		(lsu_awready),		 // Templated
		.wready			(lsu_wready),		 // Templated
		.bresp			(lsu_bresp[`AXI_RESP_BUS]), // Templated
		.bvalid			(lsu_bvalid),		 // Templated
		// Inputs
		.clk			(clk),			 // Templated
		.rst_n			(rst_n),		 // Templated
		.araddr			(lsu_araddr),		 // Templated
		.arvalid		(lsu_arvalid),		 // Templated
		.rready			(lsu_rready),		 // Templated
		.awaddr			(lsu_awaddr),		 // Templated
		.awvalid		(lsu_awvalid),		 // Templated
		.wdata			(lsu_wdata),		 // Templated
		.wstrb			(lsu_wstrb),		 // Templated
		.wvalid			(lsu_wvalid),		 // Templated
		.bready			(lsu_bready));		 // Templated

endmodule
// Local Variables:
// verilog-library-directories:("." "./core" "./perip")
// verilog-library-extensions:(".v" ".sv")
// verilog-auto-template-warn-unused: t
// verilog-auto-tieoff-declaration: "assign"
// verilog-auto-unused-ignore-regexp: "^db$"
// verilog-auto-declare-nettype: ""
// End:
