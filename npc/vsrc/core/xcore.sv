`include "../inc/defines.svh"

module xcore (
    input logic clk,
    input logic rst_n
);
    logic [`DATA_BUS] reg_rdata1;
    logic [`DATA_BUS] reg_rdata2;
    logic [`DATA_BUS] alu_src1;
    logic [`DATA_BUS] alu_src2;
    logic reg_wen;
    logic reg_wdata_sel;
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

    export "DPI-C" function dpi_that_accesses_inst;
    function bit [31:0] dpi_that_accesses_inst();
        return inst;
    endfunction

    // DPI-C: pmem_read, pmem_write
    import "DPI-C" function int dpic_pmem_read(input int raddr);
    import "DPI-C" function void dpic_pmem_write(input int waddr, input int wdata, input byte wmask);

    // ifu
    always @ (*) begin
        inst = dpic_pmem_read(pc);
    end

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
        .raddr1(inst[19:15]),
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
        .alu_src1(alu_src1),
        .alu_src2(alu_src2),
        .alu_ctrl(alu_ctrl),
        .imm_o(imm),
        .pc_adder_src2(pc_adder_src2),
        .dmem_wen(dmem_wen),
        .dmem_req(dmem_req),
        .reg_wen(reg_wen),
        .reg_wdata_sel(reg_wdata_sel)
    );

    exu exu_u0 (
        .inst(inst),
        .alu_src1(alu_src1),
        .alu_src2(alu_src2),
        .alu_ctrl(alu_ctrl),
        .imm_i(imm),
        .pc_adder_src2(pc_adder_src2),
        .alu_result(alu_result),
        .dnpc(dnpc)
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
        .reg_wdata(reg_wdata)
    );


endmodule
