import "DPI-C" function int psram_read(input int addr);
import "DPI-C" function void psram_write(input int addr, input int data);

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
    reg [31:0] rdata;

    reg [3:0] dout;
    wire [3:0] din = dio;
    wire [3:0] douten = (state == read_t) ? 4'b1111 : 4'b0000;
    assign dio[0] = douten[0] ? dout[0] : 1'bz;
    assign dio[1] = douten[1] ? dout[1] : 1'bz;
    assign dio[2] = douten[2] ? dout[2] : 1'bz;
    assign dio[3] = douten[3] ? dout[3] : 1'bz;
    

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
            cmd <= {cmd[6:0], din[0]};
        end
    end

    always @ (posedge sck or posedge reset) begin
        if (reset) begin
            addr <= 24'd0;
        end
        else if (state == addr_t) begin
            addr <= {addr[19:0], din[3:0]}; // refer to $NPC_HOME/vsrc/perip/psram/efabless/EF_PSRAM_CTRL.v
        end
    end

    always @ (posedge sck or posedge reset) begin
        if (reset) begin
            rdata <= 32'd0;
        end
        else if ((state == wait_t) && (counter == 8'd4)) begin
            rdata <= psram_read({8'b0, addr});
        end
    end

    always @ (posedge sck or posedge reset) begin
        if (reset) begin
            dout <= 4'b0;
        end
        else if (state == read_t) begin
            case (counter)
                8'd0: dout <= rdata[7:4];
                8'd1: dout <= rdata[3:0];
                8'd2: dout <= rdata[15:12];
                8'd3: dout <= rdata[11:8];
                8'd4: dout <= rdata[23:20];
                8'd5: dout <= rdata[19:16];
                8'd6: dout <= rdata[31:28];
                8'd7: dout <= rdata[27:24];
                default: dout <= 4'b0;
            endcase
        end
    end



endmodule
