`include "../inc/defines.svh"

module soc_top (
    /*AUTOINPUT*/
    /*AUTOOUTPUT*/
    input logic clk,
    input logic rst_n
);

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
logic [`AXI_ADDR_BUS]	arbiter_xbar_araddr;	// From arbiter_u0 of arbiter.v
logic			arbiter_xbar_arready;	// From xbar_u0 of xbar.v
logic			arbiter_xbar_arvalid;	// From arbiter_u0 of arbiter.v
logic [`AXI_ADDR_BUS]	arbiter_xbar_awaddr;	// From arbiter_u0 of arbiter.v
logic			arbiter_xbar_awready;	// From xbar_u0 of xbar.v
logic			arbiter_xbar_awvalid;	// From arbiter_u0 of arbiter.v
logic			arbiter_xbar_bready;	// From arbiter_u0 of arbiter.v
logic [`AXI_RESP_BUS]	arbiter_xbar_bresp;	// From xbar_u0 of xbar.v
logic			arbiter_xbar_bvalid;	// From xbar_u0 of xbar.v
logic [`AXI_DATA_BUS]	arbiter_xbar_rdata;	// From xbar_u0 of xbar.v
logic			arbiter_xbar_rready;	// From arbiter_u0 of arbiter.v
logic [`AXI_RESP_BUS]	arbiter_xbar_rresp;	// From xbar_u0 of xbar.v
logic			arbiter_xbar_rvalid;	// From xbar_u0 of xbar.v
logic [`AXI_DATA_BUS]	arbiter_xbar_wdata;	// From arbiter_u0 of arbiter.v
logic			arbiter_xbar_wready;	// From xbar_u0 of xbar.v
logic [`AXI_WSTRB_BUS]	arbiter_xbar_wstrb;	// From arbiter_u0 of arbiter.v
logic			arbiter_xbar_wvalid;	// From arbiter_u0 of arbiter.v
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
logic [`AXI_ADDR_BUS]	sram_araddr;		// From xbar_u0 of xbar.v
logic			sram_arready;		// From sram_u0 of sram.v
logic			sram_arvalid;		// From xbar_u0 of xbar.v
logic [`AXI_ADDR_BUS]	sram_awaddr;		// From xbar_u0 of xbar.v
logic			sram_awready;		// From sram_u0 of sram.v
logic			sram_awvalid;		// From xbar_u0 of xbar.v
logic			sram_bready;		// From xbar_u0 of xbar.v
logic [`AXI_RESP_BUS]	sram_bresp;		// From sram_u0 of sram.v
logic			sram_bvalid;		// From sram_u0 of sram.v
logic [`AXI_DATA_BUS]	sram_rdata;		// From sram_u0 of sram.v
logic			sram_rready;		// From xbar_u0 of xbar.v
logic [`AXI_RESP_BUS]	sram_rresp;		// From sram_u0 of sram.v
logic			sram_rvalid;		// From sram_u0 of sram.v
logic [`AXI_DATA_BUS]	sram_wdata;		// From xbar_u0 of xbar.v
logic			sram_wready;		// From sram_u0 of sram.v
logic [`AXI_WSTRB_BUS]	sram_wstrb;		// From xbar_u0 of xbar.v
logic			sram_wvalid;		// From xbar_u0 of xbar.v
logic [`AXI_ADDR_BUS]	uart_araddr;		// From xbar_u0 of xbar.v
logic			uart_arready;		// From uart_u0 of uart.v
logic			uart_arvalid;		// From xbar_u0 of xbar.v
logic [`AXI_ADDR_BUS]	uart_awaddr;		// From xbar_u0 of xbar.v
logic			uart_awready;		// From uart_u0 of uart.v
logic			uart_awvalid;		// From xbar_u0 of xbar.v
logic			uart_bready;		// From xbar_u0 of xbar.v
logic [`AXI_RESP_BUS]	uart_bresp;		// From uart_u0 of uart.v
logic			uart_bvalid;		// From uart_u0 of uart.v
logic [`AXI_DATA_BUS]	uart_rdata;		// From uart_u0 of uart.v
logic			uart_rready;		// From xbar_u0 of xbar.v
logic [`AXI_RESP_BUS]	uart_rresp;		// From uart_u0 of uart.v
logic			uart_rvalid;		// From uart_u0 of uart.v
logic [`AXI_DATA_BUS]	uart_wdata;		// From xbar_u0 of xbar.v
logic			uart_wready;		// From uart_u0 of uart.v
logic [`AXI_WSTRB_BUS]	uart_wstrb;		// From xbar_u0 of xbar.v
logic			uart_wvalid;		// From xbar_u0 of xbar.v
// End of automatics

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
		.clk			(clk),
		.rst_n			(rst_n),
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
);
*/
arbiter arbiter_u0 (/*AUTOINST*/
		    // Outputs
		    .arbiter_xbar_araddr(arbiter_xbar_araddr[`AXI_ADDR_BUS]),
		    .arbiter_xbar_arvalid(arbiter_xbar_arvalid),
		    .arbiter_xbar_rready(arbiter_xbar_rready),
		    .arbiter_xbar_awaddr(arbiter_xbar_awaddr[`AXI_ADDR_BUS]),
		    .arbiter_xbar_awvalid(arbiter_xbar_awvalid),
		    .arbiter_xbar_wdata	(arbiter_xbar_wdata[`AXI_DATA_BUS]),
		    .arbiter_xbar_wstrb	(arbiter_xbar_wstrb[`AXI_WSTRB_BUS]),
		    .arbiter_xbar_wvalid(arbiter_xbar_wvalid),
		    .arbiter_xbar_bready(arbiter_xbar_bready),
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
		    .clk		(clk),
		    .rst_n		(rst_n),
		    .arbiter_xbar_arready(arbiter_xbar_arready),
		    .arbiter_xbar_rdata	(arbiter_xbar_rdata[`AXI_DATA_BUS]),
		    .arbiter_xbar_rresp	(arbiter_xbar_rresp[`AXI_RESP_BUS]),
		    .arbiter_xbar_rvalid(arbiter_xbar_rvalid),
		    .arbiter_xbar_awready(arbiter_xbar_awready),
		    .arbiter_xbar_wready(arbiter_xbar_wready),
		    .arbiter_xbar_bresp	(arbiter_xbar_bresp[`AXI_RESP_BUS]),
		    .arbiter_xbar_bvalid(arbiter_xbar_bvalid),
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


/*xbar AUTO_TEMPLATE (
    .s0_araddr(sram_araddr[]),
    .s0_arvalid(sram_arvalid),
    .s0_arready(sram_arready),
    .s0_rdata(sram_rdata[]),
    .s0_rresp(sram_rresp[]),
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
    .s1_araddr(uart_araddr[`AXI_ADDR_BUS]),
    .s1_arvalid(uart_arvalid),
    .s1_arready(uart_arready),
    .s1_rdata(uart_rdata[`AXI_DATA_BUS]),
    .s1_rresp(uart_rresp[`AXI_RESP_BUS]),
    .s1_rvalid(uart_rvalid),
    .s1_rready(uart_rready),
    .s1_awaddr(uart_awaddr[`AXI_ADDR_BUS]),
    .s1_awvalid(uart_awvalid),
    .s1_awready(uart_awready),
    .s1_wdata(uart_wdata[`AXI_DATA_BUS]),
    .s1_wstrb(uart_wstrb[`AXI_WSTRB_BUS]),
    .s1_wvalid(uart_wvalid),
    .s1_wready(uart_wready),
    .s1_bresp(uart_bresp[`AXI_RESP_BUS]),
    .s1_bvalid(uart_bvalid),
    .s1_bready(uart_bready),
);
*/
xbar xbar_u0 (/*AUTOINST*/
	      // Outputs
	      .arbiter_xbar_arready	(arbiter_xbar_arready),
	      .arbiter_xbar_rdata	(arbiter_xbar_rdata[`AXI_DATA_BUS]),
	      .arbiter_xbar_rresp	(arbiter_xbar_rresp[`AXI_RESP_BUS]),
	      .arbiter_xbar_rvalid	(arbiter_xbar_rvalid),
	      .arbiter_xbar_awready	(arbiter_xbar_awready),
	      .arbiter_xbar_wready	(arbiter_xbar_wready),
	      .arbiter_xbar_bresp	(arbiter_xbar_bresp[`AXI_RESP_BUS]),
	      .arbiter_xbar_bvalid	(arbiter_xbar_bvalid),
	      .s0_araddr		(sram_araddr[`AXI_ADDR_BUS]), // Templated
	      .s0_arvalid		(sram_arvalid),		 // Templated
	      .s0_rready		(sram_rready),		 // Templated
	      .s0_awaddr		(sram_awaddr[`AXI_ADDR_BUS]), // Templated
	      .s0_awvalid		(sram_awvalid),		 // Templated
	      .s0_wdata			(sram_wdata[`AXI_DATA_BUS]), // Templated
	      .s0_wstrb			(sram_wstrb[`AXI_WSTRB_BUS]), // Templated
	      .s0_wvalid		(sram_wvalid),		 // Templated
	      .s0_bready		(sram_bready),		 // Templated
	      .s1_araddr		(uart_araddr[`AXI_ADDR_BUS]), // Templated
	      .s1_arvalid		(uart_arvalid),		 // Templated
	      .s1_rready		(uart_rready),		 // Templated
	      .s1_awaddr		(uart_awaddr[`AXI_ADDR_BUS]), // Templated
	      .s1_awvalid		(uart_awvalid),		 // Templated
	      .s1_wdata			(uart_wdata[`AXI_DATA_BUS]), // Templated
	      .s1_wstrb			(uart_wstrb[`AXI_WSTRB_BUS]), // Templated
	      .s1_wvalid		(uart_wvalid),		 // Templated
	      .s1_bready		(uart_bready),		 // Templated
	      // Inputs
	      .clk			(clk),
	      .rst_n			(rst_n),
	      .arbiter_xbar_araddr	(arbiter_xbar_araddr[`AXI_ADDR_BUS]),
	      .arbiter_xbar_arvalid	(arbiter_xbar_arvalid),
	      .arbiter_xbar_rready	(arbiter_xbar_rready),
	      .arbiter_xbar_awaddr	(arbiter_xbar_awaddr[`AXI_ADDR_BUS]),
	      .arbiter_xbar_awvalid	(arbiter_xbar_awvalid),
	      .arbiter_xbar_wdata	(arbiter_xbar_wdata[`AXI_DATA_BUS]),
	      .arbiter_xbar_wstrb	(arbiter_xbar_wstrb[`AXI_WSTRB_BUS]),
	      .arbiter_xbar_wvalid	(arbiter_xbar_wvalid),
	      .arbiter_xbar_bready	(arbiter_xbar_bready),
	      .s0_arready		(sram_arready),		 // Templated
	      .s0_rdata			(sram_rdata[`AXI_DATA_BUS]), // Templated
	      .s0_rresp			(sram_rresp[`AXI_RESP_BUS]), // Templated
	      .s0_rvalid		(sram_rvalid),		 // Templated
	      .s0_awready		(sram_awready),		 // Templated
	      .s0_wready		(sram_wready),		 // Templated
	      .s0_bresp			(sram_bresp[`AXI_RESP_BUS]), // Templated
	      .s0_bvalid		(sram_bvalid),		 // Templated
	      .s1_arready		(uart_arready),		 // Templated
	      .s1_rdata			(uart_rdata[`AXI_DATA_BUS]), // Templated
	      .s1_rresp			(uart_rresp[`AXI_RESP_BUS]), // Templated
	      .s1_rvalid		(uart_rvalid),		 // Templated
	      .s1_awready		(uart_awready),		 // Templated
	      .s1_wready		(uart_wready),		 // Templated
	      .s1_bresp			(uart_bresp[`AXI_RESP_BUS]), // Templated
	      .s1_bvalid		(uart_bvalid));		 // Templated


/*sram AUTO_TEMPLATE (
    .araddr(sram_araddr[]),
    .arvalid(sram_arvalid),
    .arready(sram_arready),
    .rdata(sram_rdata[]),
    .rresp(sram_rresp[]),
    .rvalid(sram_rvalid),
    .rready(sram_rready),
    .awaddr(sram_awaddr[`AXI_ADDR_BUS]),
    .awvalid(sram_awvalid),
    .awready(sram_awready),
    .wdata(sram_wdata[`AXI_DATA_BUS]),
    .wstrb(sram_wstrb[`AXI_WSTRB_BUS]),
    .wvalid(sram_wvalid),
    .wready(sram_wready),
    .bresp(sram_bresp[`AXI_RESP_BUS]),
    .bvalid(sram_bvalid),
    .bready(sram_bready),
);
*/
sram sram_u0 (/*AUTOINST*/
	      // Outputs
	      .arready			(sram_arready),		 // Templated
	      .rdata			(sram_rdata[`AXI_DATA_BUS]), // Templated
	      .rresp			(sram_rresp[`AXI_RESP_BUS]), // Templated
	      .rvalid			(sram_rvalid),		 // Templated
	      .awready			(sram_awready),		 // Templated
	      .wready			(sram_wready),		 // Templated
	      .bresp			(sram_bresp[`AXI_RESP_BUS]), // Templated
	      .bvalid			(sram_bvalid),		 // Templated
	      // Inputs
	      .clk			(clk),
	      .rst_n			(rst_n),
	      .araddr			(sram_araddr[`AXI_ADDR_BUS]), // Templated
	      .arvalid			(sram_arvalid),		 // Templated
	      .rready			(sram_rready),		 // Templated
	      .awaddr			(sram_awaddr[`AXI_ADDR_BUS]), // Templated
	      .awvalid			(sram_awvalid),		 // Templated
	      .wdata			(sram_wdata[`AXI_DATA_BUS]), // Templated
	      .wstrb			(sram_wstrb[`AXI_WSTRB_BUS]), // Templated
	      .wvalid			(sram_wvalid),		 // Templated
	      .bready			(sram_bready));		 // Templated

