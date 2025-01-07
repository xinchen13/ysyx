module ps2_top_apb(
    input         clock,
    input         reset,
    input  [31:0] in_paddr,
    input         in_psel,
    input         in_penable,
    input  [2:0]  in_pprot,
    input         in_pwrite,
    input  [31:0] in_pwdata,
    input  [3:0]  in_pstrb,
    output        in_pready,
    output [31:0] in_prdata,
    output        in_pslverr,

    input         ps2_clk,
    input         ps2_data
);
    reg [7:0] ps2_reg;

    wire ready;
    wire overflow;
    wire [7:0] scan_code;
    ps2_keyboard u_ps2_keyboard (
        .clk(clock),
        .rst_n(~reset),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .nextdata_n(1'b0),
        .scan_code(scan_code),
        .ready(ready),
        .overflow(overflow)
    );

endmodule
