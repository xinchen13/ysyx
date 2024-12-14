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
    reg [7:0] tx_reg;
    reg [2:0] state;
    reg [2:0] bit_cnt;

    // unsynthesizable
    initial begin
        state = IDLE;
        rx_reg = 'b0;
        tx_reg = 'b0;
        bit_cnt = 'b0;
        miso = 'b1;
    end

    always @ (posedge sck) begin
        if (!ss) begin
        end
        else begin
            miso <= 1'b1;
        end
    end

endmodule