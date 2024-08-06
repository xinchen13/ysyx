module top(
    input wire clk,
    input wire rst_n,
    input wire [7:0] data,
    output wire [15:0] segment_dis
);

    wire [7:0] bcd;

    lfsr u_lfsr(
        .clk(clk),
        .rst_n(rst_n),
        .din(data),
        .dout(bcd)
    );

    segment_hex u_seg1(
        .bcd(bcd[3:0]),
        .seg_display(segment_dis[7:0])
    );

    segment_hex u_seg2(
        .bcd(bcd[7:4]),
        .seg_display(segment_dis[15:8])
    );

endmodule