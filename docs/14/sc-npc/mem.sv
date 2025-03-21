`include "defines.svh"

module mem (
    input logic [`INST_DATA_BUS] inst,
    input logic [`DATA_BUS] raddr,
    input logic [`DATA_BUS] waddr,
    input logic [`DATA_BUS] wdata,
    input logic wen,
    input logic req,
    output logic [`DATA_BUS] rdata
);

    logic [6:0] opcode = inst[6:0];
    logic [2:0] funct3 = inst[14:12];
    logic [`BYTE_BUS] wmask;
    logic [`DATA_BUS] dmem_rdata_raw;
    logic [`DATA_BUS] masked_dmem_rdata;
    logic [4:0] dmem_offset;
    logic [`DATA_BUS] dmem_rdata_offset;
    logic [`DATA_BUS] dmem_wdata_offset;

    ram ram_u0 (
        .clk(clk),
        .wdata(dmem_wdata_offset),
        .waddr(waddr[7:0]),
        .raddr(raddr[7:0]),
        .rdata(dmem_rdata_raw),
        .wen(wen)
    );

    // rmask
    assign dmem_offset = {3'b0, raddr[1:0]};
    assign dmem_rdata_offset = dmem_rdata_raw >> (dmem_offset << 3);
    always @ (*) begin
        case (opcode)
            `I_LOAD_TYPE_OPCODE: begin
                case (funct3)
                    3'b000: begin
                        masked_dmem_rdata = {{24{dmem_rdata_offset[7]}}, dmem_rdata_offset[7:0]};
                    end
                    3'b001: begin
                        masked_dmem_rdata = {{16{dmem_rdata_offset[15]}}, dmem_rdata_offset[15:0]};
                    end
                    3'b010: begin
                        masked_dmem_rdata = dmem_rdata_offset;
                    end
                    3'b100: begin
                        masked_dmem_rdata = {{24'b0}, dmem_rdata_offset[7:0]};
                    end
                    3'b101: begin
                        masked_dmem_rdata = {{16'b0}, dmem_rdata_offset[15:0]};
                    end
                    default: begin
                        masked_dmem_rdata = dmem_rdata_offset;
                    end
                endcase
            end
            default: begin
                masked_dmem_rdata = dmem_rdata_offset;
            end
        endcase
    end

    assign rdata = masked_dmem_rdata;

    // wmask
    always @ (*) begin
        case (opcode)
            `S_TYPE_OPCODE: begin
                case (funct3)
                    3'b000: begin
                        wmask = 8'b00000001 << dmem_offset;
                    end
                    3'b001: begin
                        wmask = 8'b00000011 << dmem_offset;
                    end
                    3'b010: begin
                        wmask = 8'b00001111 << dmem_offset;
                    end
                    default: begin
                        wmask = 8'b00000000;
                    end
                endcase
            end
            default: begin
                wmask = 8'b00000000;
            end
        endcase
    end
    
    assign dmem_wdata_offset = wdata << (dmem_offset << 3);


endmodule