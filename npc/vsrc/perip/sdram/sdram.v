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
    // cmd
    localparam  NOP       =     3'b111;
    localparam  ACTIVE    =     3'b011;
    localparam  READ      =     3'b101;
    localparam  WRITE     =     3'b100;
    localparam  TERMINATE =     3'b110;
    localparam  PRECHARGE =     3'b010;
    localparam  REFRESH   =     3'b001;
    localparam  MODE_REG  =     3'b000;

    wire [2:0] cmd;
    assign cmd = {ras, cas, we};

    // mode register
    reg [12:0] mode_reg;
    wire [2:0] cas_latency;
    reg [3:0] burst_length;
    // write mode register
    always @ (posedge clk) begin
        if (~cs & (cmd == MODE_REG)) begin
            mode_reg <= a;
        end
    end
    // read mode register
    always @ (*) begin
        case (mode_reg[2:0])
            3'b000: burst_length = 'd1;
            3'b001: burst_length = 'd2;
            3'b010: burst_length = 'd4;
            3'b011: burst_length = 'd8;
            default: burst_length = 'd1;
        endcase
    end
    assign cas_latency = mode_reg[6:4];


endmodule
