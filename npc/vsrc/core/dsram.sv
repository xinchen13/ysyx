`include "../inc/defines.svh"

module dsram (
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

    // DPI-C: pmem_read, pmem_write
    import "DPI-C" function int dpic_pmem_read(input int raddr);
    import "DPI-C" function void dpic_pmem_write(input int waddr, input int wdata, input byte wmask);

    logic [2:0] lfsr;

    localparam [1:0] IDLE = 2'b00;
    localparam [1:0] READ = 2'b01;
    localparam [1:0] WRITE = 2'b10;

    logic [1:0] state;
    logic [1:0] next_state;

    // sram
    logic sram_ack;                     // SRAM读取完成信号
    logic [2:0] sram_wait_counter;      // 用于模拟不确定延迟的计数器

    // state reg
    always @ (posedge clk) begin
        if (!rst_n) begin
            state <= IDLE;
        end 
        else begin
            state <= next_state;
        end
    end


    assign arready = (state == IDLE) ? 1'b1 : 1'b0;
    assign awready = (state == IDLE) ? 1'b1 : 1'b0;
    assign rresp = 2'b00;
    assign bresp = 2'b00;
    assign rvalid = ((state == READ) && sram_ack) ? 1'b1 : 1'b0;
    assign bvalid = ((state == WRITE) && sram_ack) ? 1'b1 : 1'b0;
    assign wready = (state == WRITE) ? 1'b1 : 1'b0;

    // trans logic
    always @ (*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (arvalid && arready) begin
                    next_state = READ;  // 转移到READ状态
                end
                else if (awvalid && awready) begin
                    next_state = WRITE;
                end
            end
            READ: begin
                if (rvalid && rready) begin
                    next_state = IDLE;  // 数据传输完成，回到IDLE状态
                end
            end
            WRITE: begin
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
                    if (sram_wait_counter == lfsr) begin  // 模拟读取延迟
                        rdata <= dpic_pmem_read(araddr);  // 从SRAM读取数据
                        sram_ack   <= 1'b1;  // 读取完成信号
                    end 
                    else begin
                        sram_ack <= 1'b0;
                        sram_wait_counter <= sram_wait_counter + 1;
                    end
                end
                WRITE: begin
                    if (wvalid && wready && (sram_wait_counter == lfsr)) begin
                        dpic_pmem_write(awaddr, wdata, {
                            4'b0, wstrb[3], wstrb[2], wstrb[1], wstrb[0]
                        });
                        sram_ack <= 1'b1;
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

endmodule




    // // DPI-C: pmem_read, pmem_write
    // import "DPI-C" function int dpic_pmem_read(input int raddr);
    // import "DPI-C" function void dpic_pmem_write(input int waddr, input int wdata, input byte wmask);

    // // sram
    // always @ (posedge clk) begin
    //     if (awvalid) begin
    //         dpic_pmem_write(awaddr, wdata, {
    //             4'b0, wstrb[3], wstrb[2], wstrb[1], wstrb[0]
    //         });
    //     end
    // end
    // always @ (*) begin
    //     if (arvalid) begin
    //         rdata = dpic_pmem_read(araddr);
    //     end
    //     else begin
    //         rdata = 0;
    //     end
    // end

    // assign arready = rready;
    // assign awready = bready;
    // assign rvalid = arvalid;
    // assign bvalid = awvalid;
    // assign wready = 1'b1;