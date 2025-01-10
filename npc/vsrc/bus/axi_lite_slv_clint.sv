`include "../inc/defines.svh"

module axi_lite_slv_clint (
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


    localparam [2:0] IDLE =     3'b000;
    localparam [2:0] READ =     3'b001;
    localparam [2:0] AWRITE =   3'b010;
    localparam [2:0] WRITE =    3'b011;

    logic [2:0] state;
    logic [2:0] next_state;

    // sram
    logic sram_ack;                     // SRAM读取完成信号


    // mtime register
    logic [63:0] mtime;
    always @ (posedge clk) begin
        if (!rst_n) begin
            mtime <= 'b0;
        end
        else begin
            mtime <= mtime + 'b1;
        end
    end

    // state reg
    always @ (posedge clk) begin
        if (!rst_n) begin
            state <= IDLE;
            addr <= 'b0;
        end 
        else begin
            state <= next_state;
            addr <= next_addr;
        end
    end

    logic [`AXI_ADDR_BUS] next_addr;
    logic [`AXI_ADDR_BUS] addr;

    assign arready = (state == IDLE) ? 1'b1 : 1'b0;
    assign awready = (state == IDLE) ? 1'b1 : 1'b0;
    assign rresp = 2'b00;
    assign bresp = 2'b00;
    assign rvalid = ((state == READ) && sram_ack) ? 1'b1 : 1'b0;
    assign bvalid = ((state == WRITE) && sram_ack) ? 1'b1 : 1'b0;
    assign wready = (state == IDLE || state == AWRITE) ? 1'b1 : 1'b0;

    // trans logic
    always @ (*) begin
        next_state = state;
        case (state)
            IDLE: begin
                next_addr = addr;
                if (arvalid && arready) begin
                    next_state = READ;  // 转移到READ状态
                    next_addr = araddr;
                end
                else if (awvalid && awready) begin
                    next_state = AWRITE;
                    next_addr = awaddr;
                end
            end
            READ: begin
                next_addr = addr;
                if (rvalid && rready) begin
                    next_state = IDLE;  // 数据传输完成，回到IDLE状态
                end
            end
            AWRITE: begin
                next_addr = addr;
                if (wvalid && wready) begin
                    next_state = WRITE;
                end
            end
            WRITE: begin
                next_addr = addr;
                if (bvalid && bready) begin
                    next_state = IDLE;
                end
            end
            default: begin
                next_state = IDLE;
                next_addr = addr;
            end
        endcase
    end


    always @ (posedge clk) begin
        if (!rst_n) begin
            sram_ack  <= 1'b0;
            rdata <= 'b0;
        end 
        else begin
            case (state)
                IDLE: begin
                    sram_ack <= 1'b0;
                end
                READ: begin
                    case (araddr[3:0])
                        4'h0: begin
                            // rdata <= mtime[31:0] >> 9; // us: mtime / 500
                            rdata <= mtime[31:0]; // us: mtime / 500
                            // $display("read mtime low");
                        end
                        4'h4: begin
                            rdata <= mtime[63:32];
                        end
                        default: begin
                            rdata <= 'b0;
                        end
                    endcase
                    sram_ack   <= 1'b1;  // 读取完成信号
                end
                WRITE: begin
                        sram_ack <= 1'b1;
                    end
                default: begin
                end
            endcase
        end
    end

endmodule