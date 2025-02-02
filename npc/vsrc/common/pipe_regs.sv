module pipe_regs # (
    parameter DATA_WIDTH    = 32,
    parameter DATA_RESET    = 32'b0,
    parameter VALID_RESET   = 1'b0
) (
    input   logic clk,
    input   logic rst_n,

    // control path
    input   logic i_valid,
    output  logic i_ready,
    output  logic o_valid,
    input   logic o_ready,

    // data path
    input   logic [DATA_WIDTH-1:0] i_data,
    output  logic [DATA_WIDTH-1:0] o_data
);

    // -------------------- control path: state machine --------------------
    localparam STATE_BITS = 2;
    localparam [STATE_BITS-1:0] EMPTY = 'd0; // Output and buffer registers empty
    localparam [STATE_BITS-1:0] BUSY  = 'd1; // Output register holds data
    localparam [STATE_BITS-1:0] FULL  = 'd2; // Both output and buffer registers hold data
    // There is no case where only the buffer register would hold data.
    logic [STATE_BITS-1:0] state;
    logic [STATE_BITS-1:0] state_next;

    // ready reg
    always @ (posedge clk) begin
        if (!rst_n) begin
            i_ready <= 1'b1;
        end
        else begin
            i_ready <= (state_next != FULL);
        end
    end

    // valid reg
    always @ (posedge clk) begin
        if (!rst_n) begin
            o_valid <= VALID_RESET;
        end
        else begin
            o_valid <= (state_next != EMPTY);
        end
    end

    logic insert = (i_valid  == 1'b1) && (i_ready  == 1'b1);
    logic remove = (o_valid == 1'b1) && (o_ready == 1'b1);

    // reg load    = 1'b0; // Empty datapath inserts data into output register.
    // reg flow    = 1'b0; // New inserted data into output register as the old data is removed.
    // reg fill    = 1'b0; // New inserted data into buffer register. Data not removed from output register.
    // reg flush   = 1'b0; // Move data from buffer register into output register. Remove old data. No new data inserted.
    // reg unload  = 1'b0; // Remove data from output register, leaving the datapath empty.

    logic load    = (state == EMPTY) && (insert == 1'b1) && (remove == 1'b0);
    logic flow    = (state == BUSY)  && (insert == 1'b1) && (remove == 1'b1);
    logic fill    = (state == BUSY)  && (insert == 1'b1) && (remove == 1'b0);
    logic flush   = (state == FULL)  && (insert == 1'b0) && (remove == 1'b1);
    logic unload  = (state == BUSY)  && (insert == 1'b0) && (remove == 1'b1);

    always @ (*) begin
        state_next = EMPTY;
        state_next = (load   == 1'b1) ? BUSY  : state;
        state_next = (flow   == 1'b1) ? BUSY  : state_next;
        state_next = (fill   == 1'b1) ? FULL  : state_next;
        state_next = (flush  == 1'b1) ? BUSY  : state_next;
        state_next = (unload == 1'b1) ? EMPTY : state_next;
    end

    // state reg
    always @ (posedge clk) begin
        if (!rst_n) begin
            state <= EMPTY;
        end
        else begin
            state <= state_next;
        end
    end

    always @ (*) begin
        data_out_wren     = (load  == 1'b1) || (flow == 1'b1) || (flush == 1'b1);
        data_buffer_wren  = (fill  == 1'b1);
        use_buffered_data = (flush == 1'b1);
    end
    // -------------------- control path: state machine --------------------



    // ----------------------------- data path -----------------------------
    logic data_buffer_wren; // EMPTY at start, so don't load.
    logic [DATA_WIDTH-1:0] buffer_data;
    logic data_out_wren; // EMPTY at start, so accept data.
    logic use_buffered_data;
    logic [DATA_WIDTH-1:0] selected_data;

    // buffer reg
    always @ (posedge clk) begin
        if (!rst_n) begin
            buffer_data <= DATA_RESET;
        end
        else if (data_buffer_wren) begin
            buffer_data <= i_data;
        end
    end 
    // pipeline reg
    always @ (posedge clk) begin
        if (!rst_n) begin
            o_data <= DATA_RESET;
        end
        else if (data_out_wren) begin
            o_data <= selected_data;
        end
    end
    // select data out
    assign selected_data = use_buffered_data ? buffer_data : i_data;
    // ----------------------------- data path -----------------------------

endmodule
