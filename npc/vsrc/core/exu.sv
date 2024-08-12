`include "../inc/defines.svh"

module exu (
    input logic [`DATA_BUS] src1,
    input logic [`DATA_BUS] src2,
    output logic [`DATA_BUS] reg_wdata
);
    assign reg_wdata = src1 + src2;
endmodule