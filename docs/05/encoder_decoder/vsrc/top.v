module top (
    input wire en,
    input wire [7:0] data,
    output wire flag,
    output wire [7:0] seg_display,
    output wire [2:0] bcd_result
);
    wire [2:0] bcd;
    assign bcd_result = bcd;

    encoder83 u_encoder83 (
        .din(data),
        .en(en),
        .dout(bcd),
        .flag(flag)
    );

    segment u_segment (
        .en(en),
        .bcd(bcd),
        .seg_display(seg_display)
    );

endmodule