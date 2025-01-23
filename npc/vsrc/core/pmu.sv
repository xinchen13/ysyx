`include "../inc/defines.svh"

module pmu (
    input logic clk,
    input logic rst_n,

    input logic fetch_rvalid,
    input logic fetch_rready,

    input logic lsu_rvalid,
    input logic lsu_rready

);
    // total cycle
    logic [63:0] cycle_count;
    always @ (posedge clk) begin
        if (!rst_n) begin
            cycle_count <= 'b0;
        end
        else begin
            cycle_count <= cycle_count + 64'b1;
        end
    end

    // total inst fetched
    logic [63:0] inst_count;
    always @ (posedge clk) begin
        if (!rst_n) begin
            inst_count <= 'b0;
        end
        else begin
            if (fetch_rvalid & fetch_rready) begin
                inst_count <= inst_count + 64'b1;
            end
        end
    end

    logic [63:0] lsu_read_count;
    always @ (posedge clk) begin
        if (!rst_n) begin
            lsu_read_count <= 'b0;
        end
        else begin
            if (lsu_rvalid & lsu_rready) begin
                lsu_read_count <= lsu_read_count + 64'b1;
            end
        end
    end


endmodule