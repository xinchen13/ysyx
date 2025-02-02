`include "../inc/defines.svh"

module ex (
    input logic clk,
    input logic rst_n,
    input logic [`INST_DATA_BUS] inst,
    input logic [`DATA_BUS] alu_src1,
    input logic [`DATA_BUS] alu_src2,
    input logic [3:0] alu_ctrl,
    input logic [`DATA_BUS] imm_i,
    input logic [`DATA_BUS] pc_adder_src2,
    input logic [`DATA_BUS] csr_rdata,
    input logic fence_i_req,
    output logic icache_flush,
    output logic [`DATA_BUS] alu_result,
    output logic [`INST_ADDR_BUS] dnpc,
    input logic prev_valid,
    output logic this_ready,
    input logic next_ready,
    output logic this_valid
);
    logic [`DATA_BUS] pc_adder_src1;
    logic zero_flag;
    logic less_flag;
    logic [6:0] opcode = inst[6:0];
    logic [2:0] funct3 = inst[14:12];
    logic [`INST_ADDR_BUS] dnpc_tmp;

    logic inst_ecall = (inst == `INST_ECALL) ? 1'b1 : 1'b0;
    logic inst_mret = (inst == `INST_MRET) ? 1'b1 : 1'b0;

    logic fence_i_req_dly;
    always @ (posedge clk) begin
        if (!rst_n) begin
            fence_i_req_dly <= 'b0;
        end
        else begin
            fence_i_req_dly <= fence_i_req;
        end
    end
    assign icache_flush = fence_i_req & (!fence_i_req_dly);

    // done
    wire done = 1'b1;
    assign this_ready = !prev_valid || (done && next_ready);
    assign this_valid = prev_valid & done;
    

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
    assign dnpc_tmp = pc_adder_src1 + pc_adder_src2;
    assign dnpc = (inst_ecall || inst_mret) ? csr_rdata : dnpc_tmp;


    alu alu_u0 (
        .a(alu_src1),
        .b(alu_src2),
        .ctrl(alu_ctrl),
        .result(alu_result),
        .zero_flag(zero_flag),
        .less_flag(less_flag)
    );


endmodule
