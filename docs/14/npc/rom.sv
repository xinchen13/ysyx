`include "defines.svh"

module rom (
    input logic [7:0] raddr,
    output logic [`RV32_REG_BUS] rdata
);
    // define regs
    logic [`RV32_REG_BUS] regs [0:255];

    // read data
    assign rdata = regs[raddr];

endmodule