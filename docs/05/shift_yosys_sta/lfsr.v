module lfsr(
    input wire clk,
    input wire rst_n,
    input wire [7:0] din,
    output reg [7:0] dout
);
    always @ (posedge clk) begin
        if (!rst_n) begin
            dout <= din;
        end
        else begin
            dout <= {dout[4] ^ dout[3] ^ dout[2] ^ dout[0], dout[7:1]};
        end
    end

endmodule