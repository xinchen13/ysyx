`define ALU_SUB 4'b1000
`define DATA_WIDTH 32
`define DATA_BUS 31:0
`define ZERO_WORD 32'h0


module alu0 (
input logic clk,
    input logic [`DATA_BUS] a,
    input logic [`DATA_BUS] b,
    input logic [3:0] ctrl,
    output logic [`DATA_BUS] result
);
    logic [`DATA_BUS] alu_sub;

    assign alu_sub = a + (~b) + 1;

    always @ (*) begin
        case (ctrl)
            `ALU_SUB:               result = alu_sub;
            default:                result = `ZERO_WORD;
        endcase
    end


endmodule
