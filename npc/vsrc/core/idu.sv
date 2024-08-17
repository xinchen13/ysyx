`include "../inc/defines.svh"

module idu (
    input logic [`INST_DATA_BUS] inst_id,
    input logic [`INST_ADDR_BUS] pc_id,
    input logic [`DATA_BUS] reg_rdata1,
    output logic [`DATA_BUS] src1,
    output logic [`DATA_BUS] src2,
    output logic jump_flag_id,
    output logic reg_wen_id
);
    logic [`DATA_BUS] imm;
    logic [6:0] opcode = inst_id[6:0];

    always @ (*) begin
        case (opcode)
            `S_TYPE_OPCODE: 
                imm = {{20{inst_id[31]}}, inst_id[31:25], inst_id[11:7]};
            `B_TYPE_OPCODE: 
                imm = {{20{inst_id[31]}}, inst_id[7], inst_id[30:25], inst_id[11:8], 1'b0};
            `I_AL_TYPE_OPCODE,`I_LOAD_TYPE_OPCODE,`JALR_OPCODE: 
                imm = {{20{inst_id[31]}}, inst_id[31:20]} +2;
            `JAL_OPCODE: 
                imm = {{12{inst_id[31]}}, inst_id[19:12], inst_id[20], inst_id[30:21], 1'b0};
            `LUI_OPCODE,`AUIPC_OPCODE: 
                imm = {inst_id[31:12], 12'b0};
            default: 
                imm = `ZERO_WORD;
        endcase
    end

    logic [1:0] src1_sel;
    always @ (*) begin
        case (opcode)
            `LUI_OPCODE: 
                src1_sel = 2'b00;   // 32'h0
            `AUIPC_OPCODE, `JAL_OPCODE:
                src1_sel = 2'b01;   // pc
            `JALR_OPCODE, `I_AL_TYPE_OPCODE:
                src1_sel = 2'b10;   // reg_rdata1
            default: 
                src1_sel = 2'b00;
        endcase
    end

    // jump flag
    always @ (*) begin
        case (opcode)
            `JAL_OPCODE, `JALR_OPCODE: begin
                jump_flag_id = 1'b1;     
            end
            default: begin
                jump_flag_id = 1'b0;
            end
        endcase
    end

    // regfile write enable 
    always @ (*) begin
        case (opcode) 
            `LUI_OPCODE, `AUIPC_OPCODE, `I_AL_TYPE_OPCODE,`JALR_OPCODE,
            `I_LOAD_TYPE_OPCODE, `R_TYPE_OPCODE, `JAL_OPCODE: begin
                reg_wen_id = 1'b1;
            end
            default: begin
                reg_wen_id = 1'b0;
            end
        endcase
    end

    assign src1 = src1_sel[1] ? reg_rdata1 : (src1_sel[0] ? pc_id : `ZERO_WORD);
    assign src2 = imm;

endmodule