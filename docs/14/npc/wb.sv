`include "defines.svh"

module wb (
    input logic [`DATA_BUS] dmem_rdata,
    input logic [`DATA_BUS] alu_result,
    input logic [1:0] reg_wdata_sel,
    input logic [`DATA_BUS] csr_rdata,
    output logic [`DATA_BUS] reg_wdata
);

    assign reg_wdata = reg_wdata_sel[1] ? csr_rdata : (
        reg_wdata_sel[0] ? dmem_rdata : alu_result
    );

endmodule