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

    // // DPI-C: pmem_read, pmem_write
    // import "DPI-C" function int dpic_pmem_read(input int raddr);

    // // sram
    // always @ (*) begin
    //     if (arvalid) begin
    //         rdata = dpic_pmem_read(araddr);
    //     end
    //     else begin
    //         rdata = `INST_NOP;
    //     end
    // end

    logic done;
    assign done = 1'b1;

    assign arready = !arvalid || (done && rready);
    assign rvalid = arvalid & done;

    // DPI-C: pmem_read, pmem_write
    import "DPI-C" function int dpic_pmem_read(input int raddr);

    // sram
    always @ (posedge clk) begin
        if (arvalid) begin
            rdata <= dpic_pmem_read(araddr);
        end
        else begin
            rdata <= `INST_NOP;
        end
    end

endmodule