`include "../inc/defines.svh"

module soc_top (
    /*AUTOINPUT*/
    /*AUTOOUTPUT*/
    input logic clk,
    input logic rst_n
);

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
wire [`AXI_ADDR_BUS]	clint_araddr;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
logic			clint_arready;		// From clint_u0 of clint.v
wire			clint_arvalid;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
wire [`AXI_ADDR_BUS]	clint_awaddr;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
logic			clint_awready;		// From clint_u0 of clint.v
wire			clint_awvalid;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
wire			clint_bready;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
logic [`AXI_RESP_BUS]	clint_bresp;		// From clint_u0 of clint.v
logic			clint_bvalid;		// From clint_u0 of clint.v
logic [`AXI_DATA_BUS]	clint_rdata;		// From clint_u0 of clint.v
wire			clint_rready;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
logic [`AXI_RESP_BUS]	clint_rresp;		// From clint_u0 of clint.v
logic			clint_rvalid;		// From clint_u0 of clint.v
wire [`AXI_DATA_BUS]	clint_wdata;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
logic			clint_wready;		// From clint_u0 of clint.v
wire [`AXI_WSTRB_BUS]	clint_wstrb;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
wire			clint_wvalid;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
logic [`AXI_ADDR_BUS]	fetch_araddr;		// From xcore_u0 of xcore.v
wire			fetch_arready;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
logic			fetch_arvalid;		// From xcore_u0 of xcore.v
wire [`AXI_DATA_BUS]	fetch_rdata;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
logic			fetch_rready;		// From xcore_u0 of xcore.v
wire [`AXI_RESP_BUS]	fetch_rresp;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
wire			fetch_rvalid;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
logic [`AXI_ADDR_BUS]	lsu_araddr;		// From xcore_u0 of xcore.v
wire			lsu_arready;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
logic			lsu_arvalid;		// From xcore_u0 of xcore.v
logic [`AXI_ADDR_BUS]	lsu_awaddr;		// From xcore_u0 of xcore.v
wire			lsu_awready;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
logic			lsu_awvalid;		// From xcore_u0 of xcore.v
logic			lsu_bready;		// From xcore_u0 of xcore.v
wire [`AXI_RESP_BUS]	lsu_bresp;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
wire			lsu_bvalid;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
wire [`AXI_DATA_BUS]	lsu_rdata;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
logic			lsu_rready;		// From xcore_u0 of xcore.v
wire [`AXI_RESP_BUS]	lsu_rresp;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
wire			lsu_rvalid;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
logic [`AXI_DATA_BUS]	lsu_wdata;		// From xcore_u0 of xcore.v
wire			lsu_wready;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
logic [`AXI_WSTRB_BUS]	lsu_wstrb;		// From xcore_u0 of xcore.v
logic			lsu_wvalid;		// From xcore_u0 of xcore.v
wire [`AXI_ADDR_BUS]	sram_araddr;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
logic			sram_arready;		// From sram_u0 of sram.v
wire			sram_arvalid;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
wire [`AXI_ADDR_BUS]	sram_awaddr;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
logic			sram_awready;		// From sram_u0 of sram.v
wire			sram_awvalid;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
wire			sram_bready;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
logic [`AXI_RESP_BUS]	sram_bresp;		// From sram_u0 of sram.v
logic			sram_bvalid;		// From sram_u0 of sram.v
logic [`AXI_DATA_BUS]	sram_rdata;		// From sram_u0 of sram.v
wire			sram_rready;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
logic [`AXI_RESP_BUS]	sram_rresp;		// From sram_u0 of sram.v
logic			sram_rvalid;		// From sram_u0 of sram.v
wire [`AXI_DATA_BUS]	sram_wdata;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
logic			sram_wready;		// From sram_u0 of sram.v
wire [`AXI_WSTRB_BUS]	sram_wstrb;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
wire			sram_wvalid;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
wire [`AXI_ADDR_BUS]	uart_araddr;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
logic			uart_arready;		// From uart_u0 of uart.v
wire			uart_arvalid;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
wire [`AXI_ADDR_BUS]	uart_awaddr;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
logic			uart_awready;		// From uart_u0 of uart.v
wire			uart_awvalid;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
wire			uart_bready;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
logic [`AXI_RESP_BUS]	uart_bresp;		// From uart_u0 of uart.v
logic			uart_bvalid;		// From uart_u0 of uart.v
logic [`AXI_DATA_BUS]	uart_rdata;		// From uart_u0 of uart.v
wire			uart_rready;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
logic [`AXI_RESP_BUS]	uart_rresp;		// From uart_u0 of uart.v
logic			uart_rvalid;		// From uart_u0 of uart.v
wire [`AXI_DATA_BUS]	uart_wdata;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
logic			uart_wready;		// From uart_u0 of uart.v
wire [`AXI_WSTRB_BUS]	uart_wstrb;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
wire			uart_wvalid;		// From axi_lite_xbar_u0 of axi_lite_xbar.v
// End of automatics

