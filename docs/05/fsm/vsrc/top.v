module top (
    input wire clk,
    input wire rst_n,
    input wire ps2_clk,
    input wire ps2_data,
    output wire [15:0] scan_code_seg,
    output wire [15:0] ascii_seg,
    output wire [15:0] count_seg,
    output wire overflow
);
    parameter [1:0] IDLE = 2'b00,
                    READ = 2'b01,
                    DONE = 2'b10;

    reg [1:0] state;
    reg [1:0] next_state;

    // next state logic
    always @ (*) begin
        case (state) 
            IDLE: begin
                if (ready) next_state = READ;
                else next_state = IDLE;
            end
            READ: begin
                if (ready && scan_code == 8'hF0) next_state = DONE;
                else next_state = READ;
            end
            DONE: begin
                if (ready) next_state = READ;
                else next_state = IDLE;
            end
            default: next_state = IDLE;
        endcase
    end

    reg [7:0] scan_code_buf;
    // state register
    always @ (posedge clk) begin
        if (!rst_n) begin 
            state <= IDLE;
            scan_code_buf <= 8'b0;
        end
        else begin
            state <= next_state;
            scan_code_buf <= ready ? scan_code : scan_code_buf;
        end
    end

    // control logic
    wire display_en;
    assign display_en = ((state == READ) && (scan_code != 8'hF0)) ? 1'b1 : 1'b0;
    wire count_en;
    assign count_en = (state == DONE) ? 1'b1 : 1'b0;
    wire ready;

    wire [7:0] scan_code;
    wire [7:0] ascii_code;

    // counter
    reg [7:0] count;
    always @ (posedge clk) begin
        if (!rst_n) count <= 8'b0;
        else if (count_en) count <= count + 1'b1; 
    end

    ps2_keyboard u_ps2_keyboard (
        .clk(clk),
        .rst_n(rst_n),
        .ps2_clk(ps2_clk),
        .ps2_data(ps2_data),
        .nextdata_n(1'b0),
        .scan_code(scan_code),
        .ready(ready),
        .overflow(overflow)
    );

    rom u_rom (
        .scan_code(scan_code_buf),
        .ascii_code(ascii_code)
    );

    segment_hex u_scan_code_l(
        .en(display_en),
        .bcd(scan_code_buf[3:0]),
        .seg_display(scan_code_seg[7:0])
    );
    
    segment_hex u_scan_code_h(
        .en(display_en),
        .bcd(scan_code_buf[7:4]),
        .seg_display(scan_code_seg[15:8])
    );

    segment_hex u_ascii_l(
        .en(display_en),
        .bcd(ascii_code[3:0]),
        .seg_display(ascii_seg[7:0])
    );
    
    segment_hex u_ascii_h(
        .en(display_en),
        .bcd(ascii_code[7:4]),
        .seg_display(ascii_seg[15:8])
    );

    segment_hex u_count_l(
        .en(1'b1),
        .bcd(count[3:0]),
        .seg_display(count_seg[7:0])
    );
    
    segment_hex u_count_h(
        .en(1'b1),
        .bcd(count[7:4]),
        .seg_display(count_seg[15:8])
    );

endmodule