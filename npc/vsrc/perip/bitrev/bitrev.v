module bitrev (
    input  sck,
    input  ss,
    input  mosi,
    output miso
);
    // assign miso = 1'b1;

    reg [7:0] data_reg;

    // write
    always @ (posedge sck) begin
        if (!ss) begin
            data_reg <= {data_reg[6:0], mosi};
        end
        else begin
            data_reg <= 'b0;
        end
    end

    // read
    always @ (posedge sck) begin
        if (!ss) begin
            miso <= {data_reg[6:0], mosi};
        end
        else begin
            miso <= 'b1;
        end
    end

endmodule
