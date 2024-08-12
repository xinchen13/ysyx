
`define CPU_RESET_ADDR 32'h80000000

// gprs
`define REG_ADDR_BUS 4:0
`define RV32_REG_BUS 31:0
`define RV32_REG_WIDTH 32
`define RV32_REG_NUM 32
`define RV32E_REG_NUM 32

// buses
`define INST_ADDR_WIDTH 32
`define INST_ADDR_BUS 31:0
`define INST_DATA_WIDTH 32
`define INST_DATA_BUS 31:0
`define DATA_WIDTH 32
`define DATA_BUS 31:0

// inst
`define INST_EBREAK 32'h00100073