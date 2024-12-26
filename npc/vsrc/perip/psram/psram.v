// import "DPI-C" function int psram_read(input int addr);
// import "DPI-C" function void psram_write(input int addr, input int data);

// reference: ../perip/flash/flash.v

module psram(
    input sck,
    input ce_n,
    inout [3:0] dio
);

    wire reset = ce_n;

    typedef enum [2:0] { cmd_t, addr_t, data_t, err_t } state_t;
    reg [2:0]  state;
    reg [7:0]  counter;
    reg [7:0]  cmd;
    reg [23:0] addr;
    reg [31:0] data;



endmodule
