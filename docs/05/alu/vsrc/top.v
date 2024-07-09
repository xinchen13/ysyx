/* verilator lint_off WIDTHEXPAND */


module top (
    input wire [3:0] a,
    input wire [3:0] b,
    input wire [2:0] opcode,
    output wire [3:0] y,
    output wire y_zero,
    output reg y_carry,
    output reg y_overflow
);
    reg [3:0] temp_y;
    assign y = temp_y;
    assign y_zero = ~(|temp_y);
    
    wire [3:0] sub_result = a + (~b) + 1;

    always @ (*) begin
        case (opcode)
            3'b000: begin
                {y_carry, temp_y} = a + b;
                y_overflow = (a[3] == b[3]) && (temp_y[3] != a[3]);
            end
            3'b001: begin
                {y_carry, temp_y} = a + (~b) + 1;
                y_overflow = (a[3] != b[3]) && (temp_y[3] != a[3]);
            end
            3'b010: begin
                temp_y = ~a;
                y_carry = 1'b0;
                y_overflow = 1'b0;
            end
            3'b011: begin
                temp_y = a & b;
                y_carry = 1'b0;
                y_overflow = 1'b0;
            end
            3'b100: begin
                temp_y = a | b;
                y_carry = 1'b0;
                y_overflow = 1'b0;
            end
            3'b101: begin
                temp_y = a ^ b;
                y_carry = 1'b0;
                y_overflow = 1'b0;
            end
            3'b110: begin
                if (a[3] != b[3]) begin
                    temp_y = a[3] ? 4'b0001 : 4'b0000;
                    y_carry = 1'b0;
                    y_overflow = 1'b0;
                end
                else begin
                    temp_y = sub_result[3] ? 4'b0001 : 4'b0000;
                    y_carry = 1'b0;
                    y_overflow = 1'b0;
                end
            end
            3'b111: begin
                temp_y = (sub_result == 4'b0000) ? 4'b0001 : 4'b0000;
                y_carry = 1'b0;
                y_overflow = 1'b0;
            end
            default: begin
                temp_y = 4'b0000;
                y_carry = 1'b0;
                y_overflow = 1'b0;
            end
        endcase
    end

endmodule