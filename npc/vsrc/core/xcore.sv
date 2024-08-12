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
    logic reg_wen;
    logic [`DATA_BUS] reg_wdata;

    logic ebreak;
    assign ebreak = (inst == `INST_EBREAK) ? 1'b1 : 1'b0; 

    export "DPI-C" function dpi_that_accesses_ebreak;
    function bit dpi_that_accesses_ebreak();
        return ebreak;
    endfunction


    pc_reg pc_reg_u0 (
        .clk(clk),
        .rst_n(rst_n),
        .pc_old(pc),
        .pc_new(pc)
    );

    regfile regfile_u0(
        .clk(clk),
        .wdata(reg_wdata),
        .waddr(inst[11:7]),
        .raddr1(inst[19:15]),
        .raddr2(),
        .rdata1(reg_rdata1),
        .rdata2(),
        .wen(reg_wen)
    );

    idu idu_u0 (
        .inst(inst),
        .reg_rdata1(reg_rdata1),
        .src1(src1),
        .src2(src2),
        .reg_wen(reg_wen)
    );

    exu exu_u0 (
        .src1(src1),
        .src2(src2),
        .reg_wdata(reg_wdata)
    );

endmodule