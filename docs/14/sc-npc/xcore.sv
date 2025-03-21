`include "defines.svh"

module xcore (
    input logic clk,
    input logic rst_n,
    output logic [`DATA_BUS] reg_wdata_out
);
    logic [`DATA_BUS] reg_rdata1;
    logic [`DATA_BUS] reg_rdata2;
    logic [`DATA_BUS] alu_src1;
    logic [`DATA_BUS] alu_src2;
    logic reg_wen;
    logic [1:0] reg_wdata_sel;
    logic [`DATA_BUS] reg_wdata;
    logic [`INST_ADDR_BUS] dnpc;
    logic [`INST_ADDR_BUS] pc;
    logic [`INST_DATA_BUS] inst;
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

    assign reg_wdata_out = reg_wdata;


    rom rom_u0 (
        .raddr(pc[7:0]),
        .rdata(inst)
    );

    pc_reg pc_reg_u0 (
        .clk(clk),
        .rst_n(rst_n),
        .dnpc(dnpc),
        .pc(pc)
    );

    regfile regfile_u0 (
        .clk(clk),
        .wdata(reg_wdata),
        .waddr(inst[11:7]),
        .raddr1(reg_rs1),
        .raddr2(inst[24:20]),
        .rdata1(reg_rdata1),
        .rdata2(reg_rdata2),
        .wen(reg_wen)
    );

    idu idu_u0 (
        .inst(inst),
        .pc(pc),
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
        .reg_wen(reg_wen),
        .reg_wdata_sel(reg_wdata_sel),
        .csr_raddr(csr_raddr),
        .csr_wdata1(csr_wdata1),
        .csr_waddr1(csr_waddr1),
        .csr_wen1(csr_wen1),
        .csr_wen2(csr_wen2)
    );

    exu exu_u0 (
        .inst(inst),
        .alu_src1(alu_src1),
        .alu_src2(alu_src2),
        .alu_ctrl(alu_ctrl),
        .imm_i(imm),
        .pc_adder_src2(pc_adder_src2),
        .alu_result(alu_result),
        .dnpc(dnpc),
        .csr_rdata(csr_rdata)
    );

    mem mem_u0 (
        .inst(inst),
        .raddr(alu_result),
        .waddr(alu_result),
        .wdata(reg_rdata2),
        .wen(dmem_wen),
        .req(dmem_req),
        .rdata(dmem_rdata)
    );

    wb wb_u0 (
        .dmem_rdata(dmem_rdata),
        .alu_result(alu_result),
        .reg_wdata_sel(reg_wdata_sel),
        .csr_rdata(csr_rdata),
        .reg_wdata(reg_wdata)
    );

    csr_regs csr_regs_u0 (
        .clk(clk),
        .rst_n(rst_n),
        .raddr(csr_raddr),
        .waddr1(csr_waddr1),
        .wdata1(csr_wdata1),
        .wen1(csr_wen1),
        .waddr2(`CSR_MEPC),
        .wdata2(pc),
        .wen2(csr_wen2),
        .rdata(csr_rdata)
    );

endmodule
