`include "../inc/defines.svh"

module wb (
    input logic [`DATA_BUS] dmem_rdata,
    input logic [`DATA_BUS] alu_result,
    input logic reg_wdata_sel,
    output logic [`DATA_BUS] reg_wdata
);

    assign reg_wdata = reg_wdata_sel ? dmem_rdata : alu_result;

endmodule