`define ALU_SUB_MINUS 4'b0000
`define ALU_SUB 4'b1000
`define ALU_LESS_THAN_U 4'b1010
`define DATA_WIDTH 32
`define DATA_BUS 31:0
`define ZERO_WORD 32'h0


module alu1 (
input logic clk,
    input logic [`DATA_BUS] a,
    input logic [`DATA_BUS] b,
    input logic [3:0] ctrl,
    output logic [`DATA_BUS] result
);
    logic [`DATA_BUS] alu_sub_minus;
    logic [`DATA_BUS] alu_sub;
    logic [`DATA_BUS] alu_less_than_u;

    assign alu_sub = a + (~b) + 1;
    assign alu_sub_minus = a - b;
    assign alu_less_than_u = (a < b) ? 32'h1 : 32'h0;

    always @ (*) begin
        case (ctrl)
            `ALU_SUB_MINUS:         result = alu_sub_minus;
            `ALU_SUB:               result = alu_sub;
            `ALU_LESS_THAN_U:       result = alu_less_than_u;
            default:                result = `ZERO_WORD;
        endcase
    end


endmodule
