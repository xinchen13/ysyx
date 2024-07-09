module encoder83 (
    input wire [7:0] din,
    input wire en,
    output reg [2:0] dout,
    output wire flag
);
    always @ (*) begin
        if (en) begin
            casez (din) 
                8'b00000001: dout = 3'b000;
                8'b0000001?: dout = 3'b001;
                8'b000001??: dout = 3'b010;
                8'b00001???: dout = 3'b011;
                8'b0001????: dout = 3'b100;
                8'b001?????: dout = 3'b101;
                8'b01??????: dout = 3'b110;
                8'b1???????: dout = 3'b111;
                default : dout = 3'b000;
            endcase
        end
        else begin
            dout = 3'b0;
        end
    end

    assign flag = en ? (|din) : 1'b0;

endmodule