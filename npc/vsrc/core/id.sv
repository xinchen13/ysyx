`include "../inc/defines.svh"

module id (
    // from if_id
    input logic [`INST_DATA_BUS] inst,
    input logic [`INST_ADDR_BUS] pc,
    input logic prev_valid,   // 上级的valid输入

    // to if_id
    output logic this_ready,  // 本级的ready输出

    // from pc_reg(if) (其实应该是ex, 对于双周期处理器来说没有区别)
    input logic next_ready,   // 下级的 ready 输入

    // to pc_reg
    output logic this_valid,    // 本级的 valid 输出

    // from regfile
    input logic [`DATA_BUS] reg_rdata1,
    input logic [`DATA_BUS] reg_rdata2,

    // to regfile
    output logic [4:0] reg_rs1,

    // from csr regs
    input logic [`DATA_BUS] csr_rdata,

    // to exu (mem, wb)
    output logic [`DATA_BUS] alu_src1,
    output logic [`DATA_BUS] alu_src2,
    output logic [3:0] alu_ctrl,
    output logic [`DATA_BUS] imm_o,
    output logic [`DATA_BUS] pc_adder_src2,
    output logic dmem_wen,
    output logic dmem_req,
    output logic reg_wen,
    output logic [1:0] reg_wdata_sel,
    output logic [`CSR_ADDR_BUS] csr_raddr,
    output logic [`DATA_BUS] csr_wdata1,
    output logic [`CSR_ADDR_BUS] csr_waddr1,
    output logic csr_wen1,
    output logic csr_wen2
);
    logic [`DATA_BUS] imm;
    logic [6:0] opcode = inst[6:0];
    logic [2:0] funct3 = inst[14:12];
    logic funct7_5 = inst[30];
    logic inst_ecall = (inst == `INST_ECALL) ? 1'b1 : 1'b0;
    logic inst_mret = (inst == `INST_MRET) ? 1'b1 : 1'b0;
    logic done;

    // done
    assign done = 1'b1;

    // assign this_ready = !prev_valid || (done && next_ready);
    assign this_ready = 1'b1;   // break loop
    assign this_valid = prev_valid & done;


    // reg rs1
    assign reg_rs1 = inst_ecall ? 5'd15 : inst[19:15];

    // csr wen2
    assign csr_wen2 = inst_ecall;

    always @ (*) begin
        case (opcode)
            `CSR_OPCODE: begin
                if (inst_ecall) begin
                    csr_wdata1 = reg_rdata1;
                end
                else if (inst_mret) begin
                    csr_wdata1 = `ZERO_WORD;
                end
                else begin
                    case (funct3)
                        3'b001: begin // csrrw
                            csr_wdata1 = reg_rdata1;
                        end
                        3'b010: begin // csrrs
                            csr_wdata1 = reg_rdata1 | csr_rdata;
                        end
                        default: begin
                            csr_wdata1 = `ZERO_WORD;
                        end
                    endcase
                end
            end
            default: begin
                csr_wdata1 = `ZERO_WORD;
            end
        endcase
    end

    // csr waddr1 wen1
    always @ (*) begin
        case (opcode)
            `CSR_OPCODE: begin
                if (inst_ecall) begin
                    csr_wen1 = 1'b1;
                    csr_waddr1 = `CSR_MCAUSE;
                end
                else if (inst_mret) begin
                    csr_wen1 = 1'b0;
                    csr_waddr1 = 12'h0;
                end
                else begin
                    csr_wen1 = 1'b1;
                    csr_waddr1 = inst[31:20];
                end
            end
            default: begin
                csr_wen1 = 1'b0;
                csr_waddr1 = 12'h0;
            end
        endcase
    end

    // csr raddr
    always @ (*) begin
        case (opcode)
            `CSR_OPCODE: begin
                if (inst_ecall) begin
                    csr_raddr = `CSR_MTVEC;
                end
                else if (inst_mret) begin
                    csr_raddr = `CSR_MEPC;
                end
                else begin
                    csr_raddr = inst[31:20];
                end
            end
            default: begin
                csr_raddr = 12'h0;
            end
        endcase
    end

    // imm gen
    always @ (*) begin
        case (opcode)
            `S_TYPE_OPCODE: 
                imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            `B_TYPE_OPCODE: 
                imm = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            `I_AL_TYPE_OPCODE,`I_LOAD_TYPE_OPCODE,`JALR_OPCODE: 
                imm = {{20{inst[31]}}, inst[31:20]};
            `JAL_OPCODE: 
                imm = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
            `LUI_OPCODE,`AUIPC_OPCODE: 
                imm = {inst[31:12], 12'b0};
            default: 
                imm = `ZERO_WORD;
        endcase
    end
    assign imm_o = imm;

    // alu_src1
    always @ (*) begin
        case (opcode)
            `LUI_OPCODE, `AUIPC_OPCODE,
            `JALR_OPCODE, `JAL_OPCODE: begin
                alu_src1 = pc;
            end
            default: begin
                alu_src1 = reg_rdata1;
            end
        endcase
    end

    // alu_src2
    always @ (*) begin
        case (opcode)
            `LUI_OPCODE,`AUIPC_OPCODE,
            `I_AL_TYPE_OPCODE,`I_LOAD_TYPE_OPCODE,
            `S_TYPE_OPCODE:begin
                alu_src2 = imm;
            end
            `JALR_OPCODE,`JAL_OPCODE: begin
                alu_src2 = 32'd4;
            end
            `R_TYPE_OPCODE,`B_TYPE_OPCODE: begin
                alu_src2 = reg_rdata2;
            end
            default: begin
                alu_src2 = reg_rdata2;
            end
        endcase
    end

    // alu_ctrl
    always @ (*) begin
        case (opcode) 
            `AUIPC_OPCODE,`JALR_OPCODE,
            `JAL_OPCODE,`I_LOAD_TYPE_OPCODE,
            `S_TYPE_OPCODE: begin
                alu_ctrl = `ALU_ADD;
            end
            `B_TYPE_OPCODE: begin
                case (funct3) 
                    3'b000,3'b001,3'b100,3'b101: begin
                        alu_ctrl = `ALU_LESS_THAN;
                    end
                    3'b110,3'b111: begin
                        alu_ctrl = `ALU_LESS_THAN_U;
                    end
                    default: begin
                        alu_ctrl = `ALU_ADD;
                    end
                endcase
            end
            `LUI_OPCODE: begin
                alu_ctrl = `ALU_NONE;
            end
            `R_TYPE_OPCODE: begin
                case (funct3)
                    3'b000: begin
                        alu_ctrl = funct7_5 ? `ALU_SUB : `ALU_ADD;
                    end
                    3'b001: begin
                        alu_ctrl = `ALU_SHIFT_L;
                    end
                    3'b010: begin
                        alu_ctrl = `ALU_LESS_THAN;
                    end
                    3'b011: begin
                        alu_ctrl = `ALU_LESS_THAN_U;
                    end
                    3'b100: begin
                        alu_ctrl = `ALU_XOR;
                    end
                    3'b101: begin
                        alu_ctrl = funct7_5 ? `ALU_SHIFT_R_ARITH : `ALU_SHIFT_R_LOGIC;
                    end
                    3'b110: begin
                        alu_ctrl = `ALU_OR;
                    end
                    3'b111: begin
                        alu_ctrl = `ALU_AND;
                    end
                    default: begin
                        alu_ctrl = `ALU_ADD;
                    end
                endcase
            end
            `I_AL_TYPE_OPCODE: begin
                case (funct3)
                    3'b000: begin
                        alu_ctrl = `ALU_ADD;
                    end
                    3'b010: begin
                        alu_ctrl = `ALU_LESS_THAN;
                    end
                    3'b011: begin
                        alu_ctrl = `ALU_LESS_THAN_U;
                    end
                    3'b100: begin
                        alu_ctrl = `ALU_XOR;
                    end
                    3'b110: begin
                        alu_ctrl = `ALU_OR;
                    end
                    3'b111: begin
                        alu_ctrl = `ALU_AND;
                    end
                    3'b001: begin
                        alu_ctrl = `ALU_SHIFT_L;
                    end
                    3'b101: begin
                        alu_ctrl = funct7_5 ? `ALU_SHIFT_R_ARITH : `ALU_SHIFT_R_LOGIC;
                    end
                    default: begin
                        alu_ctrl = `ALU_ADD;
                    end
                endcase
            end
            default: begin
                alu_ctrl = `ALU_ADD;
            end
        endcase
    end

    // pc_adder_src2
    always @ (*) begin
        case (opcode)
            `JALR_OPCODE: begin
                pc_adder_src2 = reg_rdata1;
            end
            default: begin
                pc_adder_src2 = pc;
            end
        endcase
    end

    // dmem_wen
    always @ (*) begin
        case (opcode)
            `S_TYPE_OPCODE: begin
                dmem_wen = 1'b1;
            end
            default: begin
                dmem_wen = 1'b0;
            end
        endcase
    end

    // dmem_req
    always @ (*) begin
        case (opcode)
            `I_LOAD_TYPE_OPCODE: begin
                dmem_req = 1'b1;
            end
            default: begin
                dmem_req = 1'b0;
            end
        endcase
    end

    // reg_wen
    always @ (*) begin
        case (opcode) 
            `LUI_OPCODE, `AUIPC_OPCODE, `I_AL_TYPE_OPCODE, `JALR_OPCODE,
            `I_LOAD_TYPE_OPCODE, `R_TYPE_OPCODE, `JAL_OPCODE: begin
                reg_wen = 1'b1;
            end
            `CSR_OPCODE: begin
                case (funct3)   
                    3'b001, 3'b010: begin
                        reg_wen = 1'b1;
                    end
                    default: begin
                        reg_wen = 1'b0;
                    end
                endcase
            end
            default: begin
                reg_wen = 1'b0;
            end
        endcase
    end

    // reg_wdata_sel
    always @ (*) begin
        case (opcode)
            `I_LOAD_TYPE_OPCODE: begin
                reg_wdata_sel = 2'b01;
            end
            `CSR_OPCODE: begin
                reg_wdata_sel = 2'b10;
            end
            default: begin
                reg_wdata_sel = 2'b00;
            end
        endcase
    end

endmodule