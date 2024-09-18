`include "../inc/defines.svh"

module uart (
    input logic clk,
    input logic rst_n,

    // axi-lite interface (slave)
    // AR
    input logic [`AXI_ADDR_BUS] araddr,
    input logic arvalid,
    output logic arready,
    // R
    output logic [`AXI_DATA_BUS] rdata,
    output logic [`AXI_RESP_BUS] rresp,
    output logic rvalid,
    input logic rready,
    // AW
    input logic [`AXI_ADDR_BUS] awaddr,
    input logic awvalid,
    output logic awready,
    // W
    input logic [`AXI_DATA_BUS] wdata,
    input logic [`AXI_WSTRB_BUS] wstrb,
    input logic wvalid,
    output logic wready,
    // B
    output logic [`AXI_RESP_BUS] bresp,
    output logic bvalid,
    input logic bready
);

    import "DPI-C" function void dpic_pmem_write(input int waddr, input int wdata, input byte wmask);

    localparam [1:0] IDLE = 2'b00;
    localparam [1:0] RX = 2'b01;
    localparam [1:0] TX = 2'b10;

    logic [1:0] state;
    logic [1:0] next_state;

    logic uart_ack;

    // state reg
    always @ (posedge clk) begin
        if (!rst_n) begin
            state <= IDLE;
        end 
        else begin
            state <= next_state;
        end
    end

    assign arready = 1'b0;
    assign awready = (state == IDLE) ? 1'b1 : 1'b0;
    assign rresp = 2'b00;
    assign bresp = 2'b00;
    assign rvalid = 1'b0;
    assign bvalid = ((state == TX) && uart_ack) ? 1'b1 : 1'b0;
    assign wready = (state == IDLE) ? 1'b1 : 1'b0;

    // trans logic
    always @ (*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (awvalid && awready && wvalid && wready) begin
                    next_state = TX;
                end
            end
            TX: begin
                if (bvalid && bready) begin
                    next_state = IDLE;
                end
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end


    always @(posedge clk) begin
        if (!rst_n) begin
            uart_ack  <= 1'b0;
            rdata <= `INST_NOP;
        end 
        else begin
            case (state)
                IDLE: begin
                    uart_ack <= 1'b0;
                end
                TX: begin
                    if (~uart_ack) begin
                        dpic_pmem_write(awaddr, wdata, {
                            4'b0, wstrb[3], wstrb[2], wstrb[1], wstrb[0]
                        });
                        uart_ack <= 1'b1;
                    end
                end
                default: begin
                end
            endcase
        end
    end

endmodule
