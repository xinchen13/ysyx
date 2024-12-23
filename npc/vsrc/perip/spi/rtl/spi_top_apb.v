// define this macro to enable fast behavior simulation
// for flash by skipping SPI transfers
// `define FAST_FLASH
`define XIP_FLASH

module spi_top_apb #(
  parameter flash_addr_start = 32'h30000000,
  parameter flash_addr_end   = 32'h3fffffff,
  parameter spi_ss_num       = 8
) (
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

  output                  spi_sck,
  output [spi_ss_num-1:0] spi_ss,
  output                  spi_mosi,
  input                   spi_miso,
  output                  spi_irq_out
);

// flash simulation
`ifdef FAST_FLASH

wire [31:0] data;
parameter invalid_cmd = 8'h0;
flash_cmd flash_cmd_i(
  .clock(clock),
  .valid(in_psel && !in_penable),
  .cmd(in_pwrite ? invalid_cmd : 8'h03),
  .addr({8'b0, in_paddr[23:2], 2'b0}),
  .data(data)
);
assign spi_sck    = 1'b0;
assign spi_ss     = 8'b0;
assign spi_mosi   = 1'b1;
assign spi_irq_out= 1'b0;
assign in_pslverr = 1'b0;
assign in_pready  = in_penable && in_psel && !in_pwrite;
assign in_prdata  = data[31:0];

`elsif XIP_FLASH

  localparam IDLE_NORMAL_SPI = 3'b000;
  localparam XIP_INIT        = 3'b001;  // XIP initialization

  reg [31:0] to_spi_paddr;
  reg        to_spi_psel;
  reg        to_spi_penable;
  reg        to_spi_pwrite;
  reg [31:0] to_spi_pwdata;
  reg [3:0]  to_spi_pstrb;
  reg        from_spi_pready;
  reg [31:0] from_spi_prdata;
  reg        from_spi_pslverr;

  wire [4:0]  spi_paddr;
  wire        spi_psel;
  wire        spi_penable;
  wire        spi_pwrite;
  wire [31:0] spi_pwdata;
  wire [3:0]  spi_pstrb;
  wire        spi_pready;
  wire [31:0] spi_prdata;
  wire        spi_pslverr;

  reg [2:0] state;

  always @ (posedge clock) begin
    if (reset) begin
      state <= IDLE_NORMAL_SPI;
      to_spi_paddr    <= 'b0;
      to_spi_psel     <= 'b0;
      to_spi_penable  <= 'b0;
      to_spi_pwrite   <= 'b0;
      to_spi_pwdata   <= 'b0;
      to_spi_pstrb    <= 'b0;
      from_spi_prdata <= 'b0;
      from_spi_pready <= 'b0;
      from_spi_pslverr<= 'b0;
    end
    else begin
      case (state)
        IDLE_NORMAL_SPI: begin
          if (in_psel && in_penable) begin
            if (in_paddr >= 32'h10001000 && in_paddr <= 32'h10001fff) begin
              // Normal SPI access
              to_spi_paddr    <= in_paddr;
              to_spi_psel     <= in_psel;
              to_spi_penable  <= in_penable;
              to_spi_pwrite   <= in_pwrite;
              to_spi_pwdata   <= in_pwdata;
              to_spi_pstrb    <= in_pstrb;
              from_spi_prdata <= spi_prdata;
              from_spi_pready <= spi_pready;
              from_spi_pslverr<= spi_pslverr;
            end 
            else if (in_paddr >= flash_addr_start && in_paddr <= flash_addr_end) begin
              // XIP mode
              state <= XIP_INIT;
            end
          end
        end
        XIP_INIT: begin
          ;
        end
        default: begin
          state <= IDLE_NORMAL_SPI;
        end
    endcase
    end
  end

assign in_prdata  = from_spi_prdata;
assign in_pready  = from_spi_pready;
assign in_pslverr = from_spi_pslverr;
assign spi_paddr  = to_spi_paddr[4:0];
assign spi_psel   = to_spi_psel;
assign spi_penable= to_spi_penable;
assign spi_pwrite = to_spi_pwrite;
assign spi_pwdata = to_spi_pwdata;
assign spi_pstrb  = to_spi_pstrb;

  spi_top u0_spi_top (
    .wb_clk_i(clock),
    .wb_rst_i(reset),
    .wb_adr_i(spi_paddr),
    .wb_dat_i(spi_pwdata),
    .wb_dat_o(spi_prdata),
    .wb_sel_i(spi_pstrb),
    .wb_we_i (spi_pwrite),
    .wb_stb_i(spi_psel),
    .wb_cyc_i(spi_penable),
    .wb_ack_o(spi_pready),
    .wb_err_o(spi_pslverr),
    .wb_int_o(spi_irq_out),

    .ss_pad_o(spi_ss),
    .sclk_pad_o(spi_sck),
    .mosi_pad_o(spi_mosi),
    .miso_pad_i(spi_miso)
  );

`else

spi_top u0_spi_top (
  .wb_clk_i(clock),
  .wb_rst_i(reset),
  .wb_adr_i(in_paddr[4:0]),
  .wb_dat_i(in_pwdata),
  .wb_dat_o(in_prdata),
  .wb_sel_i(in_pstrb),
  .wb_we_i (in_pwrite),
  .wb_stb_i(in_psel),
  .wb_cyc_i(in_penable),
  .wb_ack_o(in_pready),
  .wb_err_o(in_pslverr),
  .wb_int_o(spi_irq_out),

  .ss_pad_o(spi_ss),
  .sclk_pad_o(spi_sck),
  .mosi_pad_o(spi_mosi),
  .miso_pad_i(spi_miso)
);

`endif

endmodule
