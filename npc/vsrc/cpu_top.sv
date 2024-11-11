`include "../inc/defines.svh"

module cpu_top (
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

localparam integer C_AXI_DATA_WIDTH = `AXI_DATA_WIDTH;
localparam integer C_AXI_ADDR_WIDTH = `AXI_ADDR_WIDTH;
localparam NM = 2;
localparam NS = 3;
localparam	AW = C_AXI_ADDR_WIDTH;
localparam	DW = C_AXI_DATA_WIDTH;

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
xcore xcore_u0 (/*AUTOINST*/);


/* verilator lint_off WIDTHEXPAND */
/*axixbar AUTO_TEMPLATE (
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
axixbar #(
    .C_AXI_DATA_WIDTH(DW),
    .C_AXI_ADDR_WIDTH(AW),
    .NM(NM),
    .NS(NS),
    .SLAVE_ADDR({
		32'ha0000048,
		32'ha00003f8,
        8'b0000001000000000, {(32-16){1'b0}} 
    }),
    .SLAVE_MASK({
        {(1){ 32'hfffffff8 }},
        {(1){ 32'hffffffff }},
        {(1){ 4'b1111, {(28){1'b0}} }} 
    }),
    .OPT_LOWPOWER(1'b0),
    .OPT_LINGER(1),
    .LGMAXBURST(2)
) axixbar_u0 (/*AUTOINST*/);

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
clint clint_u0 (/*AUTOINST*/);

endmodule
// Local Variables:
// verilog-library-directories:("." "./core" "./bus")
// verilog-library-extensions:(".v" ".sv")
// verilog-auto-template-warn-unused: t
// verilog-auto-tieoff-declaration: "assign"
// verilog-auto-unused-ignore-regexp: "^db$"
// verilog-auto-declare-nettype: ""
// End:
