`define ALU_SHIFT_L 4'b0001
`define ALU_SHIFT_R_LOGIC 4'b0101
`define DATA_WIDTH 32
`define DATA_BUS 31:0
`define ZERO_WORD 32'h0


module alu2 (
input logic clk,
    input logic [`DATA_BUS] a,
    input logic [`DATA_BUS] b,
    input logic [3:0] ctrl,
    output logic [`DATA_BUS] result
);
    logic [`DATA_BUS] alu_shift_l;
    logic [`DATA_BUS] alu_shift_r_logic;

    assign alu_shift_l = a << b[4:0];
    assign alu_shift_r_logic = a >> b[4:0];

    always @ (*) begin
        case (ctrl)
            `ALU_SHIFT_L:           result = alu_shift_l;
            `ALU_SHIFT_R_LOGIC:     result = alu_shift_r_logic;
            default:                result = `ZERO_WORD;
        endcase
    end
endmodule
