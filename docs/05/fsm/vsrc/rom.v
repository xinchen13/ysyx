module rom (
    input wire [7:0] scan_code,
    output reg [7:0] ascii_code 
);  
   always @ (*) begin
        case (scan_code)
            // to be continued
            8'h1c: ascii_code = 8'd65; // A
            8'h15: ascii_code = 8'd81; // Q
            8'h45: ascii_code = 8'd32; // 0
            8'h16: ascii_code = 8'd33; // 1
            8'h1e: ascii_code = 8'd34; // 2
            8'h26: ascii_code = 8'd35; // 3
            8'h25: ascii_code = 8'd36; // 4
            8'h2e: ascii_code = 8'd37; // 5
            8'h36: ascii_code = 8'd38; // 6
            8'h3d: ascii_code = 8'd39; // 7
            8'h3e: ascii_code = 8'd40; // 8
            8'h46: ascii_code = 8'd41; // 9
            default: ascii_code = 8'bxxxxxxxx;
        endcase
   end

endmodule