module segment_hex(
    input wire [3:0] bcd,
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
    parameter A     = 8'h11;
    parameter B     = 8'hc1;
    parameter C     = 8'h63;
    parameter D     = 8'h85;
    parameter E     = 8'h61;
    parameter F     = 8'h71;

    always @ (*) begin
        case (bcd)
            0: seg_display = ZERO;
            1: seg_display = ONE;
            2: seg_display = TWO;
            3: seg_display = THREE;
            4: seg_display = FOUR;
            5: seg_display = FIVE;
            6: seg_display = SIX;
            7: seg_display = SEVEN;
            8: seg_display = EIGHT;
            9: seg_display = NINE;
            10: seg_display = A;
            11: seg_display = B;
            12: seg_display = C;
            13: seg_display = D;
            14: seg_display = E;
            15: seg_display = F;
            default seg_display = BLANK;
        endcase
    end


endmodule
