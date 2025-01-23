`include "../inc/defines.svh"

module pmu (
    input logic clk,
    input logic rst_n,

    input logic fetch_rvalid,
    input logic fetch_rready

);

    logic [63:0] cycle_count;
    always @ (posedge clk) begin
        if (!rst_n) begin
            cycle_count <= 'b0;
        end
        else begin
            cycle_count <= cycle_count + 64'b1;
        end
    end


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

endmodule