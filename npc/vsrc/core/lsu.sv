`include "../inc/defines.svh"

module lsu (
    input logic clk,
    input logic rst_n,
    input logic [`INST_DATA_BUS] inst,
    input logic [`AXI_WSTRB_BUS] wmask,
    input logic [`DATA_BUS] raddr,
    input logic [`DATA_BUS] waddr,
    input logic [`DATA_BUS] ex_wdata,
    input logic wen,
    input logic req,
    output logic [`DATA_BUS] lsu_rdata,

    input logic prev_valid,
    output logic this_ready,
    input logic next_ready,
    output logic this_valid,

    // axi-lite interface (master)
    // AR
    output logic [`AXI_ADDR_BUS] araddr,
    output logic arvalid,
    input logic arready,
    // R
    input logic [`AXI_DATA_BUS] rdata,
    input logic [`AXI_RESP_BUS] rresp,
    input logic rvalid,
    output logic rready,
    // AW
    output logic [`AXI_ADDR_BUS] awaddr,
    output logic awvalid,
    input logic awready,
    // W
    output logic [`AXI_DATA_BUS] wdata,
    output logic [`AXI_WSTRB_BUS] wstrb,
    output logic wvalid,
    input logic wready,
    // B
    input logic [`AXI_RESP_BUS] bresp,
    input logic bvalid,
    output logic bready
);

    logic [6:0] opcode = inst[6:0];
    logic [2:0] funct3 = inst[14:12];

    // rmask
    logic [4:0] roffset;
    logic [`DATA_BUS] dmem_rdata_offset;
    logic [`DATA_BUS] masked_dmem_rdata;
    assign roffset = {3'b0, raddr[1:0]};
    assign dmem_rdata_offset = rdata >> (roffset << 3);
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
    assign lsu_rdata = masked_dmem_rdata;

    // wdata offset
    logic [4:0] woffset;
    logic [`DATA_BUS] wdata_offset;
    assign woffset = {3'b0, waddr[1:0]};
    assign wdata_offset = ex_wdata << (woffset << 3);

    // wmask offset
    logic [`AXI_WSTRB_BUS] wmask_offset;
    assign wmask_offset = wmask << waddr[1:0];

    // axi signals
    assign araddr = raddr;
    assign arvalid = req & prev_valid;
    assign rready = next_ready;
    assign awaddr = waddr;
    assign awvalid = wen & prev_valid;
    assign wdata = wdata_offset;
    assign wstrb = wmask_offset;
    assign wvalid = prev_valid;
    assign this_ready = arready & awready;
    assign this_valid = bvalid | rvalid | ((~arvalid) & (~awvalid) & prev_valid);
    assign bready = next_ready;

endmodule