module gpio_top_apb(
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

    output [15:0] gpio_out,
    input  [15:0] gpio_in,
    output [7:0]  gpio_seg_0,
    output [7:0]  gpio_seg_1,
    output [7:0]  gpio_seg_2,
    output [7:0]  gpio_seg_3,
    output [7:0]  gpio_seg_4,
    output [7:0]  gpio_seg_5,
    output [7:0]  gpio_seg_6,
    output [7:0]  gpio_seg_7
);

    reg [31:0] gpio_led;            // 0x0
    reg [31:0] gpio_switch;         // 0x4
    reg [31:0] gpio_segment;        // 0x8
    reg [31:0] gpio_reserved;       // 0xc

    // apb read and write: gpio_led & gpio_segment
    reg [1:0] state;
    localparam IDLE     = 2'b00;
    localparam WRITE    = 2'b01;
    localparam READ     = 2'b10;

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
                    if (in_psel & !in_penable) begin
                        state <= in_pwrite ? WRITE : READ;
                    end
                end
                READ: begin
                    if (in_psel & in_penable) begin
                        state       <= IDLE;
                        in_prdata   <=  ( {32{(in_paddr[3:2] == 2'b00)}} & gpio_led[31:0]       ) |
                                        ( {32{(in_paddr[3:2] == 2'b01)}} & gpio_switch[31:0]    ) |
                                        ( {32{(in_paddr[3:2] == 2'b10)}} & gpio_segment[31:0]   ) |
                                        ( {32{(in_paddr[3:2] == 2'b11)}} & gpio_reserved[31:0]  ) ;
                        in_pready   <= 'b1;
                        in_pslverr  <= 'b0;
                    end
                end
                WRITE: begin
                    if (in_psel & in_penable) begin
                        state       <= IDLE;
                        if (in_pstrb[0]) begin
                            case (in_paddr[3:2])
                                2'b00: gpio_led         [7:0] <= in_pwdata[7:0];
                                // 2'b01: gpio_switch      [7:0] <= in_pwdata[7:0];
                                2'b10: gpio_segment     [7:0] <= in_pwdata[7:0];
                                2'b11: gpio_reserved    [7:0] <= in_pwdata[7:0];
                                default : gpio_reserved    [7:0] <= in_pwdata[7:0];
                            endcase
                        end
                        if (in_pstrb[1]) begin
                            case (in_paddr[3:2])
                                2'b00: gpio_led         [15:8] <= in_pwdata[15:8];
                                // 2'b01: gpio_switch      [15:8] <= in_pwdata[15:8];
                                2'b10: gpio_segment     [15:8] <= in_pwdata[15:8];
                                2'b11: gpio_reserved    [15:8] <= in_pwdata[15:8];
                                default : gpio_reserved    [15:8] <= in_pwdata[15:8];
                            endcase
                        end
                        if (in_pstrb[2]) begin
                            case (in_paddr[3:2])
                                2'b00: gpio_led         [23:16] <= in_pwdata[23:16];
                                // 2'b01: gpio_switch      [23:16] <= in_pwdata[23:16];
                                2'b10: gpio_segment     [23:16] <= in_pwdata[23:16];
                                2'b11: gpio_reserved    [23:16] <= in_pwdata[23:16];
                                default: gpio_reserved    [23:16] <= in_pwdata[23:16];
                            endcase
                        end
                        if (in_pstrb[3]) begin
                            case (in_paddr[3:2])
                                2'b00: gpio_led         [31:24] <= in_pwdata[31:24];
                                // 2'b01: gpio_switch      [31:24] <= in_pwdata[31:24];
                                2'b10: gpio_segment     [31:24] <= in_pwdata[31:24];
                                2'b11: gpio_reserved    [31:24] <= in_pwdata[31:24];
                                default: gpio_reserved    [31:24] <= in_pwdata[31:24];
                            endcase
                        end
                        in_pready   <= 'b1;
                        in_pslverr  <= 'b0;
                    end
                end
                default: begin
                    state       <= IDLE;
                    in_prdata   <= 'b0;
                    in_pready   <= 'b0;
                    in_pslverr  <= 'b0;
                end
            endcase
        end
    end

    // read io pins : gpio_switch
    always @ (posedge clock) begin
        if (reset) begin
            gpio_switch <= 32'b0;
        end
        else begin
            gpio_switch[15:0] <= gpio_in;
        end
    end

    // gpio out
    assign gpio_out = gpio_led[15:0];


endmodule