/*uart AUTO_TEMPLATE (
    .araddr(uart_araddr[`AXI_ADDR_BUS]),
    .arvalid(uart_arvalid),
    .arready(uart_arready),
    .rdata(uart_rdata[`AXI_DATA_BUS]),
    .rresp(uart_rresp[`AXI_RESP_BUS]),
    .rvalid(uart_rvalid),
    .rready(uart_rready),
    .awaddr(uart_awaddr[`AXI_ADDR_BUS]),
    .awvalid(uart_awvalid),
    .awready(uart_awready),
    .wdata(uart_wdata[`AXI_DATA_BUS]),
    .wstrb(uart_wstrb[`AXI_WSTRB_BUS]),
    .wvalid(uart_wvalid),
    .wready(uart_wready),
    .bresp(uart_bresp[`AXI_RESP_BUS]),
    .bvalid(uart_bvalid),
    .bready(uart_bready),
);
*/
uart uart_u0 (/*AUTOINST*/
	      // Outputs
	      .arready			(uart_arready),		 // Templated
	      .rdata			(uart_rdata[`AXI_DATA_BUS]), // Templated
	      .rresp			(uart_rresp[`AXI_RESP_BUS]), // Templated
	      .rvalid			(uart_rvalid),		 // Templated
	      .awready			(uart_awready),		 // Templated
	      .wready			(uart_wready),		 // Templated
	      .bresp			(uart_bresp[`AXI_RESP_BUS]), // Templated
	      .bvalid			(uart_bvalid),		 // Templated
	      // Inputs
	      .clk			(clk),
	      .rst_n			(rst_n),
	      .araddr			(uart_araddr[`AXI_ADDR_BUS]), // Templated
	      .arvalid			(uart_arvalid),		 // Templated
	      .rready			(uart_rready),		 // Templated
	      .awaddr			(uart_awaddr[`AXI_ADDR_BUS]), // Templated
	      .awvalid			(uart_awvalid),		 // Templated
	      .wdata			(uart_wdata[`AXI_DATA_BUS]), // Templated
	      .wstrb			(uart_wstrb[`AXI_WSTRB_BUS]), // Templated
	      .wvalid			(uart_wvalid),		 // Templated
	      .bready			(uart_bready));		 // Templated

endmodule
// Local Variables:
// verilog-library-directories:("." "./core" "./perip" "./bus")
// verilog-library-extensions:(".v" ".sv")
// verilog-auto-template-warn-unused: t
// verilog-auto-tieoff-declaration: "assign"
// verilog-auto-unused-ignore-regexp: "^db$"
// verilog-auto-declare-nettype: ""
// End:
