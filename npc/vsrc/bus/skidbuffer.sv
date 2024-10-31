module skidbuffer #(
	parameter	[0:0]	OPT_LOWPOWER = 0,
	parameter	[0:0]	OPT_OUTREG = 1,
	parameter		DW = 8
) (
	input	wire				i_clk, i_reset,
	input	wire				i_valid,
	output	wire				o_ready,
	input	wire	[DW-1:0]	i_data,
	output	wire				o_valid,
	input	wire				i_ready,
	output	reg		[DW-1:0]	o_data
);

	wire	[DW-1:0]	w_data;

	// real skid buffer
	reg					r_valid;
	reg		[DW-1:0]	r_data;

	// r_valid
	always @ (posedge i_clk) begin
		if (i_reset)
			r_valid <= 0;
		else if ((i_valid && o_ready) && (o_valid && !i_ready))
			// We have incoming data, but the output is stalled
			r_valid <= 1;
		else if (i_ready)
			r_valid <= 0;
	end

	// r_data
	always @ (posedge i_clk)
	if (i_reset)
		r_data <= 0;
	else if (OPT_LOWPOWER && (!o_valid || i_ready))
		r_data <= 0;
	else if ((!OPT_LOWPOWER || !OPT_OUTREG || i_valid) && o_ready)
		r_data <= i_data;

	assign	w_data = r_data;

	// o_ready
	assign o_ready = !r_valid;

	// And then move on to the output port

	// Outputs are combinatorially determined from inputs
	// o_valid
	assign	o_valid = !i_reset && (i_valid || r_valid);

	// o_data
	always @(*)
	if (r_valid)
		o_data = r_data;
	else if (!OPT_LOWPOWER || i_valid)
		o_data = i_data;
	else
		o_data = 0;


endmodule