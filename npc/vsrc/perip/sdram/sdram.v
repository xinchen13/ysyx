module sdram(
    input        clk,
    input        cke,
    input        cs,
    input        ras,
    input        cas,
    input        we,
    input [12:0] a,
    input [ 1:0] ba,
    input [ 1:0] dqm,
    inout [15:0] dq
);

    reg [12:0] mode_reg;

    // cmd
    localparam  NOP       =     3'b111;
    localparam  ACTIVE    =     3'b011;
    localparam  READ      =     3'b101;
    localparam  WRITE     =     3'b100;
    localparam  TERMINATE =     3'b110;
    localparam  PRECHARGE =     3'b010;
    localparam  REFRESH   =     3'b001;
    localparam  MODE_REG  =     3'b000;


endmodule
