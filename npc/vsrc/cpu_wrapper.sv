`include "../inc/defines.svh"

// core, axim, clint
module cpu_wrapper (
    input logic clock,
    input logic reset,
    input logic io_interrupt,

    // master: aw
    input   logic           io_master_awready,
    output  logic           io_master_awvalid,
    output  logic   [31:0]  io_master_awaddr,
    output  logic   [3:0]   io_master_awid,
    output  logic   [7:0]   io_master_awlen,
    output  logic   [2:0]   io_master_awsize,
    output  logic   [1:0]   io_master_awburst,
    // master: w
    input   logic           io_master_wready,
    output  logic           io_master_wvalid,
    output  logic   [31:0]  io_master_wdata,
    output  logic   [3:0]   io_master_wstrb,
    output  logic           io_master_wlast,
    // master: b 
    output  logic           io_master_bready,
    input   logic           io_master_bvalid,
    input   logic   [1:0]   io_master_bresp,
    input   logic   [3:0]   io_master_bid,
    // master: ar
    input   logic           io_master_arready,
    output  logic           io_master_arvalid,
    output	logic   [31:0]	io_master_araddr,
    output	logic   [3:0]	io_master_arid,
    output	logic   [7:0]	io_master_arlen,
    output	logic   [2:0]	io_master_arsize,
    output	logic   [1:0]	io_master_arburst,
    // master: r
    output	logic   	    io_master_rready,
    input	logic   	    io_master_rvalid,
    input	logic   [1:0]	io_master_rresp,
    input	logic   [31:0]	io_master_rdata,
    input	logic   	    io_master_rlast,
    input	logic   [3:0]	io_master_rid,

    // slave
    output	logic   	    io_slave_awready,
    input	logic   	    io_slave_awvalid,
    input	logic   [31:0]	io_slave_awaddr,
    input	logic   [3:0]	io_slave_awid,
    input	logic   [7:0]	io_slave_awlen,
    input	logic   [2:0]	io_slave_awsize,
    input	logic   [1:0]	io_slave_awburst,
    output	logic   	    io_slave_wready,
    input	logic   	    io_slave_wvalid,
    input	logic   [31:0]	io_slave_wdata,
    input	logic   [3:0]	io_slave_wstrb,
    input	logic   	    io_slave_wlast,
    input	logic   	    io_slave_bready,
    output	logic   	    io_slave_bvalid,
    output	logic   [1:0]	io_slave_bresp,
    output	logic   [3:0]	io_slave_bid,
    output	logic   	    io_slave_arready,
    input	logic   	    io_slave_arvalid,
    input	logic   [31:0]	io_slave_araddr,
    input	logic   [3:0]	io_slave_arid,
    input	logic   [7:0]	io_slave_arlen,
    input	logic   [2:0]	io_slave_arsize,
    input	logic   [1:0]	io_slave_arburst,
    input	logic   	    io_slave_rready,
    output	logic   	    io_slave_rvalid,
    output	logic   [1:0]	io_slave_rresp,
    output	logic   [31:0]	io_slave_rdata,
    output	logic   	    io_slave_rlast,
    output	logic   [3:0]	io_slave_rid
);

/*AUTOWIRE*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)
logic [`AXI_ADDR_BUS]	fetch_araddr;		// From xcore_u0 of xcore.v
wire			fetch_arready;		// From axixbar_u0 of axixbar.v
logic			fetch_arvalid;		// From xcore_u0 of xcore.v
wire [`AXI_DATA_BUS]	fetch_rdata;		// From axixbar_u0 of axixbar.v
logic			fetch_rready;		// From xcore_u0 of xcore.v
wire [`AXI_RESP_BUS]	fetch_rresp;		// From axixbar_u0 of axixbar.v
wire			fetch_rvalid;		// From axixbar_u0 of axixbar.v
logic [`AXI_ADDR_BUS]	lsu_araddr;		// From xcore_u0 of xcore.v
wire			lsu_arready;		// From axixbar_u0 of axixbar.v
logic			lsu_arvalid;		// From xcore_u0 of xcore.v
logic [`AXI_ADDR_BUS]	lsu_awaddr;		// From xcore_u0 of xcore.v
wire			lsu_awready;		// From axixbar_u0 of axixbar.v
logic			lsu_awvalid;		// From xcore_u0 of xcore.v
logic			lsu_bready;		// From xcore_u0 of xcore.v
wire [`AXI_RESP_BUS]	lsu_bresp;		// From axixbar_u0 of axixbar.v
wire			lsu_bvalid;		// From axixbar_u0 of axixbar.v
wire [`AXI_DATA_BUS]	lsu_rdata;		// From axixbar_u0 of axixbar.v
logic			lsu_rready;		// From xcore_u0 of xcore.v
wire [`AXI_RESP_BUS]	lsu_rresp;		// From axixbar_u0 of axixbar.v
wire			lsu_rvalid;		// From axixbar_u0 of axixbar.v
logic [`AXI_DATA_BUS]	lsu_wdata;		// From xcore_u0 of xcore.v
wire			lsu_wready;		// From axixbar_u0 of axixbar.v
logic [`AXI_WSTRB_BUS]	lsu_wstrb;		// From xcore_u0 of xcore.v
logic			lsu_wvalid;		// From xcore_u0 of xcore.v
// End of automatics

localparam integer C_AXI_DATA_WIDTH = `AXI_DATA_WIDTH;
localparam integer C_AXI_ADDR_WIDTH = `AXI_ADDR_WIDTH;
localparam integer C_AXI_ID_WIDTH   = `AXI_ID_WIDTH;
localparam  NM  = 2;
localparam  NS  = 1;
localparam  IDW = C_AXI_ID_WIDTH;
localparam	AW  = C_AXI_ADDR_WIDTH;
localparam	DW  = C_AXI_DATA_WIDTH;

// unused 
assign io_slave_awready     = 'b0;
assign io_slave_wready      = 'b0;
assign io_slave_bvalid      = 'b0;
assign io_slave_bresp       = 'b0;
assign io_slave_bid         = 'b0;
assign io_slave_arready     = 'b0;
assign io_slave_rvalid      = 'b0;
assign io_slave_rresp       = 'b0;
assign io_slave_rdata       = 'b0;
assign io_slave_rlast       = 'b0;
assign io_slave_rid         = 'b0;

/*xcore AUTO_TEMPLATE (
    .clk(clock),
    .rst_n(reset),
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
		.clk			(clock),		 // Templated
		.rst_n			(reset),		 // Templated
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
/*axixbar AUTO_TEMPLATE (
    .S_AXI_ACLK(clock),
    .S_AXI_ARESETN(reset),

    // Core
    .S_AXI_AWADDR   ({32'b0,                lsu_awaddr[`AXI_ADDR_BUS]}),
    .S_AXI_AWID     ({4'b0,                 4'b0}),
    .S_AXI_AWVALID  ({1'b0, 		        lsu_awvalid}),
    .S_AXI_AWREADY  ({                      lsu_awready}),
    .S_AXI_AWLEN    ({8'b0, 	            8'b0}),
    .S_AXI_AWSIZE   ({3'b0,                 3'b010}),
    .S_AXI_AWBURST  ({2'b01,                2'b01}),
    .S_AXI_AWLOCK   ({1'b0, 	            1'b0}),
    .S_AXI_AWCACHE  ({4'b0, 	            4'b0}),
    .S_AXI_AWPROT   ({3'b0, 	            3'b0}),
    .S_AXI_AWQOS    ({4'b0, 	            4'b0}),

    .S_AXI_WDATA    ({32'b0,			    lsu_wdata[`AXI_DATA_BUS]}),
    .S_AXI_WSTRB    ({4'b0,			        lsu_wstrb[`AXI_WSTRB_BUS]}),
    .S_AXI_WVALID   ({1'b0, 			    lsu_wvalid}),
    .S_AXI_WREADY   ({ 	     			    lsu_wready}),
    .S_AXI_WLAST    ({1'b0,                 1'b0}),

    .S_AXI_BRESP    ({ 		    			lsu_bresp[`AXI_RESP_BUS]}),
    .S_AXI_BVALID   ({ 	    	 		    lsu_bvalid}),
    .S_AXI_BREADY   ({1'b0, 			    lsu_bready}),
    .S_AXI_BID      (),

    .S_AXI_ARADDR   ({fetch_araddr[`AXI_ADDR_BUS], 			lsu_araddr[`AXI_ADDR_BUS]}),
    .S_AXI_ARID     ({4'b0,                                 4'b0}),
    .S_AXI_ARVALID  ({fetch_arvalid,                        lsu_arvalid}),
    .S_AXI_ARREADY  ({fetch_arready,                        lsu_arready}),
    .S_AXI_ARLEN    ({8'b0, 	                            8'b0}),
    .S_AXI_ARSIZE   ({3'b0,                                 3'b0}),
    .S_AXI_ARBURST  ({2'b01,                                2'b0}),
    .S_AXI_ARLOCK   ({1'b0, 	                            1'b0}),
    .S_AXI_ARCACHE  ({4'b0, 	                            4'b0}),
    .S_AXI_ARPROT   ({3'b0, 	                            3'b0}),
    .S_AXI_ARQOS    ({4'b0, 	                            4'b0}),

    .S_AXI_RDATA    ({fetch_rdata[`AXI_DATA_BUS], 			lsu_rdata[`AXI_DATA_BUS] }),
    .S_AXI_RRESP    ({fetch_rresp[`AXI_RESP_BUS], 			lsu_rresp[`AXI_RESP_BUS] }),
    .S_AXI_RVALID   ({fetch_rvalid, 			            lsu_rvalid }),
    .S_AXI_RREADY   ({fetch_rready, 			            lsu_rready }),
    .S_AXI_RID      (),
    .S_AXI_RLAST    (),

    // Devices
    .M_AXI_AWADDR   ({io_master_awaddr}),
    .M_AXI_AWID     ({io_master_awid}),
    .M_AXI_AWVALID  ({io_master_awvalid}),
    .M_AXI_AWREADY  ({io_master_awready}),
    .M_AXI_AWLEN    ({io_master_awlen}),
    .M_AXI_AWSIZE   ({io_master_awsize}),
    .M_AXI_AWBURST  ({io_master_awburst}),
    .M_AXI_AWLOCK   (),
    .M_AXI_AWCACHE  (),
    .M_AXI_AWPROT   (),
    .M_AXI_AWQOS    (),

    .M_AXI_WDATA    ({io_master_wdata}),
    .M_AXI_WSTRB    ({io_master_wstrb}),
    .M_AXI_WVALID   ({io_master_wvalid}),
    .M_AXI_WREADY   ({io_master_wready}),
    .M_AXI_WLAST    ({io_master_wlast}),

    .M_AXI_BRESP    ({io_master_bresp}),
    .M_AXI_BVALID   ({io_master_bvalid}),
    .M_AXI_BREADY   ({io_master_bready}),
    .M_AXI_BID      ({io_master_bid}),

    .M_AXI_ARADDR   ({io_master_araddr}),
    .M_AXI_ARID     ({io_master_arid  }),
    .M_AXI_ARVALID  ({io_master_arvalid}),
    .M_AXI_ARREADY  ({io_master_arready}),
    .M_AXI_ARLEN    ({io_master_arlen }),
    .M_AXI_ARSIZE   ({io_master_arsize}),
    .M_AXI_ARBURST  ({io_master_arburst}),
    .M_AXI_ARLOCK   (),
    .M_AXI_ARCACHE  (),
    .M_AXI_ARPROT   (),
    .M_AXI_ARQOS    (),

    .M_AXI_RDATA    ({io_master_rdata}),
    .M_AXI_RRESP    ({io_master_rresp}),
    .M_AXI_RVALID   ({io_master_rvalid}),
    .M_AXI_RREADY   ({io_master_rready}),
    .M_AXI_RID      ({io_master_rid}),
    .M_AXI_RLAST    ({io_master_rlast}),
);
*/
axixbar #(
    .C_AXI_DATA_WIDTH(DW),
    .C_AXI_ADDR_WIDTH(AW),
    .C_AXI_ID_WIDTH(IDW),
    .NM(NM),
    .NS(NS),
    .SLAVE_ADDR({
		32'h0
    }),
    .SLAVE_MASK({
        {(1){ 32'h0 }}
    }),
    .OPT_LOWPOWER(1'b0),
    .OPT_LINGER(4),
    .LGMAXBURST(4)
) axixbar_u0 (/*AUTOINST*/
	      // Outputs
	      .S_AXI_AWREADY		({                      lsu_awready}), // Templated
	      .S_AXI_WREADY		({ 	     			    lsu_wready}), // Templated
	      .S_AXI_BVALID		({ 	    	 		    lsu_bvalid}), // Templated
	      .S_AXI_BID		(),			 // Templated
	      .S_AXI_BRESP		({ 		    			lsu_bresp[`AXI_RESP_BUS]}), // Templated
	      .S_AXI_ARREADY		({fetch_arready,                        lsu_arready}), // Templated
	      .S_AXI_RVALID		({fetch_rvalid, 			            lsu_rvalid }), // Templated
	      .S_AXI_RID		(),			 // Templated
	      .S_AXI_RDATA		({fetch_rdata[`AXI_DATA_BUS], 			lsu_rdata[`AXI_DATA_BUS] }), // Templated
	      .S_AXI_RRESP		({fetch_rresp[`AXI_RESP_BUS], 			lsu_rresp[`AXI_RESP_BUS] }), // Templated
	      .S_AXI_RLAST		(),			 // Templated
	      .M_AXI_AWVALID		({io_master_awvalid}),	 // Templated
	      .M_AXI_AWID		({io_master_awid}),	 // Templated
	      .M_AXI_AWADDR		({io_master_awaddr}),	 // Templated
	      .M_AXI_AWLEN		({io_master_awlen}),	 // Templated
	      .M_AXI_AWSIZE		({io_master_awsize}),	 // Templated
	      .M_AXI_AWBURST		({io_master_awburst}),	 // Templated
	      .M_AXI_AWLOCK		(),			 // Templated
	      .M_AXI_AWCACHE		(),			 // Templated
	      .M_AXI_AWPROT		(),			 // Templated
	      .M_AXI_AWQOS		(),			 // Templated
	      .M_AXI_WVALID		({io_master_wvalid}),	 // Templated
	      .M_AXI_WDATA		({io_master_wdata}),	 // Templated
	      .M_AXI_WSTRB		({io_master_wstrb}),	 // Templated
	      .M_AXI_WLAST		({io_master_wlast}),	 // Templated
	      .M_AXI_BREADY		({io_master_bready}),	 // Templated
	      .M_AXI_ARVALID		({io_master_arvalid}),	 // Templated
	      .M_AXI_ARID		({io_master_arid  }),	 // Templated
	      .M_AXI_ARADDR		({io_master_araddr}),	 // Templated
	      .M_AXI_ARLEN		({io_master_arlen }),	 // Templated
	      .M_AXI_ARSIZE		({io_master_arsize}),	 // Templated
	      .M_AXI_ARBURST		({io_master_arburst}),	 // Templated
	      .M_AXI_ARLOCK		(),			 // Templated
	      .M_AXI_ARCACHE		(),			 // Templated
	      .M_AXI_ARQOS		(),			 // Templated
	      .M_AXI_ARPROT		(),			 // Templated
	      .M_AXI_RREADY		({io_master_rready}),	 // Templated
	      // Inputs
	      .S_AXI_ACLK		(clock),		 // Templated
	      .S_AXI_ARESETN		(reset),		 // Templated
	      .S_AXI_AWVALID		({1'b0, 		        lsu_awvalid}), // Templated
	      .S_AXI_AWID		({4'b0,                 4'b0}), // Templated
	      .S_AXI_AWADDR		({32'b0,                lsu_awaddr[`AXI_ADDR_BUS]}), // Templated
	      .S_AXI_AWLEN		({8'b0, 	            8'b0}), // Templated
	      .S_AXI_AWSIZE		({3'b0,                 3'b010}), // Templated
	      .S_AXI_AWBURST		({2'b01,                2'b01}), // Templated
	      .S_AXI_AWLOCK		({1'b0, 	            1'b0}), // Templated
	      .S_AXI_AWCACHE		({4'b0, 	            4'b0}), // Templated
	      .S_AXI_AWPROT		({3'b0, 	            3'b0}), // Templated
	      .S_AXI_AWQOS		({4'b0, 	            4'b0}), // Templated
	      .S_AXI_WVALID		({1'b0, 			    lsu_wvalid}), // Templated
	      .S_AXI_WDATA		({32'b0,			    lsu_wdata[`AXI_DATA_BUS]}), // Templated
	      .S_AXI_WSTRB		({4'b0,			        lsu_wstrb[`AXI_WSTRB_BUS]}), // Templated
	      .S_AXI_WLAST		({1'b0,                 1'b0}), // Templated
	      .S_AXI_BREADY		({1'b0, 			    lsu_bready}), // Templated
	      .S_AXI_ARVALID		({fetch_arvalid,                        lsu_arvalid}), // Templated
	      .S_AXI_ARID		({4'b0,                                 4'b0}), // Templated
	      .S_AXI_ARADDR		({fetch_araddr[`AXI_ADDR_BUS], 			lsu_araddr[`AXI_ADDR_BUS]}), // Templated
	      .S_AXI_ARLEN		({8'b0, 	                            8'b0}), // Templated
	      .S_AXI_ARSIZE		({3'b0,                                 3'b0}), // Templated
	      .S_AXI_ARBURST		({2'b01,                                2'b0}), // Templated
	      .S_AXI_ARLOCK		({1'b0, 	                            1'b0}), // Templated
	      .S_AXI_ARCACHE		({4'b0, 	                            4'b0}), // Templated
	      .S_AXI_ARPROT		({3'b0, 	                            3'b0}), // Templated
	      .S_AXI_ARQOS		({4'b0, 	                            4'b0}), // Templated
	      .S_AXI_RREADY		({fetch_rready, 			            lsu_rready }), // Templated
	      .M_AXI_AWREADY		({io_master_awready}),	 // Templated
	      .M_AXI_WREADY		({io_master_wready}),	 // Templated
	      .M_AXI_BVALID		({io_master_bvalid}),	 // Templated
	      .M_AXI_BID		({io_master_bid}),	 // Templated
	      .M_AXI_BRESP		({io_master_bresp}),	 // Templated
	      .M_AXI_ARREADY		({io_master_arready}),	 // Templated
	      .M_AXI_RVALID		({io_master_rvalid}),	 // Templated
	      .M_AXI_RID		({io_master_rid}),	 // Templated
	      .M_AXI_RDATA		({io_master_rdata}),	 // Templated
	      .M_AXI_RRESP		({io_master_rresp}),	 // Templated
	      .M_AXI_RLAST		({io_master_rlast}));	 // Templated


endmodule
// Local Variables:
// verilog-library-directories:("." "./core" "./bus")
// verilog-library-extensions:(".v" ".sv")
// verilog-auto-template-warn-unused: t
// verilog-auto-tieoff-declaration: "assign"
// verilog-auto-unused-ignore-regexp: "^db$"
// verilog-auto-declare-nettype: ""
// End:
