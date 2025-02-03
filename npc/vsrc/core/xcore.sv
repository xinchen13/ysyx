`include "../inc/defines.svh"

module xcore (
    input logic clk,
    input logic rst_n,

    // axi-lite interface (fetch: master0)
    // AR
    output logic [`AXI_ADDR_BUS] fetch_araddr,
    output logic fetch_arvalid,
    input logic fetch_arready,
    // R
    input logic [`AXI_DATA_BUS] fetch_rdata,
    input logic [`AXI_RESP_BUS] fetch_rresp,
    input logic fetch_rvalid,
    output logic fetch_rready,

    // axi-lite interface (lsu: master1)
    // AR
    output logic [`AXI_ADDR_BUS] lsu_araddr,
    output logic lsu_arvalid,
    input logic lsu_arready,
    // R
    input logic [`AXI_DATA_BUS] lsu_rdata,
    input logic [`AXI_RESP_BUS] lsu_rresp,
    input logic lsu_rvalid,
    output logic lsu_rready,
    // AW
    output logic [`AXI_ADDR_BUS] lsu_awaddr,
    output logic lsu_awvalid,
    input logic lsu_awready,
    // W
    output logic [`AXI_DATA_BUS] lsu_wdata,
    output logic [`AXI_WSTRB_BUS] lsu_wstrb,
    output logic lsu_wvalid,
    input logic lsu_wready,
    // B
    input logic [`AXI_RESP_BUS] lsu_bresp,
    input logic lsu_bvalid,
    output logic lsu_bready
);

    logic reg_wen;
    logic [`DATA_BUS] reg_wdata;
    logic [`INST_ADDR_BUS] wb_dnpc;
    logic fetch_wb_ready;
    logic wb_ready;
    logic lsu_wb_valid;


    // fetch
    logic [`INST_ADDR_BUS] fetch_pc;
    logic [`INST_DATA_BUS] fetch_inst;
    logic fetch_ready;
    logic pc_valid;
    logic id_fetch_ready;
    logic fetch_valid;

    // fetch: axi-lite interface (master: fetch  -  salve: icache)
    logic [`AXI_ADDR_BUS] raw_fetch_araddr;
    logic raw_fetch_arvalid;
    logic raw_fetch_arready;
    logic [`AXI_DATA_BUS] raw_fetch_rdata;
    logic [`AXI_RESP_BUS] raw_fetch_rresp;
    logic raw_fetch_rvalid;
    logic raw_fetch_rready;

    // id
    logic [`INST_DATA_BUS]  id_inst;
    logic [`DATA_BUS]       id_csr_rdata;
    logic [`DATA_BUS]       id_alu_src1;
    logic [`DATA_BUS]       id_alu_src2;
    logic [3:0]             id_alu_ctrl;
    logic [`DATA_BUS]       id_imm;
    logic [`DATA_BUS]       id_pc_adder_src2;
    logic                   id_dmem_wen;
    logic                   id_dmem_req;
    logic                   id_reg_wen;
    logic [1:0]             id_reg_wdata_sel;
    logic [`INST_ADDR_BUS]  id_pc;
    logic                   id_fence_i_req;
    logic                   id_valid;
    logic                   ex_id_ready;
    logic                   id_ready;
    logic                   fetch_id_valid;
    logic [`DATA_BUS]       id_reg_rdata1;
    logic [`DATA_BUS]       id_reg_rdata2;
    logic [4:0]             id_reg_rs1;
    logic [`CSR_ADDR_BUS]   id_csr_raddr;
    logic                   id_csr_wen1;
    logic                   id_csr_wen2;
    logic [`DATA_BUS]       id_csr_wdata1;
    logic [`CSR_ADDR_BUS]   id_csr_waddr1;
    
    // ex
    logic [`INST_DATA_BUS]  ex_inst;
    logic [`DATA_BUS]       ex_csr_rdata;
    logic [`DATA_BUS]       ex_alu_src1;
    logic [`DATA_BUS]       ex_alu_src2;
    logic [3:0]             ex_alu_ctrl;
    logic [`DATA_BUS]       ex_imm;
    logic [`DATA_BUS]       ex_pc_adder_src2;
    logic                   ex_dmem_wen;
    logic                   ex_dmem_req;
    logic                   ex_reg_wen;
    logic [1:0]             ex_reg_wdata_sel;
    logic [`INST_ADDR_BUS]  ex_pc;
    logic [`DATA_BUS]       ex_alu_result;
    logic [`INST_ADDR_BUS]  ex_dnpc;
    logic                   ex_fence_i_req;
    logic                   ex_icache_flush;
    logic                   id_ex_valid;
    logic                   ex_ready;
    logic                   ex_valid;
    logic                   lsu_ex_ready;
    logic [`DATA_BUS]       ex_reg_rdata2;
    logic                   ex_csr_wen1;
    logic                   ex_csr_wen2;
    logic [`DATA_BUS]       ex_csr_wdata1;
    logic [`CSR_ADDR_BUS]   ex_csr_waddr1;

    // lsu
    logic                   ex_lsu_valid;
    logic                   lsu_ready;
    logic                   lsu_valid;
    logic                   wb_lsu_ready;
    logic [`DATA_BUS]       lsu_dmem_rdata;
    logic [`INST_DATA_BUS]  lsu_inst;
    logic [`DATA_BUS]       lsu_alu_result;
    logic [`DATA_BUS]       lsu_reg_rdata2;
    logic                   lsu_dmem_wen;
    logic                   lsu_dmem_req;
    logic                   lsu_reg_wen;
    logic [1:0]             lsu_reg_wdata_sel;
    logic [`DATA_BUS]       lsu_csr_rdata;

    // wb
    logic [`DATA_BUS] wb_alu_result;
    logic [1:0] wb_reg_wdata_sel;
    logic [`DATA_BUS] wb_csr_rdata;
    logic [`DATA_BUS] wb_dmem_rdata;
    logic wb_reg_wen;
    logic [`REG_ADDR_BUS] wb_reg_waddr;
    logic wb_valid;

    // to clint (mtime, slave)
    logic [`AXI_ADDR_BUS]	clint_araddr;
    logic			        clint_arready;
    logic			        clint_arvalid;
    logic [`AXI_ADDR_BUS]	clint_awaddr;
    logic			        clint_awready;
    logic			        clint_awvalid;
    logic			        clint_bready;
    logic [`AXI_RESP_BUS]	clint_bresp;
    logic			        clint_bvalid;
    logic [`AXI_DATA_BUS]	clint_rdata;
    logic			        clint_rready;
    logic [`AXI_RESP_BUS]	clint_rresp;
    logic			        clint_rvalid;
    logic [`AXI_DATA_BUS]	clint_wdata;
    logic			        clint_wready;
    logic [`AXI_WSTRB_BUS]	clint_wstrb;
    logic			        clint_wvalid;

    // from lsu (master)
    logic [`AXI_ADDR_BUS]	private_araddr;
    logic			        private_arready;
    logic			        private_arvalid;
    logic [`AXI_ADDR_BUS]	private_awaddr;
    logic			        private_awready;
    logic			        private_awvalid;
    logic			        private_bready;
    logic [`AXI_RESP_BUS]	private_bresp;
    logic			        private_bvalid;
    logic [`AXI_DATA_BUS]	private_rdata;
    logic			        private_rready;
    logic [`AXI_RESP_BUS]	private_rresp;
    logic			        private_rvalid;
    logic [`AXI_DATA_BUS]	private_wdata;
    logic			        private_wready;
    logic [`AXI_WSTRB_BUS]	private_wstrb;
    logic			        private_wvalid;
    
    pipe_regs # (
        .DATA_RESET(`CPU_RESET_ADDR),
        .DATA_WIDTH(`INST_ADDR_WIDTH),
        .VALID_RESET(1'b1)
    ) u0_pipe_pc_reg (
        .clk(clk),
        .rst_n(rst_n),
        .i_valid(wb_valid),
        .i_ready(fetch_wb_ready),
        .o_valid(pc_valid),
        .o_ready(fetch_ready),
        .i_data(wb_dnpc),
        .o_data(fetch_pc),
        .pipe_flush(1'b0)
    );

    fetch u1_fetch (
        .clk(clk),
        .rst_n(rst_n),
        .pc(fetch_pc),
        .prev_valid(pc_valid),
        .this_ready(fetch_ready),
        .next_ready(id_fetch_ready),
        .inst(fetch_inst),
        .this_valid(fetch_valid),
        .araddr(raw_fetch_araddr),
        .arvalid(raw_fetch_arvalid),
        .arready(raw_fetch_arready),
        .rdata(raw_fetch_rdata),
        .rresp(raw_fetch_rresp),
        .rvalid(raw_fetch_rvalid),
        .rready(raw_fetch_rready)
    );

    icache u2_icache (
        .clk(clk),
        .rst_n(rst_n),
        .icache_flush(ex_icache_flush),
        .raw_fetch_araddr(raw_fetch_araddr),
        .raw_fetch_arvalid(raw_fetch_arvalid),
        .raw_fetch_arready(raw_fetch_arready),
        .raw_fetch_rdata(raw_fetch_rdata),
        .raw_fetch_rresp(raw_fetch_rresp),
        .raw_fetch_rvalid(raw_fetch_rvalid),
        .raw_fetch_rready(raw_fetch_rready),
        .fetch_araddr(fetch_araddr),
        .fetch_arvalid(fetch_arvalid),
        .fetch_arready(fetch_arready),
        .fetch_rdata(fetch_rdata),
        .fetch_rresp(fetch_rresp),
        .fetch_rvalid(fetch_rvalid),
        .fetch_rready(fetch_rready)
    );

    pipe_regs # (
        .DATA_RESET(64'b0),
        .DATA_WIDTH(64),
        .VALID_RESET(1'b0)
    ) u3_pipe_fetch_id (
        .clk(clk),
        .rst_n(rst_n),
        .i_valid(fetch_valid),
        .i_ready(id_fetch_ready),
        .o_valid(fetch_id_valid),
        .o_ready(id_ready),
        .i_data({fetch_pc,  fetch_inst}),
        .o_data({id_pc,     id_inst}),
        .pipe_flush(1'b0)
    );

    regfile u4_regfile (
        .clk(clk),
        .wdata(reg_wdata),
        .waddr(wb_reg_waddr),
        .raddr1(id_reg_rs1),
        .raddr2(id_inst[24:20]),
        .rdata1(id_reg_rdata1),
        .rdata2(id_reg_rdata2),
        .wen(reg_wen)
    );

    id u5_id (
        .inst(id_inst),
        .pc(id_pc),
        .reg_rdata1(id_reg_rdata1),
        .reg_rdata2(id_reg_rdata2),
        .reg_rs1(id_reg_rs1),
        .csr_rdata(id_csr_rdata),
        .alu_src1(id_alu_src1),
        .alu_src2(id_alu_src2),
        .alu_ctrl(id_alu_ctrl),
        .imm_o(id_imm),
        .pc_adder_src2(id_pc_adder_src2),
        .dmem_wen(id_dmem_wen),
        .dmem_req(id_dmem_req),
        .reg_wen(id_reg_wen),
        .reg_wdata_sel(id_reg_wdata_sel),
        .csr_raddr(id_csr_raddr),
        .csr_wdata1(id_csr_wdata1),
        .csr_waddr1(id_csr_waddr1),
        .csr_wen1(id_csr_wen1),
        .csr_wen2(id_csr_wen2),
        .prev_valid(fetch_id_valid),
        .this_ready(id_ready),
        .next_ready(ex_id_ready),
        .this_valid(id_valid),
        .fence_i_req(id_fence_i_req)
    );

    pipe_regs # (
        .DATA_RESET(312'b0),
        .DATA_WIDTH(312),
        .VALID_RESET(1'b0)
    ) u6_pipe_id_ex (
        .clk(clk),
        .rst_n(rst_n),
        .i_valid(id_valid),
        .i_ready(ex_id_ready),
        .o_valid(id_ex_valid),
        .o_ready(ex_ready),
        .i_data({
            id_csr_rdata,
            id_alu_src1,
            id_alu_src2,
            id_alu_ctrl,
            id_imm,
            id_pc_adder_src2,
            id_dmem_wen,
            id_dmem_req,
            id_reg_wen,
            id_reg_wdata_sel,
            id_inst,
            id_fence_i_req,
            id_reg_rdata2,
            id_csr_wen1,
            id_csr_wen2,
            id_csr_wdata1,
            id_csr_waddr1,
            id_pc
        }),
        .o_data({
            ex_csr_rdata,
            ex_alu_src1,
            ex_alu_src2,
            ex_alu_ctrl,
            ex_imm,
            ex_pc_adder_src2,
            ex_dmem_wen,
            ex_dmem_req,
            ex_reg_wen,
            ex_reg_wdata_sel,
            ex_inst,
            ex_fence_i_req,
            ex_reg_rdata2,
            ex_csr_wen1,
            ex_csr_wen2,
            ex_csr_wdata1,
            ex_csr_waddr1,
            ex_pc
        }),
        .pipe_flush(1'b0)
    );

    csr_regs u7_csr_regs (
        .clk(clk),
        .rst_n(rst_n),
        .raddr(id_csr_raddr),
        .waddr1(ex_csr_waddr1),
        .wdata1(ex_csr_wdata1),
        .wen1(ex_csr_wen1),
        .waddr2(`CSR_MEPC),
        .wdata2(ex_pc),
        .wen2(ex_csr_wen2),
        .rdata(id_csr_rdata)
    );

    ex u8_ex (
        .clk(clk),
        .rst_n(rst_n),
        .inst(ex_inst),
        .alu_src1(ex_alu_src1),
        .alu_src2(ex_alu_src2),
        .alu_ctrl(ex_alu_ctrl),
        .imm_i(ex_imm),
        .pc_adder_src2(ex_pc_adder_src2),
        .alu_result(ex_alu_result),
        .dnpc(ex_dnpc),
        .csr_rdata(ex_csr_rdata),
        .fence_i_req(ex_fence_i_req),
        .icache_flush(ex_icache_flush),
        .prev_valid(id_ex_valid),
        .this_ready(ex_ready),
        .next_ready(lsu_ex_ready),
        .this_valid(ex_valid)
    );

    pipe_regs # (
        .DATA_RESET(133'b0),
        .DATA_WIDTH(133),
        .VALID_RESET(1'b0)
    ) u9_pipe_ex_lsu (
        .clk(clk),
        .rst_n(rst_n),
        .i_valid(ex_valid),
        .i_ready(lsu_ex_ready),
        .o_valid(ex_lsu_valid),
        .o_ready(lsu_ready),
        .i_data({
            ex_inst,
            ex_alu_result,
            ex_reg_rdata2,
            ex_dmem_wen,
            ex_dmem_req,
            ex_reg_wdata_sel,
            ex_csr_rdata,
            ex_reg_wen
        }),
        .o_data({
            lsu_inst,
            lsu_alu_result,
            lsu_reg_rdata2,
            lsu_dmem_wen,
            lsu_dmem_req,
            lsu_reg_wdata_sel,
            lsu_csr_rdata,
            lsu_reg_wen
        }),
        .pipe_flush(1'b0)
    );

    lsu u10_lsu (
        .clk(clk),
        .rst_n(rst_n),
        .inst(lsu_inst),
        .raddr(lsu_alu_result),
        .waddr(lsu_alu_result),
        .ex_wdata(lsu_reg_rdata2),
        .wen(lsu_dmem_wen),
        .req(lsu_dmem_req),
        .lsu_rdata(lsu_dmem_rdata),
        .prev_valid(ex_lsu_valid),
        .this_ready(lsu_ready),
        .next_ready(wb_lsu_ready),
        .this_valid(lsu_valid),
        .araddr(private_araddr),
        .arvalid(private_arvalid),
        .arready(private_arready),
        .rdata(private_rdata),
        .rresp(private_rresp),
        .rvalid(private_rvalid),
        .rready(private_rready),
        .awaddr(private_awaddr),
        .awvalid(private_awvalid),
        .awready(private_awready),
        .wdata(private_wdata),
        .wstrb(private_wstrb),
        .wvalid(private_wvalid),
        .wready(private_wready),
        .bresp(private_bresp),
        .bvalid(private_bvalid),
        .bready(private_bready)
    );

    simple_xbar u11_simple_xbar (
        .arbiter_xbar_arready	(private_arready),
        .arbiter_xbar_rdata	    (private_rdata[`AXI_DATA_BUS]),
        .arbiter_xbar_rresp	    (private_rresp[`AXI_RESP_BUS]),
        .arbiter_xbar_rvalid	(private_rvalid),
        .arbiter_xbar_awready	(private_awready),
        .arbiter_xbar_wready	(private_wready),
        .arbiter_xbar_bresp	    (private_bresp[`AXI_RESP_BUS]),
        .arbiter_xbar_bvalid	(private_bvalid),
        .s0_araddr		        (lsu_araddr[`AXI_ADDR_BUS]),
        .s0_arvalid		        (lsu_arvalid),		
        .s0_rready		        (lsu_rready),		
        .s0_awaddr		        (lsu_awaddr[`AXI_ADDR_BUS]),
        .s0_awvalid		        (lsu_awvalid),		
        .s0_wdata			    (lsu_wdata[`AXI_DATA_BUS]),
        .s0_wstrb			    (lsu_wstrb[`AXI_WSTRB_BUS]),
        .s0_wvalid		        (lsu_wvalid),		
        .s0_bready		        (lsu_bready),		
        .s1_araddr		        (clint_araddr[`AXI_ADDR_BUS]),
        .s1_arvalid		        (clint_arvalid),
        .s1_rready		        (clint_rready),
        .s1_awaddr		        (clint_awaddr[`AXI_ADDR_BUS]),
        .s1_awvalid		        (clint_awvalid),
        .s1_wdata			    (clint_wdata[`AXI_DATA_BUS]),
        .s1_wstrb			    (clint_wstrb[`AXI_WSTRB_BUS]),
        .s1_wvalid		        (clint_wvalid),
        .s1_bready		        (clint_bready),
        .clk			        (clk),
        .rst_n			        (rst_n),
        .arbiter_xbar_araddr	(private_araddr[`AXI_ADDR_BUS]),
        .arbiter_xbar_arvalid	(private_arvalid),
        .arbiter_xbar_rready	(private_rready),
        .arbiter_xbar_awaddr	(private_awaddr[`AXI_ADDR_BUS]),
        .arbiter_xbar_awvalid	(private_awvalid),
        .arbiter_xbar_wdata	    (private_wdata[`AXI_DATA_BUS]),
        .arbiter_xbar_wstrb	    (private_wstrb[`AXI_WSTRB_BUS]),
        .arbiter_xbar_wvalid	(private_wvalid),
        .arbiter_xbar_bready	(private_bready),
        .s0_arready		        (lsu_arready),		
        .s0_rdata			    (lsu_rdata[`AXI_DATA_BUS]),
        .s0_rresp			    (lsu_rresp[`AXI_RESP_BUS]),
        .s0_rvalid		        (lsu_rvalid),		
        .s0_awready		        (lsu_awready),		
        .s0_wready		        (lsu_wready),		
        .s0_bresp			    (lsu_bresp[`AXI_RESP_BUS]),
        .s0_bvalid		        (lsu_bvalid),		
        .s1_arready		        (clint_arready),
        .s1_rdata			    (clint_rdata[`AXI_DATA_BUS]),
        .s1_rresp			    (clint_rresp[`AXI_RESP_BUS]),
        .s1_rvalid		        (clint_rvalid),
        .s1_awready		        (clint_awready),
        .s1_wready		        (clint_wready),
        .s1_bresp			    (clint_bresp[`AXI_RESP_BUS]),
        .s1_bvalid		        (clint_bvalid)
    );

    axi_lite_slv_clint u12_axi_lite_slv_clint (
        .arready		(clint_arready),
        .rdata		    (clint_rdata[`AXI_DATA_BUS]),
        .rresp		    (clint_rresp[`AXI_RESP_BUS]),
        .rvalid		    (clint_rvalid),	
        .awready		(clint_awready),
        .wready		    (clint_wready),	
        .bresp		    (clint_bresp[`AXI_RESP_BUS]),
        .bvalid		    (clint_bvalid),	
        .clk			(clk),	
        .rst_n		    (rst_n),	
        .araddr		    (clint_araddr[`AXI_ADDR_BUS]),
        .arvalid		(clint_arvalid),
        .rready		    (clint_rready),	
        .awaddr		    (clint_awaddr[`AXI_ADDR_BUS]),
        .awvalid		(clint_awvalid),
        .wdata		    (clint_wdata[`AXI_DATA_BUS]),
        .wstrb		    (clint_wstrb[`AXI_WSTRB_BUS]),
        .wvalid		    (clint_wvalid),
        .bready		    (clint_bready)
    );

    lsu_wb_pipe lsu_wb_pipe_u0(
        .clk(clk),
        .rst_n(rst_n),
        .i_valid(lsu_valid),
        .i_ready(wb_lsu_ready),
        .o_valid(lsu_wb_valid),
        .o_ready(wb_ready),
        .lsu_alu_result(lsu_alu_result),
        .lsu_reg_wdata_sel(lsu_reg_wdata_sel),
        .lsu_csr_rdata(lsu_csr_rdata),
        .lsu_dmem_rdata(lsu_dmem_rdata),
        .lsu_reg_wen(lsu_reg_wen),
        .lsu_reg_waddr(lsu_inst[11:7]),
        .wb_alu_result(wb_alu_result),
        .wb_reg_wdata_sel(wb_reg_wdata_sel),
        .wb_csr_rdata(wb_csr_rdata),
        .wb_dmem_rdata(wb_dmem_rdata),
        .wb_reg_wen(wb_reg_wen),
        .wb_reg_waddr(wb_reg_waddr),
        .ex_dnpc(ex_dnpc),
        .wb_dnpc(wb_dnpc)
    );

    wb wb_u0 (
        .prev_valid(lsu_wb_valid),
        .this_ready(wb_ready),
        .next_ready(fetch_wb_ready),
        .this_valid(wb_valid),
        .dmem_rdata(wb_dmem_rdata),
        .alu_result(wb_alu_result),
        .reg_wdata_sel(wb_reg_wdata_sel),
        .csr_rdata(wb_csr_rdata),
        .reg_wdata(reg_wdata),
        .wb_reg_wen(wb_reg_wen),
        .reg_wen(reg_wen)
    );

    `ifdef PMU_ON
        pmu pmu_u0 (
            .clk(clk),
            .rst_n(rst_n),
            .fetch_rvalid(raw_fetch_rvalid),
            .fetch_rready(raw_fetch_rready),
            .fetch_arvalid(raw_fetch_arvalid),
            .fetch_arready(raw_fetch_arready),
            .fetch_rdata(raw_fetch_rdata),
            .lsu_rvalid(lsu_rvalid),
            .lsu_rready(lsu_rready),
            .ins_retire(lsu_wb_valid)
        );
    `endif

endmodule
