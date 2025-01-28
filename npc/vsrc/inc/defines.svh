
`define CPU_RESET_ADDR 32'h30000000
`define ZERO_WORD 32'h0
`define BYTE_BUS 7:0

// gprs
`define REG_ADDR_BUS 4:0
`define RV32_REG_BUS 31:0
`define RV32_REG_WIDTH 32
`define RV32_REG_NUM 32
`define RV32E_REG_NUM 32

// csr
`define CSR_ADDR_WIDTH 12
`define CSR_ADDR_BUS 11:0
`define CSR_MTVEC   12'h305
`define CSR_MCAUSE  12'h342
`define CSR_MEPC    12'h341
`define CSR_MSTATUS 12'h300

// buses
`define INST_ADDR_WIDTH 32
`define INST_ADDR_BUS 31:0
`define INST_DATA_WIDTH 32
`define INST_DATA_BUS 31:0
`define DATA_WIDTH 32
`define DATA_BUS 31:0
`define AXI_ADDR_WIDTH 32
`define AXI_ADDR_BUS 31:0
`define AXI_DATA_WIDTH 32
`define AXI_DATA_BUS 31:0
`define AXI_WSTRB_BUS 3:0
`define AXI_RESP_BUS 1:0
`define AXI_ID_WIDTH 4

// alu
`define ALU_ADD 4'b0000
`define ALU_SUB 4'b1000
`define ALU_SHIFT_L 4'b0001
`define ALU_LESS_THAN 4'b0010
`define ALU_LESS_THAN_U 4'b1010
`define ALU_NONE 4'b0011
`define ALU_XOR 4'b0100
`define ALU_SHIFT_R_ARITH 4'b1101
`define ALU_SHIFT_R_LOGIC 4'b0101
`define ALU_OR 4'b0110
`define ALU_AND 4'b0111

// inst
// opcode
`define R_TYPE_OPCODE 7'b0110011
`define S_TYPE_OPCODE 7'b0100011
`define B_TYPE_OPCODE 7'b1100011
`define I_AL_TYPE_OPCODE 7'b0010011
`define I_LOAD_TYPE_OPCODE 7'b0000011
`define JAL_OPCODE 7'b1101111
`define JALR_OPCODE 7'b1100111
`define LUI_OPCODE 7'b0110111
`define AUIPC_OPCODE 7'b0010111
`define CSR_OPCODE    7'b1110011  // CSR inst

// ebreak, ecall, mret
`define INST_EBREAK 32'h00100073
`define INST_ECALL  32'h73
`define INST_MRET   32'h30200073
`define INST_NOP    32'h00000001

// turn on performance monitor unit
`define PMU_ON          1'b1
// `define ICACHE_ON       1'b1