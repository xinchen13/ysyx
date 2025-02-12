`include "../inc/defines.svh"

module icache (
    input logic clk,
    input logic rst_n,

    input logic icache_flush,

    // axi-lite interface: core
    // AR
    input logic [`AXI_ADDR_BUS] raw_fetch_araddr,
    input logic raw_fetch_arvalid,
    output logic raw_fetch_arready,
    // R
    output logic [`AXI_DATA_BUS] raw_fetch_rdata,
    output logic [`AXI_RESP_BUS] raw_fetch_rresp,
    output logic raw_fetch_rvalid,
    input logic raw_fetch_rready,

    // axi-lite interface: bus
    // AR
    output logic [`AXI_ADDR_BUS] fetch_araddr,
    output logic fetch_arvalid,
    input logic fetch_arready,
    // R
    input logic [`AXI_DATA_BUS] fetch_rdata,
    input logic [`AXI_RESP_BUS] fetch_rresp,
    input logic fetch_rvalid,
    output logic fetch_rready
);
    `ifdef ICACHE_ON
        // pmu
        `ifdef PMU_ON
            reg [63:0] real_cache_hit;
            reg [63:0] real_cache_miss;
            reg [63:0] access_time_total;
            reg [63:0] miss_penalty_total;
            reg [2:0] pmu_state;
            localparam PMU_IDLE = 3'b000;
            localparam PMU_HIT  = 3'b001;
            localparam PMU_MISS = 3'b010;
            always @ (posedge clk) begin
                if (!rst_n) begin
                    access_time_total <= 'b0;
                    miss_penalty_total <= 'b0;
                end
                else begin
                    if (pmu_state == PMU_HIT) begin
                        access_time_total <= access_time_total + 64'b1;
                    end
                    else if (pmu_state == PMU_MISS) begin
                        miss_penalty_total <= miss_penalty_total + 64'b1;
                    end
                end
            end
        `endif

        localparam M = 2;              // one cache line has 2 ** M bytes
        localparam N = 4;              // icache has 2 ** N cache lines
        localparam CACHE_LINE_COUNT = 2**N;

        // state machine
        localparam IDLE         = 3'b000;
        localparam FETCH_REQ    = 3'b001;
        localparam MEM_REQ      = 3'b010;
        localparam RETURN_DATA  = 3'b011;
        reg [2:0] state;
        reg [`AXI_ADDR_BUS] buffered_addr;
        reg [`AXI_DATA_BUS] buffered_data;
        reg [`AXI_RESP_BUS] buffered_rresp;

        reg [`AXI_DATA_BUS]                 data_array  [0:CACHE_LINE_COUNT-1];         // data (32 bits)
        reg [`AXI_DATA_WIDTH-M-N-1:0]       tag_array   [0:CACHE_LINE_COUNT-1];         // tag (32-n-m+1 bits)
        reg                                 valid_array [0:CACHE_LINE_COUNT-1];         // valid (1 bit)

        wire [M-1:0]                    offset      = buffered_addr[M-1:0];
        wire [N-1:0]                    index       = buffered_addr[M+N-1:M];
        wire [`AXI_DATA_WIDTH-M-N-1:0]  tag         = buffered_addr[`AXI_DATA_WIDTH-1:M+N];
        wire cache_hit                              = (tag == tag_array[index]) & valid_array[index];

        // control signals
        assign raw_fetch_arready = (state == IDLE) ? 1'b1 : 1'b0;
        assign raw_fetch_rdata   = buffered_data;
        assign fetch_araddr      = buffered_addr;
        assign raw_fetch_rresp   = buffered_rresp;
        assign raw_fetch_rvalid  = (state == RETURN_DATA) ? 1'b1 : 1'b0;

        always @ (posedge clk) begin
            if (!rst_n) begin
                buffered_addr <= 'b0;
                buffered_data <= 'b0;
                buffered_rresp  <= 'b0;
                state <= IDLE;
                `ifdef PMU_ON
                    pmu_state <= PMU_IDLE;
                    real_cache_hit <= 'b0;
                    real_cache_miss <= 'b0;
                `endif
            end
            else begin
                case (state)
                    IDLE: begin
                        if (raw_fetch_arvalid) begin
                            buffered_addr <= raw_fetch_araddr;
                            state <= FETCH_REQ;
                        end
                    end
                    FETCH_REQ: begin
                        if (cache_hit) begin
                            `ifdef PMU_ON
                                real_cache_hit <= real_cache_hit + 64'b1;
                                pmu_state <= PMU_HIT;
                            `endif
                            state <= RETURN_DATA;
                            buffered_data <= data_array[index];
                            buffered_rresp <= 'b0;
                        end
                        else begin
                            `ifdef PMU_ON
                                real_cache_miss <= real_cache_miss + 64'b1;
                                pmu_state <= PMU_MISS;
                            `endif
                            state <= MEM_REQ;
                        end
                    end
                    MEM_REQ: begin
                        if (cache_hit) begin
                            state <= RETURN_DATA;
                            buffered_data <= data_array[index];
                            buffered_rresp <= 'b0;
                        end
                    end
                    RETURN_DATA: begin
                        if (raw_fetch_rready) begin
                            `ifdef PMU_ON
                                pmu_state <= PMU_IDLE;
                            `endif
                            state <= IDLE;
                        end
                    end
                    default: begin
                        state <= IDLE;
                    end
                endcase
            end
        end

        // mem erq state machine
        localparam MEM_REQ_IDLE = 3'b000;
        localparam MEM_REQ_ADDR = 3'b001;
        localparam MEM_REQ_WAIT = 3'b010;
        localparam MEM_REQ_DONE = 3'b011;
        reg [2:0] mem_req_state;

        integer i;
        always @ (posedge clk) begin
            if (!rst_n) begin
                mem_req_state <= MEM_REQ_IDLE;
                fetch_rready <= 1'b0;
                fetch_arvalid <= 1'b0;
                for (i = 0; i < CACHE_LINE_COUNT; i = i + 1) begin
                    data_array[i]   <= {`AXI_DATA_WIDTH{1'b0}};
                    tag_array[i]    <= {`AXI_DATA_WIDTH-M-N{1'b0}};
                    valid_array[i]  <= 1'b0;
                end
            end
            else begin
                if (!icache_flush) begin
                    case (mem_req_state)
                        MEM_REQ_IDLE: begin
                            if (state == MEM_REQ & !cache_hit) begin
                                mem_req_state <= MEM_REQ_ADDR;
                                fetch_arvalid <= 1'b1;
                            end
                        end
                        MEM_REQ_ADDR: begin
                            if (fetch_arvalid & fetch_arready) begin
                                mem_req_state <= MEM_REQ_WAIT;
                                fetch_arvalid <= 1'b0;
                                fetch_rready <= 1'b1;
                            end
                        end
                        MEM_REQ_WAIT: begin
                            if (fetch_rvalid) begin
                                mem_req_state <= MEM_REQ_DONE;
                                fetch_rready <= 1'b0;
                                data_array[index] <= fetch_rdata;
                            end
                        end
                        MEM_REQ_DONE: begin
                            mem_req_state <= MEM_REQ_IDLE;
                            tag_array[index] <= tag;
                            valid_array[index] <= 1'b1;
                        end
                        default: begin
                            mem_req_state <= MEM_REQ_IDLE;
                        end
                    endcase
                end
                else begin
                    // flush
                    for (i = 0; i < CACHE_LINE_COUNT; i = i + 1) begin
                        valid_array[i]  <= 1'b0;
                    end 
                end
            end
        end

    `else
        assign fetch_araddr         = raw_fetch_araddr;
        assign fetch_arvalid        = raw_fetch_arvalid;
        assign raw_fetch_arready    = fetch_arready;
        assign raw_fetch_rdata      = fetch_rdata;
        assign raw_fetch_rresp      = fetch_rresp;
        assign raw_fetch_rvalid     = fetch_rvalid;
        assign fetch_rready         = raw_fetch_rready;
    `endif


endmodule