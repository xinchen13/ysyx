`include "../inc/defines.svh"

module regfile (
    input logic clk,
    input logic [`RV32_REG_BUS] wdata,
    input logic [`REG_ADDR_BUS] waddr,
    input logic [`REG_ADDR_BUS] raddr1,
    input logic [`REG_ADDR_BUS] raddr2,
    output logic [`RV32_REG_BUS] rdata1,
    output logic [`RV32_REG_BUS] rdata2,
    input logic wen
);
    // define regs
    logic [`RV32_REG_BUS] regs [0:`RV32_REG_NUM-1];

    // read data
    assign rdata1 = (raddr1 == 0) ? 0 : regs[raddr1];
    assign rdata2 = (raddr2 == 0) ? 0 : regs[raddr2];
    
    // write data
    always @ (posedge clk) begin
        if ((waddr != 0) && wen) begin
            regs[waddr] <= wdata;
        end
    end

endmodule