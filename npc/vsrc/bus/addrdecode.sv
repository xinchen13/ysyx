module addrdecode #(
		parameter	NS = 8,
		parameter	AW = 32, DW=32+32/8+1+1,
		parameter	[NS*AW-1:0]	SLAVE_ADDR = {
				{ 3'b111,  {(AW-3){1'b0}} },
				{ 3'b110,  {(AW-3){1'b0}} },
				{ 3'b101,  {(AW-3){1'b0}} },
				{ 3'b100,  {(AW-3){1'b0}} },
				{ 3'b011,  {(AW-3){1'b0}} },
				{ 3'b010,  {(AW-3){1'b0}} },
				{ 4'b0010, {(AW-4){1'b0}} },
				{ 4'b0000, {(AW-4){1'b0}} }},
		parameter	[NS*AW-1:0]	SLAVE_MASK = (NS <= 1) ? 0
			: { {(NS-2){ 3'b111, {(AW-3){1'b0}} }},
				{(2){ 4'b1111, {(AW-4){1'b0}} }} },
		parameter	[NS-1:0]	ACCESS_ALLOWED = -1
) (

    input	wire			    i_clk, i_reset,
    input	wire			    i_valid,
    output	reg			        o_stall,
    input	wire	[AW-1:0]	i_addr,
    input	wire	[DW-1:0]	i_data,
    output	reg			        o_valid,
    input	wire			    i_stall,
    output	reg	    [NS:0]		o_decode,
    output	reg	    [AW-1:0]	o_addr,
    output	reg	    [DW-1:0]	o_data
);

	wire	[NS:0]		    request;
	reg	    [NS-1:0]	    prerequest;
	integer			        iM;

	// prerequest
	always @ (*) begin
        for(iM=0; iM<NS; iM=iM+1)
            prerequest[iM] = (((i_addr ^ SLAVE_ADDR[iM*AW +: AW])
                & SLAVE_MASK[iM*AW +: AW]) == 0)
                && (ACCESS_ALLOWED[iM]);
    end


	// request
	generate if (NS == 1)
	begin : SINGLE_SLAVE
		assign request[0] = i_valid;
	end 
    else begin : GENERAL_CASE
		reg	[NS-1:0]	r_request;
		always @(*)
		begin
			for(iM=0; iM<NS; iM=iM+1)
				r_request[iM] = i_valid && prerequest[iM];
			if ((NS > 1 && |prerequest[NS-1:1]))
				r_request[0] = 1'b0;
		end

		assign	request[NS-1:0] = r_request;
	end endgenerate

    assign request[NS] = 1'b0;

	generate
	begin : GEN_COMBINATORIAL_OUTPUTS
		always @(*)
		begin
			o_valid = i_valid;
			o_stall = i_stall;
			o_addr  = i_addr;
			o_data  = i_data;
			o_decode = request;
		end
	end endgenerate

endmodule
