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

  wire [31:0] to_spi_paddr;
  wire        to_spi_psel;
  wire        to_spi_penable;
  wire [2:0]  to_spi_pprot;
  wire        to_spi_pwrite;
  wire [31:0] to_spi_pwdata;
  wire [3:0]  to_spi_pstrb;

  reg [2:0] state;

  always @ (posedge clock) begin
    if (reset) begin
      state <= IDLE_NORMAL_SPI;
      to_spi_paddr    <= in_paddr;
      to_spi_psel     <= in_psel;
      to_spi_penable  <= in_penable;
      to_spi_pprot    <= in_pprot;
      to_spi_pwrite   <= in_pwrite;
      to_spi_pwdata   <= in_pwdata;
      to_spi_pstrb    <= in_pstrb;
    end
    else if (state == IDLE_NORMAL_SPI) begin
      if (in_paddr[31:28] == 4'h1) begin
          to_spi_paddr    <= in_paddr;
          to_spi_psel     <= in_psel;
          to_spi_penable  <= in_penable;
          to_spi_pprot    <= in_pprot;
          to_spi_pwrite   <= in_pwrite;
          to_spi_pwdata   <= in_pwdata;
          to_spi_pstrb    <= in_pstrb;
      end
      else if (in_paddr[31:28] == 4'h3) begin
      end
      else begin
      end

    end
    
  end


spi_top u0_spi_top (
  .wb_clk_i(clock),
  .wb_rst_i(reset),
  .wb_adr_i(to_spi_paddr[4:0]),
  .wb_dat_i(to_spi_pwdata),
  .wb_dat_o(in_prdata),
  .wb_sel_i(to_spi_pstrb),
  .wb_we_i (to_spi_pwrite),
  .wb_stb_i(to_spi_psel),
  .wb_cyc_i(to_spi_penable),
  .wb_ack_o(in_pready),
  .wb_err_o(in_pslverr),
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
