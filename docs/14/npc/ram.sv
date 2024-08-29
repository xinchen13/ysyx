`include "defines.svh"

module ram (
    input logic clk,
    input logic [`RV32_REG_BUS] wdata,
    input logic [7:0] waddr,
    input logic [7:0] raddr,
    output logic [`RV32_REG_BUS] rdata,
    input logic wen
);
    // define regs
    logic [`RV32_REG_BUS] regs [0:255];

    // read data
    assign rdata = regs[raddr];
    
    // write data
    always @ (posedge clk) begin
        if (wen) begin
            regs[waddr] <= wdata;
        end
    end

endmodule