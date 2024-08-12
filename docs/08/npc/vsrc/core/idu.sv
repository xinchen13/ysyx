`include "../inc/defines.svh"

module idu (
    input logic [`INST_DATA_BUS] inst,
    input logic [`DATA_BUS] reg_rdata1,
    output logic [`DATA_BUS] src1,
    output logic [`DATA_BUS] src2,
    output logic reg_wen
);

    assign src1 = reg_rdata1;
    assign src2 = {{20{inst[31]}}, inst[31:20]};
    assign reg_wen = 1'b1;

endmodule