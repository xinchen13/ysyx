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
    output reg        in_pready,
    output reg [31:0] in_prdata,
    output reg        in_pslverr,

    output [7:0]  vga_r,
    output [7:0]  vga_g,
    output [7:0]  vga_b,
    output        vga_hsync,
    output        vga_vsync,
    output        vga_valid
);
    // frame buffer: registers
    reg [31:0] vmem [0:2**21-1];

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
                        vmem[in_paddr[22:2]]  <= in_pwdata; // 22-2+1=21
                        in_pready   <= 'b1;
                        in_pslverr  <= 'b0;
                    end
                end
            endcase
        end
    end

    // vga ctrl
    parameter h_frontporch = 96;
    parameter h_active = 144;
    parameter h_backporch = 784;
    parameter h_total = 800;

    parameter v_frontporch = 2;
    parameter v_active = 35;
    parameter v_backporch = 515;
    parameter v_total = 525;

    reg [9:0] x_cnt;
    reg [9:0] y_cnt;
    wire h_valid;
    wire v_valid;
    wire [9:0] h_addr;
    wire [9:0] v_addr;

    always @(posedge clock) begin
        if(reset == 1'b1) begin
            x_cnt <= 1;
            y_cnt <= 1;
        end
        else begin
            if(x_cnt == h_total)begin
                x_cnt <= 1;
                if(y_cnt == v_total) y_cnt <= 1;
                else y_cnt <= y_cnt + 1;
            end
            else x_cnt <= x_cnt + 1;
        end
    end

    assign vga_hsync = (x_cnt > h_frontporch);
    assign vga_vsync = (y_cnt > v_frontporch);

    assign h_valid = (x_cnt > h_active) & (x_cnt <= h_backporch);
    assign v_valid = (y_cnt > v_active) & (y_cnt <= v_backporch);
    assign vga_valid = h_valid & v_valid;

    assign h_addr = h_valid ? (x_cnt - 10'd145) : 10'd0;
    assign v_addr = v_valid ? (y_cnt - 10'd36) : 10'd0;

    assign {vga_r, vga_g, vga_b} = vmem[{1'b0, v_addr, h_addr}][23:0];

endmodule
