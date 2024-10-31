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
		//
		// ACCESS_ALLOWED is a bit-wise mask indicating which slaves
		// may get access to the bus.  If ACCESS_ALLOWED[slave] is true,
		// then a master can connect to the slave via this method.  This
		// parameter is primarily here to support AXI (or other similar
		// buses) which may have separate accesses for both read and
		// write.  By using this, a read-only slave can be connected,
		// which would also naturally create an error on any attempt to
		// write to it.
		parameter	[NS-1:0]	ACCESS_ALLOWED = -1,
		//
		// If OPT_REGISTERED is set, address decoding will take an extra
		// clock, and will register the results of the decoding
		// operation.
		parameter [0:0]	OPT_REGISTERED = 0
	) (
		// {{{
		input	wire			i_clk, i_reset,
		//
		input	wire			i_valid,
		output	reg			o_stall,
		input	wire	[AW-1:0]	i_addr,
		input	wire	[DW-1:0]	i_data,
		//
		output	reg			o_valid,
		input	wire			i_stall,
		output	reg	[NS:0]		o_decode,
		output	reg	[AW-1:0]	o_addr,
		output	reg	[DW-1:0]	o_data
		// }}}
	);

	// Local declarations
	// {{{
	//
	// OPT_NONESEL controls whether or not the address lines are fully
	// proscribed, or whether or not a "no-slave identified" slave should
	// be created.  To avoid a "no-slave selected" output, slave zero must
	// have no mask bits set (and therefore no address bits set), and it
	// must also allow access.
	localparam [0:0] OPT_NONESEL = (!ACCESS_ALLOWED[0])
					|| (SLAVE_MASK[AW-1:0] != 0);
	//
	wire	[NS:0]		request;
	reg	[NS-1:0]	prerequest;
	integer			iM;
	// }}}

	// prerequest
	// {{{
	always @(*)
	for(iM=0; iM<NS; iM=iM+1)
		prerequest[iM] = (((i_addr ^ SLAVE_ADDR[iM*AW +: AW])
				&SLAVE_MASK[iM*AW +: AW])==0)
			&&(ACCESS_ALLOWED[iM]);
	// }}}

	// request
	//  {{{
	generate if (OPT_NONESEL)
	begin : NO_DEFAULT_REQUEST
		// {{{
		reg	[NS-1:0]	r_request;

		// Need to create a slave to describe when nothing is selected
		//
		always @(*)
		begin
			for(iM=0; iM<NS; iM=iM+1)
				r_request[iM] = i_valid && prerequest[iM];
			if (!OPT_NONESEL && (NS > 1 && |prerequest[NS-1:1]))
				r_request[0] = 1'b0;
		end

		assign	request[NS-1:0] = r_request;
		// }}}
	end else if (NS == 1)
	begin : SINGLE_SLAVE
		// {{{
		assign request[0] = i_valid;
		// }}}
	end else begin : GENERAL_CASE
		// {{{
		reg	[NS-1:0]	r_request;

		always @(*)
		begin
			for(iM=0; iM<NS; iM=iM+1)
				r_request[iM] = i_valid && prerequest[iM];
			if (!OPT_NONESEL && (NS > 1 && |prerequest[NS-1:1]))
				r_request[0] = 1'b0;
		end

		assign	request[NS-1:0] = r_request;
		// }}}
	end endgenerate
	// }}}

	// request[NS]
	// {{{
	generate if (OPT_NONESEL)
	begin : GENERATE_NONSEL_SLAVE
		reg	r_request_NS, r_none_sel;

		always @(*)
		begin
			// Let's assume nothing's been selected, and then check
			// to prove ourselves wrong.
			//
			// Note that none_sel will be considered an error
			// condition in the follow-on processing.  Therefore
			// it's important to clear it if no request is pending.
			r_none_sel = i_valid && (prerequest == 0);
			//
			// request[NS] indicates a request for a non-existent
			// slave.  A request that should (eventually) return a
			// bus error
			//
			r_request_NS = r_none_sel;
		end

		assign request[NS] = r_request_NS;
	end else begin : NO_NONESEL_SLAVE
		assign request[NS] = 1'b0;
	end endgenerate
	// }}}

	// o_valid, o_addr, o_data, o_decode, o_stall
	// {{{
	generate if (OPT_REGISTERED)
	begin : GEN_REG_OUTPUTS

		// o_valid
		// {{{
		initial	o_valid = 0;
		always @(posedge i_clk)
		if (i_reset)
			o_valid <= 0;
		else if (!o_stall)
			o_valid <= i_valid;
		// }}}

		// o_addr, o_data
		// {{{
		initial	o_addr   = 0;
		initial	o_data   = 0;
		always @(posedge i_clk)
		if (i_reset)
		begin
			o_addr   <= 0;
			o_data   <= 0;
		end else if ((!o_valid || !i_stall)
				 && (i_valid))
		begin
			o_addr   <= i_addr;
			o_data   <= i_data;
		end else if (!i_stall)
		begin
			o_addr   <= 0;
			o_data   <= 0;
		end
		// }}}

		// o_decode
		// {{{
		initial	o_decode = 0;
		always @(posedge i_clk)
		if (i_reset)
			o_decode <= 0;
		else if ((!o_valid || !i_stall)
				 && (i_valid))
			o_decode <= request;
		else if (!i_stall)
			o_decode <= 0;
		// }}}

		// o_stall
		// {{{
		always @(*)
			o_stall = (o_valid && i_stall);
		// }}}
	end else begin : GEN_COMBINATORIAL_OUTPUTS

		always @(*)
		begin
			o_valid = i_valid;
			o_stall = i_stall;
			o_addr  = i_addr;
			o_data  = i_data;

			o_decode = request;
		end

		// Make Verilator happy
		wire	unused;
		assign	unused = &{ 1'b0, i_reset };

	end endgenerate
endmodule
