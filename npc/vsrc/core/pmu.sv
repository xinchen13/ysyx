`include "../inc/defines.svh"

module pmu (
    input logic clk,
    input logic rst_n,

    input logic fetch_rvalid,
    input logic fetch_rready,
    input logic fetch_arvalid,
    input logic fetch_arready,

    input logic lsu_rvalid,
    input logic lsu_rready,

    input logic [`AXI_DATA_BUS] fetch_rdata,
    
    input logic ins_retire

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

    // inst cycle
    localparam IDLE         = 3'b110;
    localparam A_TYPE       = 3'b000;
    localparam B_TYPE       = 3'b001;
    localparam C_TYPE       = 3'b010;
    localparam LOAD_TYPE    = 3'b011;
    localparam STORE_TYPE   = 3'b100;
    localparam NONE_TYPE    = 3'b101;
    reg [2:0] cycle_count_state;

    logic [63:0] a_type_cycle;    // arithmetic and logic
    logic [63:0] b_type_cycle;    // branch and jump
    logic [63:0] c_type_cycle;    // csr
    logic [63:0] load_type_cycle;
    logic [63:0] store_type_cycle;
    logic [63:0] none_type_cycle;
    always @ (posedge clk) begin
        if (!rst_n) begin
            cycle_count_state <= IDLE;
        end
        else begin
            if (fetch_rvalid & fetch_rready) begin
                case (opcode)
                    `S_TYPE_OPCODE: 
                        cycle_count_state <= STORE_TYPE;
                    `B_TYPE_OPCODE, `JAL_OPCODE, `JALR_OPCODE: 
                        cycle_count_state <= B_TYPE;
                    `I_AL_TYPE_OPCODE, `R_TYPE_OPCODE, `LUI_OPCODE,`AUIPC_OPCODE: 
                        cycle_count_state <= A_TYPE;
                    `I_LOAD_TYPE_OPCODE:
                        cycle_count_state <= LOAD_TYPE;
                    `CSR_OPCODE: 
                        cycle_count_state <= C_TYPE;
                    default: 
                        cycle_count_state <= NONE_TYPE;
                endcase
            end
            else if (ins_retire) begin
                cycle_count_state <= IDLE;
            end
        end
    end

    always @ (posedge clk) begin
        if (!rst_n) begin
            a_type_cycle      <= 'b0;
            b_type_cycle      <= 'b0;
            c_type_cycle      <= 'b0;
            load_type_cycle   <= 'b0;
            store_type_cycle  <= 'b0;
            none_type_cycle   <= 'b0;
        end
        else begin
            case (cycle_count_state)
                IDLE: begin
                end
                A_TYPE: begin
                    a_type_cycle <= a_type_cycle + 64'b1;
                end
                B_TYPE: begin
                    b_type_cycle <= b_type_cycle + 64'b1;
                end
                C_TYPE: begin
                    c_type_cycle <= c_type_cycle + 64'b1;
                end
                LOAD_TYPE: begin
                    load_type_cycle <= load_type_cycle + 64'b1;
                end
                STORE_TYPE: begin
                    store_type_cycle <= store_type_cycle + 64'b1;
                end
                default: begin
                    none_type_cycle <= none_type_cycle + 64'b1;
                end
            endcase
        end
    end


    // front end: fetch counter
    reg fetch_state;
    logic [63:0] front_end_fetch_cycle;
    always @ (posedge clk) begin
        if (!rst_n) begin
            fetch_state <= 'b0;
        end
        else begin
            if (fetch_arvalid & fetch_arready) begin
                fetch_state <= 'b1;
            end
            else if (fetch_rvalid & fetch_rready) begin
                fetch_state <= 'b0;
            end
        end
    end

    always @ (posedge clk) begin
        if (!rst_n) begin
            front_end_fetch_cycle <= 'b0;
        end
        else begin
            if (fetch_state) begin
                front_end_fetch_cycle <= front_end_fetch_cycle + 64'b1;
            end
        end
    end

endmodule