`include "../inc/defines.svh"

module pipe_ctrl (
    input logic [4:0]   id_rs1,
    input logic [4:0]   id_rs2,
    input logic         id_rs2_valid,
    input logic [4:0]   ex_rd,
    input logic         ex_reg_wen,
    input logic         ex_valid,
    input logic [4:0]   lsu_rd,
    input logic         lsu_reg_wen,
    input logic         lsu_valid,
    input logic [4:0]   wb_rd,
    input logic         wb_reg_wen,
    input logic         wb_valid,
    output logic        id_raw_stall
);

    logic id_ex_raw;
    logic id_lsu_raw;
    logic id_wb_raw;
    
    assign id_ex_raw    = (((id_rs1 == ex_rd)   & (id_rs1 != 5'b0) ) | ((id_rs2 == ex_rd) & id_rs2_valid & (id_rs2 != 5'b0))) & ex_reg_wen;
    assign id_lsu_raw   = (((id_rs1 == lsu_rd)  & (id_rs1 != 5'b0) ) | ((id_rs2 == lsu_rd) & id_rs2_valid & (id_rs2 != 5'b0))) & lsu_reg_wen;
    assign id_wb_raw    = (((id_rs1 == wb_rd)   & (id_rs1 != 5'b0) ) | ((id_rs2 == wb_rd) & id_rs2_valid & (id_rs2 != 5'b0))) & wb_reg_wen;

    assign id_raw_stall = (id_ex_raw & ex_valid) | (id_lsu_raw & lsu_valid) | (id_wb_raw & wb_valid);

endmodule