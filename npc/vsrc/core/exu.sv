`include "../inc/defines.svh"

module exu (
    input logic [`INST_ADDR_BUS] pc_ex,
    input logic reg_wen_id,
    input logic [`DATA_BUS] src1,
    input logic [`DATA_BUS] src2,
    input logic jump_flag_ex,
    output logic [`DATA_BUS] reg_wdata_ex,
    output logic reg_wen_ex,
    output logic [`INST_ADDR_BUS] dnpc
);
    logic [`DATA_BUS] alu_result;
    logic [`INST_ADDR_BUS] snpc;

    assign snpc = pc_ex + 32'h4;
    assign alu_result = src1 + src2;

    assign dnpc = jump_flag_ex ? alu_result : snpc;
    assign reg_wdata_ex = jump_flag_ex ? snpc : alu_result;
    assign reg_wen_ex = reg_wen_id;

endmodule
