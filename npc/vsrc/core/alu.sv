`include "../inc/defines.svh"

module alu (
    input logic [`DATA_BUS] a,
    input logic [`DATA_BUS] b,
    input logic [3:0] ctrl,
    output logic [`DATA_BUS] result,
    output logic zero_flag,         // for branch
    output logic less_flag          // for branch
);
    logic [`DATA_BUS] alu_add;
    logic [`DATA_BUS] alu_sub;
    logic [`DATA_BUS] alu_or;
    logic [`DATA_BUS] alu_xor;
    logic [`DATA_BUS] alu_and;
    logic [`DATA_BUS] alu_shift_l;
    logic [`DATA_BUS] alu_shift_r_logic;
    logic [`DATA_BUS] alu_shift_r_arith;
    logic [`DATA_BUS] alu_less_than;
    logic [`DATA_BUS] alu_less_than_u;

    assign alu_add = a + b;
    assign alu_sub = a + (~b) + 1;
    assign alu_or = a | b;
    assign alu_xor = a ^ b;
    assign alu_and = a & b;
    assign alu_shift_l = a << b[4:0];
    assign alu_shift_r_logic = a >> b[4:0];
    assign alu_less_than = (a[`DATA_WIDTH-1] != b[`DATA_WIDTH-1]) ? 
        (a[`DATA_WIDTH-1] ? 32'h1 : 32'h0) : 
        (alu_sub[`DATA_WIDTH-1] ? 32'h1 : 32'h0);
    assign alu_less_than_u = (a < b) ? 32'h1 : 32'h0;

    // sra
    logic [`DATA_BUS] tmp = 32'hffffffff << (6'h20 - b[4:0]);
    assign alu_shift_r_arith = a[`DATA_WIDTH-1] ? (alu_shift_r_logic | tmp) : alu_shift_r_logic;

    always @ (*) begin
        case (ctrl)
            `ALU_ADD:               result = alu_add;
            `ALU_SUB:               result = alu_sub;
            `ALU_SHIFT_L:           result = alu_shift_l;
            `ALU_LESS_THAN:         result = alu_less_than;
            `ALU_LESS_THAN_U:       result = alu_less_than_u;
            `ALU_NONE:              result = b;
            `ALU_XOR:               result = alu_xor;
            `ALU_SHIFT_R_ARITH:     result = alu_shift_r_arith;
            `ALU_SHIFT_R_LOGIC:     result = alu_shift_r_logic;
            `ALU_OR:                result = alu_or;
            `ALU_AND:               result = alu_and;
            default:                result = `ZERO_WORD;
        endcase
    end

    assign zero_flag = ~(|alu_sub);
    // assign less_flag = result[0];
    assign less_flag = (result == 32'h1) ? 1'b1 : 1'b0;

endmodule
