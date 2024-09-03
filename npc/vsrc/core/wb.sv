`include "../inc/defines.svh"

module wb (

    input logic prev_valid,   // 上级的valid输入
    output logic this_ready,  // 本级的ready输出
    input logic wb_reg_wen,
    output logic reg_wen,
    input logic [`DATA_BUS] dmem_rdata,
    input logic [`DATA_BUS] alu_result,
    input logic [1:0] reg_wdata_sel,
    input logic [`DATA_BUS] csr_rdata,
    output logic [`DATA_BUS] reg_wdata
);

    assign reg_wdata = reg_wdata_sel[1] ? csr_rdata : (
        reg_wdata_sel[0] ? dmem_rdata : alu_result
    );

    assign this_ready = 1'b1;
    assign reg_wen = wb_reg_wen & prev_valid;

endmodule