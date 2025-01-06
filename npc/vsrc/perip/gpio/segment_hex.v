module segment_hex(
    input wire en,
    input wire [3:0] bcd,
    output reg [7:0] seg_display
);
    localparam  BLANK = 8'b11111111;
    localparam  ZERO  = 8'b00000011;
    localparam  ONE   = 8'b10011111;
    localparam  TWO   = 8'b00100101;
    localparam  THREE = 8'b00001101;
    localparam  FOUR  = 8'b10011001;
    localparam  FIVE  = 8'b01001001;
    localparam  SIX   = 8'b01000001;
    localparam  SEVEN = 8'b00011111;
    localparam  EIGHT = 8'b00000001;
    localparam  NINE  = 8'b00001001;
    localparam  A     = 8'h11;
    localparam  B     = 8'hc1;
    localparam  C     = 8'h63;
    localparam  D     = 8'h85;
    localparam  E     = 8'h61;          
    localparam  F     = 8'h71;

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
                8: seg_display = EIGHT;
                9: seg_display = NINE;
                10: seg_display = A;
                11: seg_display = B;
                12: seg_display = C;
                13: seg_display = D;
                14: seg_display = E;
                15: seg_display = F;
                default: seg_display = BLANK;
            endcase
        end
        else begin
            seg_display = BLANK;
        end
    end

endmodule




    