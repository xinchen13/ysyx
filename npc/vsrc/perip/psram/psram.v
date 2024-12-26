// import "DPI-C" function int psram_read(input int addr);
// import "DPI-C" function void psram_write(input int addr, input int data);

// reference: ../perip/flash/flash.v

module psram(
    input sck,
    input ce_n,
    inout [3:0] dio
);

    wire reset = ce_n;

    typedef enum [2:0] { cmd_t, addr_t, wait_t, data_t, err_t } state_t;
    reg [2:0]  state;
    reg [7:0]  counter;
    reg [7:0]  cmd;
    reg [23:0] addr;
    reg [31:0] data;

    always@(posedge sck or posedge reset) begin
        if (reset) begin
            state <= cmd_t;
        end
        else begin
            case (state)
                cmd_t:  state <= (counter == 8'd7 ) ? addr_t : state;
                addr_t: state <= ((cmd != 8'hEB) && (cmd != 8'h38) ) ? err_t  :
                                (counter == 8'd5) ? wait_t : state;
                wait_t: state <= (counter == 8'd5) ? data_t : state;
                data_t: state <= state;

                default: begin
                    state <= state;
                    $write("Assertion failed: Unsupported command `%xh`, only support `03h` read command\n", cmd);
                    $fatal;
                end
            endcase
        end
    end



endmodule
