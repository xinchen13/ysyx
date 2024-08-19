`include "../inc/defines.svh"

module exu (
    input logic [`INST_DATA_BUS] inst,
    input logic [`DATA_BUS] alu_src1,
    input logic [`DATA_BUS] alu_src2,
    input logic [3:0] alu_ctrl,
    input logic [`DATA_BUS] imm_i,
    input logic [`DATA_BUS] pc_adder_src2,
    output logic [`DATA_BUS] alu_result,
    output logic [`INST_ADDR_BUS] dnpc
);
    logic [`DATA_BUS] pc_adder_src1;
    logic zero_flag;
    logic less_flag;
    logic [6:0] opcode = inst[6:0];
    logic [2:0] funct3 = inst[14:12];

    // pc_adder_src1
    always @ (*) begin
        case (opcode) 
            `JALR_OPCODE,`JAL_OPCODE: begin
                pc_adder_src1 = imm_i;
            end
            `B_TYPE_OPCODE: begin
                case (funct3)
                    3'b000: begin
                        pc_adder_src1 = zero_flag ? imm_i : 32'h4;
                    end
                    3'b001: begin
                        pc_adder_src1 = zero_flag ? 32'h4 : imm_i;
                    end
                    3'b100, 3'b110: begin
                        pc_adder_src1 = less_flag ? imm_i : 32'h4;
                    end
                    3'b101, 3'b111: begin
                        pc_adder_src1 = less_flag ? 32'h4 : imm_i;
                    end
                    default: begin
                        pc_adder_src1 = 32'h4;
                    end
                endcase
            end
            default: begin
                pc_adder_src1 = 32'h4;
            end
        endcase
    end

    // pc adder
    assign dnpc = pc_adder_src1 + pc_adder_src2;


    alu alu_u0 (
        .a(alu_src1),
        .b(alu_src2),
        .ctrl(alu_ctrl),
        .result(alu_result),
        .zero_flag(zero_flag),
        .less_flag(less_flag)
    );


endmodule
