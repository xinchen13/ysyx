`include "../inc/defines.svh"

module pmu (
    input logic clk,
    input logic rst_n,

    input logic fetch_rvalid,
    input logic fetch_rready,

    input logic lsu_rvalid,
    input logic lsu_rready,

    input logic [`AXI_DATA_BUS] fetch_rdata

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

    // lsu read
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

    // inst type
    logic [63:0] a_type;    // arithmetic and logic
    logic [63:0] b_type;    // branch and jump
    logic [63:0] c_type;    // csr
    logic [63:0] load_type;
    logic [63:0] store_type;
    logic [63:0] none_type;
    logic [6:0] opcode = fetch_rdata[6:0];
    always @ (posedge clk) begin
        if (!rst_n) begin
            a_type      <= 'b0;
            b_type      <= 'b0;
            c_type      <= 'b0;
            load_type   <= 'b0;
            store_type  <= 'b0;
            none_type   <= 'b0;
        end
        else begin
            if (fetch_rvalid & fetch_rready) begin
                case (opcode)
                    `S_TYPE_OPCODE: 
                        store_type <= store_type + 64'b1;
                    `B_TYPE_OPCODE, `JAL_OPCODE, `JALR_OPCODE: 
                        b_type <= b_type + 64'b1;
                    `I_AL_TYPE_OPCODE, `R_TYPE_OPCODE, `LUI_OPCODE,`AUIPC_OPCODE: 
                        a_type <= a_type + 64'b1;
                    `I_LOAD_TYPE_OPCODE:
                        load_type <= load_type + 64'b1;
                    `CSR_OPCODE: 
                        c_type <= c_type + 64'b1;
                    default: 
                        none_type <= none_type + 64'b1;
                endcase
            end
        end
    end




endmodule