module bitrev (
    input  sck,
    input  ss,
    input  mosi,
    output reg miso
);
    localparam IDLE     = 3'b000;
    localparam RX       = 3'b001;
    localparam TX       = 3'b010;

    reg [7:0] rx_reg;
    reg [2:0] state;
    reg [2:0] bit_cnt;

    // unsynthesizable
    initial begin
        state = IDLE;
        rx_reg = 'b0;
        bit_cnt = 'b0;
        miso = 'b1;
    end

    always @ (posedge sck or negedge ss) begin
        if (!ss) begin
            case (state)
                IDLE: begin
                    state <= RX;
                    bit_cnt <= 3'd0;
                    rx_reg <= {mosi, rx_reg[7:1]};
                    miso <= 1'b1;
                end
                RX: begin
                    rx_reg <= {mosi, rx_reg[7:1]};
                    if (bit_cnt == 3'd7) begin
                        state <= TX;
                        miso <= mosi;
                        bit_cnt <= 3'd6;
                    end
                    else begin
                        bit_cnt <= bit_cnt + 1'b1;
                        miso <= 1'b1;
                    end
                end
                TX: begin
                    miso <= rx_reg[bit_cnt];
                    if (bit_cnt == 3'd0) begin
                        state <= IDLE;
                        bit_cnt <= 3'd0;
                    end
                    else begin
                        bit_cnt <= bit_cnt - 1'b1;
                    end
                end
                default: begin
                    state <= IDLE;
                    rx_reg <= 'b0;
                    bit_cnt <= 'b0;
                    miso <= 'b1;
                end
            endcase
        end
        else begin
            state <= IDLE;
            rx_reg <= 'b0;
            bit_cnt <= 'b0;
            miso <= 'b1;
        end
    end

endmodule