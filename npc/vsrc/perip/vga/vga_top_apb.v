module vga_top_apb(
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

    output [7:0]  vga_r,
    output [7:0]  vga_g,
    output [7:0]  vga_b,
    output        vga_hsync,
    output        vga_vsync,
    output        vga_valid
);
    // frame buffer: registers
    reg [31:0] frame_buffer [0:2*21-1];

    // write reg
    reg state;
    localparam IDLE     = 1'b0;
    localparam WRITE    = 1'b1;
    always @ (posedge clock) begin
        if (reset) begin
            state       <= IDLE;
            in_prdata   <= 'b0;
            in_pready   <= 'b0;
            in_pslverr  <= 'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    in_prdata   <= 'b0;
                    in_pready   <= 'b0;
                    in_pslverr  <= 'b0;
                    if (in_psel & !in_penable & in_pwrite) begin
                        state <= WRITE;
                    end
                end
                WRITE: begin
                    if (in_psel & in_penable) begin
                        state       <= IDLE;
                        frame_buffer[in_paddr[22:2]]  <= in_pwdata; // 22-2+1=21
                        in_pready   <= 'b1;
                        in_pslverr  <= 'b0;
                    end
                end
            endcase
        end
    end

endmodule
