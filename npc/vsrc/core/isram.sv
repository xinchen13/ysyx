`include "../inc/defines.svh"

module isram (
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

    // logic done;
    // assign done = 1'b1;

    // assign arready = !arvalid || (done && rready);
    // assign rvalid = arvalid & done;

    // DPI-C: pmem_read, pmem_write
    import "DPI-C" function int dpic_pmem_read(input int raddr);

    // // sram
    // always @ (*) begin
    //     if (arvalid) begin
    //         rdata = dpic_pmem_read(araddr);
    //     end
    //     else begin
    //         rdata = `INST_NOP;
    //     end
    // end

    localparam [1:0] IDLE = 2'b00;
    localparam [1:0] WAIT = 2'b01;
    localparam [1:0] READ = 2'b10;

    logic [1:0] state;
    logic [1:0] next_state;

    // sram
    logic sram_ack;                     // SRAM读取完成信号
    logic [2:0] sram_wait_counter;      // 用于模拟不确定延迟的计数器
    logic [`AXI_DATA_BUS] sram_rdata;  // 从SRAM读取的数据

    // state reg
    always @ (posedge clk) begin
        if (!rst_n) begin
            state <= IDLE;
        end 
        else begin
            state <= next_state;
        end
    end

    // // trans logic
    // always @(*) begin
    //     next_state = state;
    //     case (state)
    //         IDLE: begin
    //             if (arvalid && arready) begin
    //                 next_state = WAIT;  // 转移到ADDR状态，捕获地址
    //             end
    //         end
    //         WAIT: begin
    //             if (sram_ack) begin
    //                 next_state = READ;  // SRAM读取完成，转移到READ状态
    //             end
    //         end
    //         READ: begin
    //             if (rvalid && rready) begin
    //                 next_state = IDLE;  // 数据传输完成，回到IDLE状态
    //             end
    //         end
    //         default: begin
    //             next_state = IDLE;
    //         end
    //     endcase
    // end



    // always @(posedge clk) begin
    //     if (!rst_n) begin
    //         sram_ack  <= 1'b0;
    //         sram_wait_counter <= 3'b000;  // 初始化等待计数器
    //     end 
    //     else begin
    //         case (state)
    //             IDLE: begin
    //                 sram_wait_counter <= 3'b000; // 重置等待计数器
    //             end
    //             WAIT: begin
    //                 if (sram_wait_counter == 3'b000) begin  // 模拟读取延迟
    //                     sram_rdata <= dpic_pmem_read(araddr);  // 从SRAM读取数据
    //                     sram_ack   <= 1'b1;  // 读取完成信号
    //                 end 
    //                 else begin
    //                     sram_ack <= 1'b0;
    //                     sram_wait_counter <= sram_wait_counter + 1;
    //                 end
    //             end
    //             READ: begin
    //                 if (rvalid && rready) begin
    //                     sram_ack <= 1'b0; // 清除ack信号，准备下一次操作
    //                 end
    //             end
    //             default: begin
    //             end
    //         endcase
    //     end
    // end

    assign arready = (state == IDLE) ? 1'b1 : 1'b0;
    assign rdata = ((state == WAIT) && sram_ack) ? sram_rdata : `INST_NOP;
    assign rresp = 2'b00;
    assign rvalid = ((state == WAIT) && sram_ack) ? 1'b1 : 1'b0;

    // trans logic
    always @ (*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (arvalid && arready) begin
                    next_state = WAIT;  // 转移到ADDR状态，捕获地址
                end
            end
            WAIT: begin
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
        end 
        else begin
            case (state)
                IDLE: begin
                    sram_wait_counter <= 3'b000; // 重置等待计数器
                    sram_ack <= 1'b0;
                end
                WAIT: begin
                    if (sram_wait_counter == 3'b000) begin  // 模拟读取延迟
                        sram_rdata <= dpic_pmem_read(araddr);  // 从SRAM读取数据
                        sram_ack   <= 1'b1;  // 读取完成信号
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