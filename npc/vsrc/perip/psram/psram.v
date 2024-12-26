// import "DPI-C" function int psram_read(input int addr);
// import "DPI-C" function void psram_write(input int addr, input int data);

// reference: ../perip/flash/flash.v

module psram(
    input sck,
    input ce_n,
    inout [3:0] dio
);

    wire reset = ce_n;

    typedef enum [2:0] {cmd_t, addr_t, wait_t, read_t, write_t, err_t } state_t;
    reg [2:0]  state;
    reg [7:0]  counter;
    reg [7:0]  cmd;
    reg [23:0] addr;
    reg [31:0] data;

    always @ (posedge sck or posedge reset) begin
        if (reset) begin
            state <= cmd_t;
        end
        else begin
            case (state)
                cmd_t:  state <= (counter == 8'd7 ) ? addr_t : state;
                addr_t: state <= (counter == 8'd5) ? (cmd == 8'hEB ? wait_t : cmd == 8'h38 ? write_t : err_t) : state;
                wait_t: state <= (counter == 8'd5) ? read_t : state;
                read_t: state <= state;
                write_t: state <= state;

                default: begin
                    state <= state;
                    $write("Assertion failed: Unsupported command `%xh`, only support `03h` read command\n", cmd);
                    $fatal;
                end
            endcase
        end
    end

    always @ (posedge sck or posedge reset) begin
        if (reset) begin 
            counter <= 8'd0;
        end
        else begin
            case (state)
                cmd_t:      counter <= (counter < 8'd7) ? counter + 8'd1 : 8'd0;
                addr_t:     counter <= (counter < 8'd5) ? counter + 8'd1 : 8'd0;
                wait_t:     counter <= (counter < 8'd5) ? counter + 8'b1 : 8'd0;
                default:    counter <= counter + 8'd1;
            endcase
        end
    end

    always @ (posedge sck or posedge reset) begin
        if (reset) begin
            cmd <= 8'd0;
        end
        else if (state == cmd_t) begin
            cmd <= {cmd[6:0], dio[0]};
        end
    end

    always @ (posedge sck or posedge reset) begin
        if (reset) begin
            addr <= 24'd0;
        end
        else if (state == addr_t) begin
            addr <= {addr[19:0], dio[3:0]}; // refer to $NPC_HOME/vsrc/perip/psram/efabless/EF_PSRAM_CTRL.v
        end
    end



endmodule
