`include "defines.svh"

module csr_regs (
    input logic clk,
    input logic rst_n,
    input logic [`CSR_ADDR_BUS] raddr,
    input logic [`CSR_ADDR_BUS] waddr1,
    input logic [`DATA_BUS] wdata1,
    input logic wen1,
    input logic [`CSR_ADDR_BUS] waddr2,
    input logic [`DATA_BUS] wdata2,
    input logic wen2,
    output logic [`DATA_BUS] rdata
);

    // define regs
    logic [`DATA_BUS] mtvec;
    logic [`DATA_BUS] mcause;
    logic [`DATA_BUS] mepc;
    logic [`DATA_BUS] mstatus;

    always @ (*) begin 
        case (raddr) 
            `CSR_MCAUSE: begin
                rdata = mcause; 
            end
            `CSR_MTVEC: begin
                rdata = mtvec;
            end
            `CSR_MSTATUS: begin
                rdata = mstatus;
            end
            `CSR_MEPC: begin
                rdata = mepc;
            end
            default: begin
                rdata = `ZERO_WORD;
            end
        endcase
    end

    always @ (posedge clk) begin
        if (!rst_n) begin
            mstatus <= 32'h00001800;
        end

        if (wen1) begin
            case (waddr1) 
                `CSR_MCAUSE: begin
                    mcause <= wdata1;
                end
                `CSR_MTVEC: begin
                    mtvec <= wdata1;
                end
                `CSR_MSTATUS: begin
                    mstatus <= wdata1;
                end
                `CSR_MEPC: begin
                    mepc <= wdata1;
                end
                default: begin
                    mstatus <= 32'h00001800; // should not reach here 
                end
            endcase
        end
    end

    always @ (posedge clk) begin
        if (wen2) begin
            case (waddr2) 
                `CSR_MCAUSE: begin
                    mcause <= wdata2;
                end
                `CSR_MTVEC: begin
                    mtvec <= wdata2;
                end
                `CSR_MSTATUS: begin
                    mstatus <= wdata2;
                end
                `CSR_MEPC: begin
                    mepc <= wdata2;
                end
                default: begin
                    mstatus <= 32'h00001800; // should not reach here
                end
            endcase
        end
    end

endmodule