localparam integer C_AXI_DATA_WIDTH = `AXI_DATA_WIDTH;
localparam integer C_AXI_ADDR_WIDTH = `AXI_ADDR_WIDTH;
localparam NM = 2;
localparam NS = 3;
localparam	AW = C_AXI_ADDR_WIDTH;
localparam	DW = C_AXI_DATA_WIDTH;
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


/* verilator lint_off WIDTHEXPAND */
/*axi_lite_xbar AUTO_TEMPLATE (
    .S_AXI_ACLK(clk),
    .S_AXI_ARESETN(rst_n),

    // Core
    .S_AXI_AWADDR({ 	32'b0, 			lsu_awaddr[`AXI_ADDR_BUS] }),
    .S_AXI_AWPROT({ 	3'b000,		 	3'b000 }),
    .S_AXI_AWVALID({ 	1'b0, 		lsu_awvalid }),
    .S_AXI_AWREADY({ 	     		lsu_awready }),

    .S_AXI_WDATA({ 		32'b0,			lsu_wdata[`AXI_DATA_BUS] }),
    .S_AXI_WSTRB({ 		4'b0,			lsu_wstrb[`AXI_WSTRB_BUS] }),
    .S_AXI_WVALID({ 	1'b0, 			lsu_wvalid }),
    .S_AXI_WREADY({ 	     			lsu_wready }),

    .S_AXI_BRESP({ 		    			lsu_bresp[`AXI_RESP_BUS] }),
    .S_AXI_BVALID({ 	    	 		lsu_bvalid }),
    .S_AXI_BREADY({ 	1'b0, 			lsu_bready }),

    .S_AXI_ARADDR({ 	fetch_araddr[`AXI_ADDR_BUS], 			lsu_araddr[`AXI_ADDR_BUS] }),
    .S_AXI_ARPROT({ 	3'b000, 			3'b000 }),
    .S_AXI_ARVALID({ 	fetch_arvalid, 		lsu_arvalid }),
    .S_AXI_ARREADY({ 	fetch_arready, 		lsu_arready }),

    .S_AXI_RDATA({ 		fetch_rdata[`AXI_DATA_BUS], 			lsu_rdata[`AXI_DATA_BUS] }),
    .S_AXI_RRESP({ 		fetch_rresp[`AXI_RESP_BUS], 			lsu_rresp[`AXI_RESP_BUS] }),
    .S_AXI_RVALID({ 	fetch_rvalid, 			lsu_rvalid }),
    .S_AXI_RREADY({ 	fetch_rready, 			lsu_rready }),

    // Devices
    .M_AXI_AWADDR({ clint_awaddr[`AXI_ADDR_BUS], 	uart_awaddr[`AXI_ADDR_BUS], 		sram_awaddr[`AXI_ADDR_BUS]  }),
    .M_AXI_AWPROT( ),
    .M_AXI_AWVALID({clint_awvalid,	uart_awvalid,		sram_awvalid }),
    .M_AXI_AWREADY({clint_awready,	uart_awready,		sram_awready }),

    .M_AXI_WDATA({ 	clint_wdata[`AXI_DATA_BUS], 	uart_wdata[`AXI_DATA_BUS], 		sram_wdata[`AXI_DATA_BUS]   }),
    .M_AXI_WSTRB({  clint_wstrb[`AXI_WSTRB_BUS], 	uart_wstrb[`AXI_WSTRB_BUS], 		sram_wstrb[`AXI_WSTRB_BUS]   }),
    .M_AXI_WVALID({ clint_wvalid,	uart_wvalid,		sram_wvalid  }),
    .M_AXI_WREADY({ clint_wready,	uart_wready,		sram_wready  }),

    .M_AXI_BRESP({  clint_bresp[`AXI_RESP_BUS], 	uart_bresp[`AXI_RESP_BUS], 		sram_bresp[`AXI_RESP_BUS]   }),
    .M_AXI_BVALID({ clint_bvalid,	uart_bvalid,		sram_bvalid  }),
    .M_AXI_BREADY({ clint_bready,	uart_bready,		sram_bready  }),

    .M_AXI_ARADDR({ clint_araddr[`AXI_ADDR_BUS], 	uart_araddr[`AXI_ADDR_BUS], 		sram_araddr[`AXI_ADDR_BUS]    }),
    .M_AXI_ARPROT( ),
    .M_AXI_ARVALID({clint_arvalid,	uart_arvalid,		sram_arvalid }),
    .M_AXI_ARREADY({clint_arready,	uart_arready,		sram_arready }),

    .M_AXI_RDATA({  clint_rdata[`AXI_DATA_BUS], 	uart_rdata[`AXI_DATA_BUS], 		sram_rdata[`AXI_DATA_BUS]   }),
    .M_AXI_RRESP({  clint_rresp[`AXI_RESP_BUS], 	uart_rresp[`AXI_RESP_BUS], 		sram_rresp[`AXI_RESP_BUS]   }),
    .M_AXI_RVALID({ clint_rvalid,	uart_rvalid,		sram_rvalid  }),
    .M_AXI_RREADY({ clint_rready,	uart_rready,		sram_rready  }),
);
*/
axi_lite_xbar #(
    .C_AXI_DATA_WIDTH(DW),
    .C_AXI_ADDR_WIDTH(AW),
    .NM(NM),
    .NS(NS),
    .SLAVE_ADDR({
		32'ha0000048,
		32'ha00003f8,
        4'b1000, {(32-4){1'b0}} 
    }),
    .SLAVE_MASK({ {(2){ 32'hffffffff }},
				{(1){ 4'b1111, {(28){1'b0}} }} }),
    .OPT_LOWPOWER(1'b0),
    .OPT_LINGER(4),
    .LGMAXBURST(2)
) axi_lite_xbar_u0 (/*AUTOINST*/
		    // Outputs
		    .S_AXI_AWREADY	({ 	     		lsu_awready }), // Templated
		    .S_AXI_WREADY	({ 	     			lsu_wready }), // Templated
		    .S_AXI_BVALID	({ 	    	 		lsu_bvalid }), // Templated
		    .S_AXI_BRESP	({ 		    			lsu_bresp[`AXI_RESP_BUS] }), // Templated
		    .S_AXI_ARREADY	({ 	fetch_arready, 		lsu_arready }), // Templated
		    .S_AXI_RVALID	({ 	fetch_rvalid, 			lsu_rvalid }), // Templated
		    .S_AXI_RDATA	({ 		fetch_rdata[`AXI_DATA_BUS], 			lsu_rdata[`AXI_DATA_BUS] }), // Templated
		    .S_AXI_RRESP	({ 		fetch_rresp[`AXI_RESP_BUS], 			lsu_rresp[`AXI_RESP_BUS] }), // Templated
		    .M_AXI_AWADDR	({ clint_awaddr[`AXI_ADDR_BUS], 	uart_awaddr[`AXI_ADDR_BUS], 		sram_awaddr[`AXI_ADDR_BUS]  }), // Templated
		    .M_AXI_AWPROT	( ),			 // Templated
		    .M_AXI_AWVALID	({clint_awvalid,	uart_awvalid,		sram_awvalid }), // Templated
		    .M_AXI_WDATA	({ 	clint_wdata[`AXI_DATA_BUS], 	uart_wdata[`AXI_DATA_BUS], 		sram_wdata[`AXI_DATA_BUS]   }), // Templated
		    .M_AXI_WSTRB	({  clint_wstrb[`AXI_WSTRB_BUS], 	uart_wstrb[`AXI_WSTRB_BUS], 		sram_wstrb[`AXI_WSTRB_BUS]   }), // Templated
		    .M_AXI_WVALID	({ clint_wvalid,	uart_wvalid,		sram_wvalid  }), // Templated
		    .M_AXI_BREADY	({ clint_bready,	uart_bready,		sram_bready  }), // Templated
		    .M_AXI_ARADDR	({ clint_araddr[`AXI_ADDR_BUS], 	uart_araddr[`AXI_ADDR_BUS], 		sram_araddr[`AXI_ADDR_BUS]    }), // Templated
		    .M_AXI_ARPROT	( ),			 // Templated
		    .M_AXI_ARVALID	({clint_arvalid,	uart_arvalid,		sram_arvalid }), // Templated
		    .M_AXI_RREADY	({ clint_rready,	uart_rready,		sram_rready  }), // Templated
		    // Inputs
		    .S_AXI_ACLK		(clk),			 // Templated
		    .S_AXI_ARESETN	(rst_n),		 // Templated
		    .S_AXI_AWVALID	({ 	1'b0, 		lsu_awvalid }), // Templated
		    .S_AXI_AWADDR	({ 	32'b0, 			lsu_awaddr[`AXI_ADDR_BUS] }), // Templated
		    .S_AXI_AWPROT	({ 	3'b000,		 	3'b000 }), // Templated
		    .S_AXI_WVALID	({ 	1'b0, 			lsu_wvalid }), // Templated
		    .S_AXI_WDATA	({ 		32'b0,			lsu_wdata[`AXI_DATA_BUS] }), // Templated
		    .S_AXI_WSTRB	({ 		4'b0,			lsu_wstrb[`AXI_WSTRB_BUS] }), // Templated
		    .S_AXI_BREADY	({ 	1'b0, 			lsu_bready }), // Templated
		    .S_AXI_ARVALID	({ 	fetch_arvalid, 		lsu_arvalid }), // Templated
		    .S_AXI_ARADDR	({ 	fetch_araddr[`AXI_ADDR_BUS], 			lsu_araddr[`AXI_ADDR_BUS] }), // Templated
		    .S_AXI_ARPROT	({ 	3'b000, 			3'b000 }), // Templated
		    .S_AXI_RREADY	({ 	fetch_rready, 			lsu_rready }), // Templated
		    .M_AXI_AWREADY	({clint_awready,	uart_awready,		sram_awready }), // Templated
		    .M_AXI_WREADY	({ clint_wready,	uart_wready,		sram_wready  }), // Templated
		    .M_AXI_BRESP	({  clint_bresp[`AXI_RESP_BUS], 	uart_bresp[`AXI_RESP_BUS], 		sram_bresp[`AXI_RESP_BUS]   }), // Templated
		    .M_AXI_BVALID	({ clint_bvalid,	uart_bvalid,		sram_bvalid  }), // Templated
		    .M_AXI_ARREADY	({clint_arready,	uart_arready,		sram_arready }), // Templated
		    .M_AXI_RDATA	({  clint_rdata[`AXI_DATA_BUS], 	uart_rdata[`AXI_DATA_BUS], 		sram_rdata[`AXI_DATA_BUS]   }), // Templated
		    .M_AXI_RRESP	({  clint_rresp[`AXI_RESP_BUS], 	uart_rresp[`AXI_RESP_BUS], 		sram_rresp[`AXI_RESP_BUS]   }), // Templated
		    .M_AXI_RVALID	({ clint_rvalid,	uart_rvalid,		sram_rvalid  })); // Templated



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

/*clint AUTO_TEMPLATE (
    .araddr(clint_araddr[`AXI_ADDR_BUS]),
    .arvalid(clint_arvalid),
    .arready(clint_arready),
    .rdata(clint_rdata[`AXI_DATA_BUS]),
    .rresp(clint_rresp[`AXI_RESP_BUS]),
    .rvalid(clint_rvalid),
    .rready(clint_rready),
    .awaddr(clint_awaddr[`AXI_ADDR_BUS]),
    .awvalid(clint_awvalid),
    .awready(clint_awready),
    .wdata(clint_wdata[`AXI_DATA_BUS]),
    .wstrb(clint_wstrb[`AXI_WSTRB_BUS]),
    .wvalid(clint_wvalid),
    .wready(clint_wready),
    .bresp(clint_bresp[`AXI_RESP_BUS]),
    .bvalid(clint_bvalid),
    .bready(clint_bready),
);
*/
clint clint_u0 (/*AUTOINST*/
		// Outputs
		.arready		(clint_arready),	 // Templated
		.rdata			(clint_rdata[`AXI_DATA_BUS]), // Templated
		.rresp			(clint_rresp[`AXI_RESP_BUS]), // Templated
		.rvalid			(clint_rvalid),		 // Templated
		.awready		(clint_awready),	 // Templated
		.wready			(clint_wready),		 // Templated
		.bresp			(clint_bresp[`AXI_RESP_BUS]), // Templated
		.bvalid			(clint_bvalid),		 // Templated
		// Inputs
		.clk			(clk),
		.rst_n			(rst_n),
		.araddr			(clint_araddr[`AXI_ADDR_BUS]), // Templated
		.arvalid		(clint_arvalid),	 // Templated
		.rready			(clint_rready),		 // Templated
		.awaddr			(clint_awaddr[`AXI_ADDR_BUS]), // Templated
		.awvalid		(clint_awvalid),	 // Templated
		.wdata			(clint_wdata[`AXI_DATA_BUS]), // Templated
		.wstrb			(clint_wstrb[`AXI_WSTRB_BUS]), // Templated
		.wvalid			(clint_wvalid),		 // Templated
		.bready			(clint_bready));		 // Templated

endmodule
// Local Variables:
// verilog-library-directories:("." "./core" "./perip" "./bus")
// verilog-library-extensions:(".v" ".sv")
// verilog-auto-template-warn-unused: t
// verilog-auto-tieoff-declaration: "assign"
// verilog-auto-unused-ignore-regexp: "^db$"
// verilog-auto-declare-nettype: ""
// End:
