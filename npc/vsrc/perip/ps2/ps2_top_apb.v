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
    output reg         in_pready,
    output reg  [31:0] in_prdata,
    output reg         in_pslverr,

    input         ps2_clk,
    input         ps2_data
);
    wire ready;
    wire overflow;
    wire [7:0] scan_code;
    reg nextdata_n;
    wire nextdata_n_wire = nextdata_n;

    // state machine
    reg state;
    localparam IDLE     = 1'b0;
    localparam READ     = 1'b1;

    always @ (posedge clock) begin
        if (reset) begin
            state       <= IDLE;
            in_prdata   <= 'b0;
            in_pready   <= 'b0;
            in_pslverr  <= 'b0;
            nextdata_n  <= 'b1;
        end
        else begin
            case (state)
                IDLE: begin
                    in_prdata   <= 'b0;
                    in_pready   <= 'b0;
                    in_pslverr  <= 'b0;
                    nextdata_n  <= 'b1;
                    if (in_psel & !in_penable) begin
                        state <= READ;
                    end
                end
                READ: begin
                    if (in_psel & in_penable) begin
                        state       <= IDLE;
                        nextdata_n  <= 'b0;
                        in_prdata   <= ready ? {24'b0, scan_code} : 'b0;
                        in_pready   <= 'b1;
                        in_pslverr  <= 'b0;
                    end
                end
            endcase
        end
    end

    ps2_keyboard u_ps2_keyboard (
        .clk(clock),
        .rst_n(~reset),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .nextdata_n(nextdata_n_wire),
        .scan_code(scan_code),
        .ready(ready),
        .overflow(overflow)
    );

endmodule
