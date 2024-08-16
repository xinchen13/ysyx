`include "../inc/defines.svh"

module xcore (
    input logic clk,
    input logic rst_n,
    input logic [`INST_DATA_BUS] inst,
    output logic [`INST_ADDR_BUS] pc
);
    logic [`DATA_BUS] reg_rdata1;
    logic [`DATA_BUS] src1;
    logic [`DATA_BUS] src2;
    logic reg_wen_id;
    logic reg_wen_ex;
    logic jump_flag_id;
    logic [`DATA_BUS] reg_wdata_ex;
    logic [`INST_ADDR_BUS] dnpc;

    logic ebreak;
    assign ebreak = (inst == `INST_EBREAK) ? 1'b1 : 1'b0; 

    export "DPI-C" function dpi_that_accesses_ebreak;
    function bit dpi_that_accesses_ebreak();
        return ebreak;
    endfunction


    pc_reg pc_reg_u0 (
        .clk(clk),
        .rst_n(rst_n),
        .dnpc(dnpc),
        .pc(pc)
    );

    regfile regfile_u0(
        .clk(clk),
        .wdata(reg_wdata_ex),
        .waddr(inst[11:7]),
        .raddr1(inst[19:15]),
        .raddr2(),
        .rdata1(reg_rdata1),
        .rdata2(),
        .wen(reg_wen_ex)
    );

    idu idu_u0 (
        .inst_id(inst),
        .pc_id(pc),
        .reg_rdata1(reg_rdata1),
        .src1(src1),
        .src2(src2),
        .jump_flag_id(jump_flag_id),
        .reg_wen_id(reg_wen_id)
    );

    exu exu_u0 (
        .pc_ex(pc),
        .reg_wen_id(reg_wen_id),
        .src1(src1),
        .src2(src2),
        .jump_flag_ex(jump_flag_id),
        .reg_wdata_ex(reg_wdata_ex),
        .reg_wen_ex(reg_wen_ex),
        .dnpc(dnpc)
    );

endmodule
