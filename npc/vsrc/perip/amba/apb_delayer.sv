`include "defines.svh"

module apb_delayer(
    input         clock,
    input         reset,
    input  [31:0] in_paddr,
    input         in_psel,
    input         in_penable,
    input  [2:0]  in_pprot,
    input         in_pwrite,
    input  [31:0] in_pwdata,
    input  [3:0]  in_pstrb,
    output logic        in_pready,
    output logic [31:0] in_prdata,
    output logic       in_pslverr,

    output [31:0] out_paddr,
    output        out_psel,
    output        out_penable,
    output [2:0]  out_pprot,
    output        out_pwrite,
    output [31:0] out_pwdata,
    output [3:0]  out_pstrb,
    input         out_pready,
    input  [31:0] out_prdata,
    input         out_pslverr
);
    `ifdef PMU_ON

    assign out_paddr   = in_paddr;
    assign out_psel    = in_psel;
    assign out_penable = in_penable;
    assign out_pprot   = in_pprot;
    assign out_pwrite  = in_pwrite;
    assign out_pwdata  = in_pwdata;
    assign out_pstrb   = in_pstrb;

    // states
    localparam IDLE         = 3'b000;
    localparam APB_ACTIVE   = 3'b001;
    localparam APB_DELAY    = 3'b010;
    localparam COFF_S       = 10;
    localparam R_MUL_S      = 64'd9 << COFF_S; // r = 10, s = 1024
    reg [2:0] state;
    reg [63:0] delay_counter;
    reg  [31:0] temp_prdata;
    reg         temp_pslverr;

    always @ (posedge clock) begin
        if (reset) begin
            state <= IDLE;
        end
        else begin
            if(in_psel & !in_penable) begin
                state <= APB_ACTIVE;
            end
            else if((state == APB_ACTIVE) & out_pready) begin
                state <= APB_DELAY;
            end
            else if((state == APB_DELAY) & (delay_counter == 64'b0)) begin
                state <= IDLE;
            end
        end
    end

    always @ (posedge clock) begin
        if (reset) begin
            delay_counter <= 'b0;
        end
        else begin
            if ((state == APB_ACTIVE) & (!out_pready)) begin
                delay_counter <= delay_counter + R_MUL_S;
            end
            else if (out_pready) begin
                delay_counter <= (delay_counter >> COFF_S);
                temp_prdata <= out_prdata;
                temp_pslverr <= out_pslverr;
            end
            else if ((state == APB_DELAY) & (delay_counter != 64'b0)) begin
                delay_counter <= delay_counter - 64'b1;
            end
        end
    end



    always @ (posedge clock) begin
        if (reset) begin
            in_pready   <= 'b0;
            in_prdata   <= 'b0;
            in_pslverr  <= 'b0;
        end
        else begin
            if ((state == APB_DELAY) & (delay_counter == 64'b0)) begin
                in_pready   <= 'b1;
                in_prdata   <= temp_prdata;
                in_pslverr  <= temp_pslverr;
            end
            else begin
                in_pready   <= 'b0;
                in_prdata   <= 'b0;
                in_pslverr  <= 'b0;
            end
        end
    end

    `else
    assign out_paddr   = in_paddr;
    assign out_psel    = in_psel;
    assign out_penable = in_penable;
    assign out_pprot   = in_pprot;
    assign out_pwrite  = in_pwrite;
    assign out_pwdata  = in_pwdata;
    assign out_pstrb   = in_pstrb;
    assign in_pready   = out_pready;
    assign in_prdata   = out_prdata;
    assign in_pslverr  = out_pslverr;
    `endif

endmodule
