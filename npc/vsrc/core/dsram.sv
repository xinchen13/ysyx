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

    // sram
    always @ (posedge clk) begin
        if (awvalid) begin
            dpic_pmem_write(awaddr, wdata, {
                wstrb[3], wstrb[3], wstrb[2], wstrb[2], wstrb[1], wstrb[1], wstrb[0], wstrb[0]
            });
        end
    end
    always @ (*) begin
        if (arvalid) begin
            rdata = dpic_pmem_read(araddr);
        end
        else begin
            rdata = 0;
        end
    end

    assign arready = rready;
    assign awready = bready;
    assign rvalid = arvalid;
    assign bvalid = awvalid;

    assign wready = 1'b1;

endmodule