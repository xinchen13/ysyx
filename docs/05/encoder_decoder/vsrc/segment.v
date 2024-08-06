module segment(
    input wire en,
    input wire [2:0] bcd,
    output reg [7:0] seg_display
);

    parameter BLANK = 8'b11111111;
    parameter ZERO  = 8'b00000011;
    parameter ONE   = 8'b10011111;
    parameter TWO   = 8'b00100101;
    parameter THREE = 8'b00001101;
    parameter FOUR  = 8'b10011001;
    parameter FIVE  = 8'b01001001;
    parameter SIX   = 8'b01000001;
    parameter SEVEN = 8'b00011111;
    parameter EIGHT = 8'b00000001;
    parameter NINE  = 8'b00001001;

    always @ (*) begin
        if (en) begin
            case (bcd)
                0: seg_display = ZERO;
                1: seg_display = ONE;
                2: seg_display = TWO;
                3: seg_display = THREE;
                4: seg_display = FOUR;
                5: seg_display = FIVE;
                6: seg_display = SIX;
                7: seg_display = SEVEN;
                default seg_display = BLANK;
            endcase
        end
        else begin
            seg_display = BLANK;
        end
    end

endmodule