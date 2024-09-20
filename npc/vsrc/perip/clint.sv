`include "../inc/defines.svh"

module clint (
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

    logic [2:0] lfsr;

    localparam [1:0] IDLE = 2'b00;
    localparam [1:0] READ = 2'b01;

    logic [1:0] state;
    logic [1:0] next_state;
    logic [`AXI_ADDR_BUS] addr;
    logic [`AXI_ADDR_BUS] next_addr;

    // sram
    logic sram_ack;                     // SRAM读取完成信号
    logic [2:0] sram_wait_counter;      // 用于模拟不确定延迟的计数器

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


    assign arready = (state == IDLE) ? 1'b1 : 1'b0;
    assign rresp = 2'b00;
    assign rvalid = ((state == READ) && sram_ack) ? 1'b1 : 1'b0;

    // trans logic
    always @ (*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (arvalid && arready) begin
                    next_state = READ;  // 转移到READ状态
                    next_addr = araddr; 
                end
            end
            READ: begin
                if (rvalid && rready) begin
                    next_state = IDLE;  // 数据传输完成，回到IDLE状态
                end
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end


    always @(posedge clk) begin
        if (!rst_n) begin
            sram_ack  <= 1'b0;
            sram_wait_counter <= 3'b000;  // 初始化等待计数器
            rdata <= `INST_NOP;
            lfsr <= 3'b001;
        end 
        else begin
            case (state)
                IDLE: begin
                    sram_wait_counter <= 3'b000; // 重置等待计数器
                    sram_ack <= 1'b0;
                    lfsr <= {lfsr[1:0], lfsr[2] ^ lfsr[1]}; // LFSR反馈多项式, 伪随机延迟
                end
                READ: begin
                    if ((sram_wait_counter == lfsr) && (addr == 32'ha0000048)) begin  // 模拟读取延迟
                        rdata <= mtime[31:0];  // 从SRAM读取数据
                        sram_ack   <= 1'b1;  // 读取完成信号
                        sram_wait_counter <= 3'b000; // 重置等待计数器
                    end 
                    else begin
                        sram_ack <= 1'b0;
                        sram_wait_counter <= sram_wait_counter + 1;
                    end
                end
                default: begin
                end
            endcase
        end
    end

    // assign arready = rready;
    // assign rvalid = arvalid;
    // assign awready = 'b0;
    // assign rresp = 'b0;

    // // read
    // always @ (*) begin
    //     if (arvalid) begin
    //         case (araddr)
    //             32'ha0000048: begin
    //                 rdata = mtime[31:0] >> 9; // us: mtime / 500
    //             end
    //             32'ha000004c: begin
    //                 rdata = mtime[63:32];
    //             end
    //             default: begin
    //                 rdata = 'b0;
    //             end
    //         endcase
    //     end
    //     else begin
    //         rdata = 'b0;
    //     end
    // end

endmodule