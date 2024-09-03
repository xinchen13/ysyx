`include "../inc/defines.svh"

module xcore (
    input logic clk,
    input logic rst_n
);
    logic [`DATA_BUS] reg_rdata1;
    logic [`DATA_BUS] reg_rdata2;
    logic [`DATA_BUS] alu_src1;
    logic [`DATA_BUS] alu_src2;
    logic id_reg_wen;
    logic reg_wen;
    logic [1:0] reg_wdata_sel;
    logic [`DATA_BUS] reg_wdata;
    logic [`INST_ADDR_BUS] dnpc;
    logic [`INST_ADDR_BUS] fetch_pc;
    logic [`INST_ADDR_BUS] id_pc;
    logic [`INST_DATA_BUS] fetch_inst;
    logic [`INST_DATA_BUS] id_inst;
    logic [3:0] alu_ctrl;
    logic [`DATA_BUS] alu_result;
    logic [`DATA_BUS] imm;
    logic [`DATA_BUS] pc_adder_src2;
    logic dmem_wen;
    logic dmem_req;
    logic [`DATA_BUS] dmem_rdata;
    logic [`CSR_ADDR_BUS] csr_raddr;
    logic csr_wen2;
    logic [`DATA_BUS] csr_wdata1;
    logic [`CSR_ADDR_BUS] csr_waddr1;
    logic csr_wen1;
    logic [`DATA_BUS] csr_rdata;
    logic [4:0] reg_rs1;
    logic fetch_valid;
    logic dnpc_valid;
    logic fetch_ready;
    logic pc_valid;
    logic id_ready;
    logic fetch_id_valid;
    logic id_fetch_ready;
    logic fetch_ex_ready;
    logic wb_ready;

    // wb
    logic [`DATA_BUS] wb_alu_result;
    logic [1:0] wb_reg_wdata_sel;
    logic [`DATA_BUS] wb_csr_rdata;
    logic [`DATA_BUS] wb_dmem_rdata;
    logic wb_reg_wen;
    logic [`REG_ADDR_BUS] wb_reg_waddr;

    pc_reg pc_reg_u0 (
        .clk(clk),
        .rst_n(rst_n),
        .i_valid(dnpc_valid),
        .i_ready(fetch_ex_ready),
        .o_valid(pc_valid),
        .o_ready(fetch_ready),
        .dnpc(dnpc),
        .fetch_pc(fetch_pc)
    );

    fetch fetch_u0 (
        .clk(clk),
        .rst_n(rst_n),
        .pc(fetch_pc),
        .prev_valid(pc_valid),
        .this_ready(fetch_ready),
        .next_ready(id_fetch_ready),
        .inst(fetch_inst),
        .this_valid(fetch_valid)
    );

    fetch_id_pipe fetch_id_pipe_u0 (
        .clk(clk),
        .rst_n(rst_n),
        .i_valid(fetch_valid),
        .i_ready(id_fetch_ready),
        .o_valid(fetch_id_valid),
        .o_ready(id_ready),
        .fetch_pc(fetch_pc),
        .fetch_inst(fetch_inst),
        .id_pc(id_pc),
        .id_inst(id_inst)
    );


    regfile regfile_u0 (
        .clk(clk),
        .wdata(reg_wdata),
        .waddr(wb_reg_waddr),
        .raddr1(reg_rs1),
        .raddr2(id_inst[24:20]),
        .rdata1(reg_rdata1),
        .rdata2(reg_rdata2),
        .wen(reg_wen)
    );

    id id_u0 (
        .inst(id_inst),
        .pc(id_pc),
        .reg_rdata1(reg_rdata1),
        .reg_rdata2(reg_rdata2),
        .reg_rs1(reg_rs1),
        .csr_rdata(csr_rdata),
        .alu_src1(alu_src1),
        .alu_src2(alu_src2),
        .alu_ctrl(alu_ctrl),
        .imm_o(imm),
        .pc_adder_src2(pc_adder_src2),
        .dmem_wen(dmem_wen),
        .dmem_req(dmem_req),
        .reg_wen(id_reg_wen),
        .reg_wdata_sel(reg_wdata_sel),
        .csr_raddr(csr_raddr),
        .csr_wdata1(csr_wdata1),
        .csr_waddr1(csr_waddr1),
        .csr_wen1(csr_wen1),
        .csr_wen2(csr_wen2),
        .prev_valid(fetch_id_valid),
        .this_ready(id_ready),
        .next_ready(fetch_ex_ready & wb_ready),
        .this_valid(dnpc_valid)
    );

    ex ex_u0 (
        .inst(id_inst),
        .alu_src1(alu_src1),
        .alu_src2(alu_src2),
        .alu_ctrl(alu_ctrl),
        .imm_i(imm),
        .pc_adder_src2(pc_adder_src2),
        .alu_result(alu_result),
        .dnpc(dnpc),
        .csr_rdata(csr_rdata)
    );

    lsu lsu_u0 (
        .clk(clk),
        .rst_n(rst_n),
        .inst(id_inst),
        .raddr(alu_result),
        .waddr(alu_result),
        .wdata(reg_rdata2),
        .wen(dmem_wen),
        .req(dmem_req),
        .rdata(dmem_rdata)
    );

    lsu_wb_pipe lsu_wb_pipe_u0(
        .clk(clk),
        .rst_n(rst_n),
        .i_valid(fetch_id_valid),
        .i_ready(),
        .o_valid(),
        .o_ready(1'b1),
        .lsu_alu_result(alu_result),
        .lsu_reg_wdata_sel(reg_wdata_sel),
        .lsu_csr_rdata(csr_rdata),
        .lsu_dmem_rdata(dmem_rdata),
        .lsu_reg_wen(id_reg_wen),
        .lsu_reg_waddr(id_inst[11:7]),
        .wb_alu_result(wb_alu_result),
        .wb_reg_wdata_sel(wb_reg_wdata_sel),
        .wb_csr_rdata(wb_csr_rdata),
        .wb_dmem_rdata(wb_dmem_rdata),
        .wb_reg_wen(wb_reg_wen),
        .wb_reg_waddr(wb_reg_waddr)
    );

    wb wb_u0 (
        .prev_valid(dnpc_valid),
        .this_ready(wb_ready),
        .dmem_rdata(wb_dmem_rdata),
        .alu_result(wb_alu_result),
        .reg_wdata_sel(wb_reg_wdata_sel),
        .csr_rdata(wb_csr_rdata),
        .reg_wdata(reg_wdata),
        .wb_reg_wen(wb_reg_wen),
        .reg_wen(reg_wen)
    );

    csr_regs csr_regs_u0 (
        .clk(clk),
        .rst_n(rst_n),
        .raddr(csr_raddr),
        .waddr1(csr_waddr1),
        .wdata1(csr_wdata1),
        .wen1(csr_wen1),
        .waddr2(`CSR_MEPC),
        .wdata2(id_pc),
        .wen2(csr_wen2),
        .rdata(csr_rdata)
    );

endmodule
