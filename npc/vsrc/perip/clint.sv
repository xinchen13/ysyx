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

    assign arready = rready;
    assign rvalid = arvalid;

    // read
    always @ (*) begin
        if (arvalid) begin
            case (araddr[2])
                1'b0: begin
                    rdata = mtime[31:0];
                end
                1'b1: begin
                    rdata = mtime[63:32];
                end
            endcase
        end
        else begin
            rdata = 'b0;
        end
    end

endmodule