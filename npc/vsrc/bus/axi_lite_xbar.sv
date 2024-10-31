module axi_lite_xbar #(
	parameter integer C_AXI_DATA_WIDTH = 32,
	parameter integer C_AXI_ADDR_WIDTH = 32,
	localparam	AW = C_AXI_ADDR_WIDTH,
	localparam	DW = C_AXI_DATA_WIDTH,
	parameter	NM = 2,
	parameter	NS = 3,
	parameter	[NS*AW-1:0]	SLAVE_ADDR = {
		3'b111,  {(AW-3){1'b0}},
		3'b110,  {(AW-3){1'b0}},
		3'b101,  {(AW-3){1'b0}},
		3'b100,  {(AW-3){1'b0}},
		3'b011,  {(AW-3){1'b0}},
		3'b010,  {(AW-3){1'b0}},
		4'b0001, {(AW-4){1'b0}},
		4'b0000, {(AW-4){1'b0}} 
	},
	parameter	[NS*AW-1:0]	SLAVE_MASK =
		(NS <= 1) ? { 4'b1111, {(AW-4){1'b0}} }
		: { {(NS-2){ 3'b111, {(AW-3){1'b0}} }},
			{(2){ 4'b1111, {(AW-4){1'b0}} }} },

	parameter [0:0]	OPT_LOWPOWER = 1,
	parameter	OPT_LINGER = 4,
	parameter	LGMAXBURST = 5
) (
	input	wire	S_AXI_ACLK,
	input	wire	S_AXI_ARESETN,
	// Incoming AXI4-lite slave port(s)
	input	wire	[NM-1:0]			S_AXI_AWVALID,
	output	wire	[NM-1:0]			S_AXI_AWREADY,
	input	wire	[NM*C_AXI_ADDR_WIDTH-1:0]	S_AXI_AWADDR,
	input	wire	[NM*3-1:0]			S_AXI_AWPROT,

	input	wire	[NM-1:0]			S_AXI_WVALID,
	output	wire	[NM-1:0]			S_AXI_WREADY,
	input	wire	[NM*C_AXI_DATA_WIDTH-1:0]	S_AXI_WDATA,
	input	wire	[NM*C_AXI_DATA_WIDTH/8-1:0]	S_AXI_WSTRB,

	output	wire	[NM-1:0]			S_AXI_BVALID,
	input	wire	[NM-1:0]			S_AXI_BREADY,
	output	wire	[NM*2-1:0]			S_AXI_BRESP,

	input	wire	[NM-1:0]			S_AXI_ARVALID,
	output	wire	[NM-1:0]			S_AXI_ARREADY,
	input	wire	[NM*C_AXI_ADDR_WIDTH-1:0]	S_AXI_ARADDR,
	input	wire	[NM*3-1:0]			S_AXI_ARPROT,

	output	wire	[NM-1:0]			S_AXI_RVALID,
	input	wire	[NM-1:0]			S_AXI_RREADY,
	output	wire	[NM*C_AXI_DATA_WIDTH-1:0]	S_AXI_RDATA,
	output	wire	[NM*2-1:0]			S_AXI_RRESP,

	// Outgoing AXI4-lite master port(s)
	output	wire	[NS*C_AXI_ADDR_WIDTH-1:0]	M_AXI_AWADDR,
	output	wire	[NS*3-1:0]			M_AXI_AWPROT,
	output	wire	[NS-1:0]			M_AXI_AWVALID,
	input	wire	[NS-1:0]			M_AXI_AWREADY,

	output	wire	[NS*C_AXI_DATA_WIDTH-1:0]	M_AXI_WDATA,
	output	wire	[NS*C_AXI_DATA_WIDTH/8-1:0]	M_AXI_WSTRB,
	output	wire	[NS-1:0]			M_AXI_WVALID,
	input	wire	[NS-1:0]			M_AXI_WREADY,

	input	wire	[NS*2-1:0]			M_AXI_BRESP,
	input	wire	[NS-1:0]			M_AXI_BVALID,
	output	wire	[NS-1:0]			M_AXI_BREADY,

	output	wire	[NS*C_AXI_ADDR_WIDTH-1:0]	M_AXI_ARADDR,
	output	wire	[NS*3-1:0]			M_AXI_ARPROT,
	output	wire	[NS-1:0]			M_AXI_ARVALID,
	input	wire	[NS-1:0]			M_AXI_ARREADY,

	input	wire	[NS*C_AXI_DATA_WIDTH-1:0]	M_AXI_RDATA,
	input	wire	[NS*2-1:0]			M_AXI_RRESP,
	input	wire	[NS-1:0]			M_AXI_RVALID,
	output	wire	[NS-1:0]			M_AXI_RREADY
);

	localparam	LGLINGER = (OPT_LINGER>1) ? $clog2(OPT_LINGER+1) : 1;
	localparam	LGNM = (NM>1) ? $clog2(NM) : 1;
	localparam	LGNS = (NS>1) ? $clog2(NS+1) : 1;
	// In order to use indexes, and hence fully balanced mux trees, it helps
	// to make certain that we have a power of two based lookup.  NMFULL
	// is the number of masters in this lookup, with potentially some
	// unused extra ones.  NSFULL is defined similarly.
	localparam	NMFULL = (NM>1) ? (1<<LGNM) : 1;
	localparam	NSFULL = (NS>1) ? (1<<LGNS) : 2;
	localparam [1:0] INTERCONNECT_ERROR = 2'b11;
	localparam [0:0] OPT_SKID_INPUT = 0;

	genvar	N,M;
	integer	iN, iM;

	reg	[NSFULL-1:0]	wrequest		[0:NM-1];
	reg	[NSFULL-1:0]	rrequest		[0:NM-1];
	reg	[NSFULL-1:0]	wrequested		[0:NM];
	reg	[NSFULL-1:0]	rrequested		[0:NM];
	reg	[NS:0]		wgrant			[0:NM-1];
	reg	[NS:0]		rgrant			[0:NM-1];
	reg	[NM-1:0]	swgrant;
	reg	[NM-1:0]	srgrant;
	reg	[NS-1:0]	mwgrant;
	reg	[NS-1:0]	mrgrant;

	wire	[LGMAXBURST-1:0]	w_sawpending	[0:NM-1];
	wire	[LGMAXBURST-1:0]	w_srpending	[0:NM-1];

	reg	[NM-1:0]		swfull;
	reg	[NM-1:0]		srfull;
	reg	[NM-1:0]		swempty;
	reg	[NM-1:0]		srempty;

	wire	[LGNS-1:0]		swindex	[0:NMFULL-1];
	wire	[LGNS-1:0]		srindex	[0:NMFULL-1];
	wire	[LGNM-1:0]		mwindex	[0:NSFULL-1];
	wire	[LGNM-1:0]		mrindex	[0:NSFULL-1];

	wire	[NM-1:0]		wdata_expected;

	// The shadow buffers
	wire	[NMFULL-1:0]	m_awvalid, m_wvalid, m_arvalid;
	wire	[NM-1:0]	dcd_awvalid, dcd_arvalid;

	wire	[C_AXI_ADDR_WIDTH-1:0]		m_awaddr	[0:NMFULL-1];
	wire	[2:0]				m_awprot	[0:NMFULL-1];
	wire	[C_AXI_DATA_WIDTH-1:0]		m_wdata		[0:NMFULL-1];
	wire	[C_AXI_DATA_WIDTH/8-1:0]	m_wstrb		[0:NMFULL-1];

	wire	[C_AXI_ADDR_WIDTH-1:0]		m_araddr	[0:NMFULL-1];
	wire	[2:0]				m_arprot	[0:NMFULL-1];

	wire	[NM-1:0]	skd_awvalid, skd_awstall, skd_wvalid;
	wire	[NM-1:0]	skd_arvalid, skd_arstall;
	wire	[AW-1:0]	skd_awaddr			[0:NM-1];
	wire	[3-1:0]		skd_awprot			[0:NM-1];
	wire	[AW-1:0]	skd_araddr			[0:NM-1];
	wire	[3-1:0]		skd_arprot			[0:NM-1];

	reg	[NM-1:0]	r_bvalid;
	reg	[1:0]		r_bresp		[0:NM-1];

	reg	[NSFULL-1:0]	m_axi_awvalid;
	reg	[NSFULL-1:0]	m_axi_awready;
	reg	[NSFULL-1:0]	m_axi_wvalid;
	reg	[NSFULL-1:0]	m_axi_wready;
	reg	[NSFULL-1:0]	m_axi_bvalid;
	reg	[1:0]		m_axi_bresp	[0:NSFULL-1];

	reg	[NSFULL-1:0]	m_axi_arvalid;
	reg	[NSFULL-1:0]	m_axi_arready;
	reg	[NSFULL-1:0]	m_axi_rvalid;
	reg	[NSFULL-1:0]	m_axi_rready;

	reg	[NM-1:0]	r_rvalid;
	reg	[1:0]		r_rresp		[0:NM-1];
	reg	[DW-1:0]	r_rdata		[0:NM-1];

	reg	[DW-1:0]	m_axi_rdata	[0:NSFULL-1];
	reg	[1:0]		m_axi_rresp	[0:NSFULL-1];

	reg	[NM-1:0]	slave_awaccepts;
	reg	[NM-1:0]	slave_waccepts;
	reg	[NM-1:0]	slave_raccepts;

	always @(*)
	begin
		m_axi_awvalid = -1;
		m_axi_awready = -1;
		m_axi_wvalid = -1;
		m_axi_wready = -1;
		m_axi_bvalid = 0;

		m_axi_awvalid[NS-1:0] = M_AXI_AWVALID;
		m_axi_awready[NS-1:0] = M_AXI_AWREADY;
		m_axi_wvalid[NS-1:0]  = M_AXI_WVALID;
		m_axi_wready[NS-1:0]  = M_AXI_WREADY;
		m_axi_bvalid[NS-1:0]  = M_AXI_BVALID;

		for(iM=0; iM<NS; iM=iM+1)
		begin
			m_axi_bresp[iM] = M_AXI_BRESP[iM* 2 +:  2];

			m_axi_rdata[iM] = M_AXI_RDATA[iM*DW +: DW];
			m_axi_rresp[iM] = M_AXI_RRESP[iM* 2 +:  2];
		end
		for(iM=NS; iM<NSFULL; iM=iM+1)
		begin
			m_axi_bresp[iM] = INTERCONNECT_ERROR;

			m_axi_rdata[iM] = 0;
			m_axi_rresp[iM] = INTERCONNECT_ERROR;
		end

	end

	generate for(N=0; N<NM; N=N+1)
	begin : DECODE_WRITE_REQUEST

		wire	[NS:0]		wdecode;
		reg	r_mawvalid, r_mwvalid;

		// awskid
		skidbuffer #(
			.DW(AW+3), .OPT_OUTREG(OPT_SKID_INPUT)
		) awskid(
			.i_clk(S_AXI_ACLK), .i_reset(!S_AXI_ARESETN),
			.i_valid(S_AXI_AWVALID[N]), .o_ready(S_AXI_AWREADY[N]),
			.i_data({ S_AXI_AWADDR[N*AW +: AW], S_AXI_AWPROT[N*3 +: 3] }),
			.o_valid(skd_awvalid[N]), .i_ready(!skd_awstall[N]),
				.o_data({ skd_awaddr[N], skd_awprot[N] })

		);

		// write address decoding
		addrdecode #(
			.AW(AW), .DW(3), .NS(NS),
			.SLAVE_ADDR(SLAVE_ADDR),
			.SLAVE_MASK(SLAVE_MASK)
		) wraddr(
			.i_clk(S_AXI_ACLK), .i_reset(!S_AXI_ARESETN),
			.i_valid(skd_awvalid[N]), .o_stall(skd_awstall[N]),
				.i_addr(skd_awaddr[N]), .i_data(skd_awprot[N]),
			.o_valid(dcd_awvalid[N]),
				.i_stall(!dcd_awvalid[N]||!slave_awaccepts[N]),
				.o_decode(wdecode), .o_addr(m_awaddr[N]),
				.o_data(m_awprot[N])
		);

		// wskid

		skidbuffer #(
			.DW(DW+DW/8), .OPT_OUTREG(OPT_SKID_INPUT)
		) wskid (
			.i_clk(S_AXI_ACLK), .i_reset(!S_AXI_ARESETN),
			.i_valid(S_AXI_WVALID[N]), .o_ready(S_AXI_WREADY[N]),
				.i_data({ S_AXI_WDATA[N*DW +: DW],
						S_AXI_WSTRB[N*DW/8 +: DW/8]}),
			.o_valid(skd_wvalid[N]),
				.i_ready(m_wvalid[N] && slave_waccepts[N]),
				.o_data({ m_wdata[N], m_wstrb[N] })
		);

		// slave_awaccepts
		always @(*)
		begin
			slave_awaccepts[N] = 1'b1;
			if (!swgrant[N])
				slave_awaccepts[N] = 1'b0;
			if (swfull[N])
				slave_awaccepts[N] = 1'b0;
			if (!wrequest[N][swindex[N]])
				slave_awaccepts[N] = 1'b0;
			if (!wgrant[N][NS]&&(m_axi_awvalid[swindex[N]] && !m_axi_awready[swindex[N]]))
				slave_awaccepts[N] = 1'b0;
			// ERRORs are always accepted
			//	back pressure is handled in the write side
		end

		// slave_waccepts
		always @(*)
		begin
			slave_waccepts[N] = 1'b1;
			if (!swgrant[N])
				slave_waccepts[N] = 1'b0;
			if (!wdata_expected[N])
				slave_waccepts[N] = 1'b0;
			if (!wgrant[N][NS] &&(m_axi_wvalid[swindex[N]]
						&& !m_axi_wready[swindex[N]]))
				slave_waccepts[N] = 1'b0;
			if (wgrant[N][NS]&&(S_AXI_BVALID[N]&& !S_AXI_BREADY[N]))
				slave_waccepts[N] = 1'b0;
		end

		// r_mawvalid, r_mwvalid
		always @(*)
		begin
			r_mawvalid= dcd_awvalid[N] && !swfull[N];
			r_mwvalid = skd_wvalid[N];
			wrequest[N]= 0;
			if (!swfull[N])
				wrequest[N][NS:0] = wdecode;
		end

		assign	m_awvalid[N] = r_mawvalid;
		assign	m_wvalid[N] = r_mwvalid;

	end for (N=NM; N<NMFULL; N=N+1)
	begin : UNUSED_WSKID_BUFFERS
		// {{{
		assign	m_awvalid[N] = 0;
		assign	m_awaddr[N] = 0;
		assign	m_awprot[N] = 0;
		assign	m_wdata[N] = 0;
		assign	m_wstrb[N] = 0;
		// }}}
	end endgenerate

	generate for(N=0; N<NM; N=N+1)
	begin : DECODE_READ_REQUEST
		wire	[NS:0]		rdecode;
		reg	r_marvalid;

		// arskid
		skidbuffer #(
			.DW(AW+3), .OPT_OUTREG(OPT_SKID_INPUT)
		) arskid(
			.i_clk(S_AXI_ACLK), .i_reset(!S_AXI_ARESETN),
			.i_valid(S_AXI_ARVALID[N]), .o_ready(S_AXI_ARREADY[N]),
			.i_data({ S_AXI_ARADDR[N*AW +: AW], S_AXI_ARPROT[N*3 +: 3] }),
			.o_valid(skd_arvalid[N]), .i_ready(!skd_arstall[N]),
				.o_data({ skd_araddr[N], skd_arprot[N] })
		);

		// Read address decoding
		addrdecode #(
			.AW(AW), .DW(3), .NS(NS),
			.SLAVE_ADDR(SLAVE_ADDR), .SLAVE_MASK(SLAVE_MASK)
		) rdaddr(
			.i_clk(S_AXI_ACLK), .i_reset(!S_AXI_ARESETN),
			.i_valid(skd_arvalid[N]), .o_stall(skd_arstall[N]),
				.i_addr(skd_araddr[N]), .i_data(skd_arprot[N]),
			.o_valid(dcd_arvalid[N]),
				.i_stall(!m_arvalid[N] || !slave_raccepts[N]),
				.o_decode(rdecode), .o_addr(m_araddr[N]),
				.o_data(m_arprot[N])
		);

		// r_marvalid -> m_arvalid[N]
		always @(*)
		begin
			r_marvalid = dcd_arvalid[N] && !srfull[N];
			rrequest[N] = 0;
			if (!srfull[N])
				rrequest[N][NS:0] = rdecode;
		end

		assign	m_arvalid[N] = r_marvalid;

		// slave_raccepts
		always @(*)
		begin
			slave_raccepts[N] = 1'b1;
			if (!srgrant[N])
				slave_raccepts[N] = 1'b0;
			if (srfull[N])
				slave_raccepts[N] = 1'b0;
			if (!rrequest[N][srindex[N]])
				slave_raccepts[N] = 1'b0;
			if (!rgrant[N][NS])
			begin
				if (m_axi_arvalid[srindex[N]] && !m_axi_arready[srindex[N]])
					slave_raccepts[N] = 1'b0;
			end else if (S_AXI_RVALID[N] && !S_AXI_RREADY[N])
				slave_raccepts[N] = 1'b0;
		end

	end for (N=NM; N<NMFULL; N=N+1)
	begin : UNUSED_RSKID_BUFFERS
		assign	m_arvalid[N] = 0;
		assign	m_araddr[N] = 0;
		assign	m_arprot[N] = 0;
	end endgenerate

	// wrequested
	always @(*)
	begin : DECONFLICT_WRITE_REQUESTS

		for(iN=1; iN<NM ; iN=iN+1)
			wrequested[iN] = 0;

		// Vivado may complain about too many bits for wrequested.
		// This is (currrently) expected.  swindex is used to index
		// into wrequested, and swindex has LGNS bits, where LGNS
		// is $clog2(NS+1) rather than $clog2(NS).  The extra bits
		// are defined to be zeros, but the point is there are defined.
		// Therefore, no matter what swindex is, it will always
		// reference something valid.
		wrequested[NM] = 0;

		for(iM=0; iM<NS; iM=iM+1)
		begin
			wrequested[0][iM] = 1'b0;
			for(iN=1; iN<NM ; iN=iN+1)
			begin
				// Continue to request any channel with
				// a grant and pending operations
				if (wrequest[iN-1][iM] && wgrant[iN-1][iM])
					wrequested[iN][iM] = 1;
				if (wrequest[iN-1][iM] && (!swgrant[iN-1]||swempty[iN-1]))
					wrequested[iN][iM] = 1;
				// Otherwise, if it's already claimed, then
				// it can't be claimed again
				if (wrequested[iN-1][iM])
					wrequested[iN][iM] = 1;
			end
			wrequested[NM][iM] = wrequest[NM-1][iM] || wrequested[NM-1][iM];
		end
	end

	// rrequested
	always @(*)
	begin : DECONFLICT_READ_REQUESTS

		for(iN=0; iN<NM ; iN=iN+1)
			rrequested[iN] = 0;

		// See the note above for wrequested.  This applies to
		// rrequested as well.
		rrequested[NM] = 0;

		for(iM=0; iM<NS; iM=iM+1)
		begin
			rrequested[0][iM] = 0;
			for(iN=1; iN<NM ; iN=iN+1)
			begin
				// Continue to request any channel with
				// a grant and pending operations
				if (rrequest[iN-1][iM] && rgrant[iN-1][iM])
					rrequested[iN][iM] = 1;
				if (rrequest[iN-1][iM] && (!srgrant[iN-1] || srempty[iN-1]))
					rrequested[iN][iM] = 1;
				// Otherwise, if it's already claimed, then
				// it can't be claimed again
				if (rrequested[iN-1][iM])
					rrequested[iN][iM] = 1;
			end
			rrequested[NM][iM] = rrequest[NM-1][iM] || rrequested[NM-1][iM];
		end
	end

	// mwgrant, mrgrant
	generate for(M=0; M<NS; M=M+1)
	begin : GEN_GRANT
		initial	mwgrant[M] = 0;
		always @(*)
		begin
			mwgrant[M] = 0;
			for(iN=0; iN<NM; iN=iN+1)
			if (wgrant[iN][M])
				mwgrant[M] = 1;
		end

		always @(*)
		begin
			mrgrant[M] = 0;
			for(iN=0; iN<NM; iN=iN+1)
			if (rgrant[iN][M])
				mrgrant[M] = 1;
		end
	end endgenerate

	generate for(N=0; N<NM; N=N+1)
	begin : ARBITRATE_WRITE_REQUESTS
		// Declarations
		reg			stay_on_channel;
		reg			requested_channel_is_available;
		reg			leave_channel;
		reg	[LGNS-1:0]	requested_index;
		wire			linger;

		// stay_on_channel
		always @(*)
		begin
			stay_on_channel = |(wrequest[N][NS:0] & wgrant[N]);

			if (swgrant[N] && !swempty[N])
				stay_on_channel = 1;
		end

		// requested_channel_is_available
		always @(*)
		begin
			requested_channel_is_available =
				|(wrequest[N][NS-1:0] & ~mwgrant
						& ~wrequested[N][NS-1:0]);
			if (wrequest[N][NS])
				requested_channel_is_available = 1;

			if (NM < 2)
				requested_channel_is_available = m_awvalid[N];
		end

		if (OPT_LINGER == 0)
		begin : NO_LINGER
			assign	linger = 0;
		end else begin : WRITE_LINGER
			reg [LGLINGER-1:0]	linger_counter;
			reg			r_linger;

			initial	r_linger = 0;
			initial	linger_counter = 0;
			always @(posedge S_AXI_ACLK)
			if (!S_AXI_ARESETN || wgrant[N][NS])
			begin
				r_linger <= 0;
				linger_counter <= 0;
			end else if (!swempty[N] || S_AXI_BVALID[N])
			begin
				linger_counter <= OPT_LINGER;
				r_linger <= 1;
			end else if (linger_counter > 0)
			begin
				r_linger <= (linger_counter > 1);
				linger_counter <= linger_counter - 1;
			end else
				r_linger <= 0;

			assign	linger = r_linger;
		end

		// leave_channel
		always @(*)
		begin
			leave_channel = 0;
			if (!m_awvalid[N]
				&& (!linger || wrequested[NM][swindex[N]]))
				// Leave the channel after OPT_LINGER counts
				// of the channel being idle, or when someone
				// else asks for the channel
				leave_channel = 1;
			if (m_awvalid[N] && !wrequest[N][swindex[N]])
				// Need to leave this channel to connect
				// to any other channel
				leave_channel = 1;
		end

		// wgrant, swgrant
		initial	wgrant[N]  = 0;
		initial	swgrant[N] = 0;
		always @(posedge S_AXI_ACLK)
		if (!S_AXI_ARESETN)
		begin
			wgrant[N]  <= 0;
			swgrant[N] <= 0;
		end else if (!stay_on_channel)
		begin
			if (requested_channel_is_available)
			begin
				// Switching channels
				swgrant[N] <= 1'b1;
				wgrant[N]  <= wrequest[N][NS:0];
			end else if (leave_channel)
			begin
				swgrant[N] <= 1'b0;
				wgrant[N]  <= 0;
			end
		end

		// requested_index
		always @(wrequest[N])
		begin
			requested_index = 0;
			for(iM=0; iM<=NS; iM=iM+1)
			if (wrequest[N][iM])
				requested_index= requested_index | iM[LGNS-1:0];
		end

		// Now for swindex
		reg	[LGNS-1:0]	r_swindex;

		initial	r_swindex = 0;
		always @(posedge S_AXI_ACLK)
		if (!stay_on_channel && requested_channel_is_available)
			r_swindex <= requested_index;

		assign	swindex[N] = r_swindex;

	end for (N=NM; N<NMFULL; N=N+1)
	begin : EMPTY_WRITE_REQUEST
		assign	swindex[N] = 0;
	end endgenerate

	generate for(N=0; N<NM; N=N+1)
	begin : ARBITRATE_READ_REQUESTS
		// Declarations
		reg			stay_on_channel;
		reg			requested_channel_is_available;
		reg			leave_channel;
		reg	[LGNS-1:0]	requested_index;
		wire			linger;

		// stay_on_channel
		always @(*)
		begin
			stay_on_channel = |(rrequest[N][NS:0] & rgrant[N]);

			if (srgrant[N] && !srempty[N])
				stay_on_channel = 1;
		end

		// requested_channel_is_available
		always @(*)
		begin
			requested_channel_is_available =
				|(rrequest[N][NS-1:0] & ~mrgrant
						& ~rrequested[N][NS-1:0]);
			if (rrequest[N][NS])
				requested_channel_is_available = 1;

			if (NM < 2)
				requested_channel_is_available = m_arvalid[N];
		end

		if (OPT_LINGER == 0)
		begin : NO_LINGER
			assign	linger = 0;
		end else begin : READ_LINGER
			reg [LGLINGER-1:0]	linger_counter;
			reg			r_linger;

			initial	r_linger = 0;
			initial	linger_counter = 0;
			always @(posedge S_AXI_ACLK)
			if (!S_AXI_ARESETN || rgrant[N][NS])
			begin
				r_linger <= 0;
				linger_counter <= 0;
			end else if (!srempty[N] || S_AXI_RVALID[N])
			begin
				linger_counter <= OPT_LINGER;
				r_linger <= 1;
			end else if (linger_counter > 0)
			begin
				r_linger <= (linger_counter > 1);
				linger_counter <= linger_counter - 1;
			end else
				r_linger <= 0;

			assign	linger = r_linger;
		end

		// leave_channel
		always @(*)
		begin
			leave_channel = 0;
			if (!m_arvalid[N]
				&& (!linger || rrequested[NM][srindex[N]]))
				// Leave the channel after OPT_LINGER counts
				// of the channel being idle, or when someone
				// else asks for the channel
				leave_channel = 1;
			if (m_arvalid[N] && !rrequest[N][srindex[N]])
				// Need to leave this channel to connect
				// to any other channel
				leave_channel = 1;
		end

		// rgrant, srgrant
		// {{{
		initial	rgrant[N]  = 0;
		initial	srgrant[N] = 0;
		always @(posedge S_AXI_ACLK)
		if (!S_AXI_ARESETN)
		begin
			rgrant[N]  <= 0;
			srgrant[N] <= 0;
		end else if (!stay_on_channel)
		begin
			if (requested_channel_is_available)
			begin
				// Switching channels
				srgrant[N] <= 1'b1;
				rgrant[N] <= rrequest[N][NS:0];
			end else if (leave_channel)
			begin
				srgrant[N] <= 1'b0;
				rgrant[N]  <= 0;
			end
		end
		// }}}

		// requested_index
		// {{{
		always @(rrequest[N])
		begin
			requested_index = 0;
			for(iM=0; iM<=NS; iM=iM+1)
			if (rrequest[N][iM])
				requested_index = requested_index|iM[LGNS-1:0];
		end
		// }}}

		// Now for srindex
		// {{{
		reg	[LGNS-1:0]	r_srindex;

		initial	r_srindex = 0;
		always @(posedge S_AXI_ACLK)
		if (!stay_on_channel && requested_channel_is_available)
			r_srindex <= requested_index;

		assign	srindex[N] = r_srindex;
		// }}}
		// }}}
	end for (N=NM; N<NMFULL; N=N+1)
	begin : EMPTY_READ_REQUEST
		// {{{
		assign	srindex[N] = 0;
		// }}}
	end endgenerate

	// Calculate mwindex
	generate for (M=0; M<NS; M=M+1)
	begin : SLAVE_WRITE_INDEX
		// {{{
		if (NM <= 1)
		begin : ONE_MASTER
			// {{{
			assign mwindex[M] = 0;
			// }}}
		end else begin : MULTIPLE_MASTERS
			// {{{
			reg [LGNM-1:0]		reswindex;
			reg	[LGNM-1:0]	r_mwindex;

			always @(*)
			begin
				reswindex = 0;
			for(iN=0; iN<NM; iN=iN+1)
			if ((!swgrant[iN] || swempty[iN])
				&&(wrequest[iN][M] && !wrequested[iN][M]))
					reswindex = reswindex | iN[LGNM-1:0];
			end

			always @(posedge S_AXI_ACLK)
			if (!mwgrant[M])
				r_mwindex <= reswindex;

			assign	mwindex[M] = r_mwindex;
			// }}}
		end
		// }}}
	end for (M=NS; M<NSFULL; M=M+1)
	begin : NO_WRITE_INDEX
		// {{{
		assign	mwindex[M] = 0;
		// }}}
	end endgenerate

	// Calculate mrindex
	generate for (M=0; M<NS; M=M+1)
	begin : SLAVE_READ_INDEX
		// {{{
		if (NM <= 1)
		begin : ONE_MASTER
			// {{{
			assign mrindex[M] = 0;
			// }}}
		end else begin : MULTIPLE_MASTERS
			// {{{
			reg [LGNM-1:0]	resrindex;
			reg [LGNM-1:0]	r_mrindex;

			always @(*)
			begin
				resrindex = 0;
			for(iN=0; iN<NM; iN=iN+1)
			if ((!srgrant[iN] || srempty[iN])
				&&(rrequest[iN][M] && !rrequested[iN][M]))
					resrindex = resrindex | iN[LGNM-1:0];
			end

			always @(posedge S_AXI_ACLK)
			if (!mrgrant[M])
				r_mrindex <= resrindex;

			assign	mrindex[M] = r_mrindex;
			// }}}
		end
		// }}}
	end for (M=NS; M<NSFULL; M=M+1)
	begin : NO_READ_INDEX
		// {{{
		assign	mrindex[M] = 0;
		// }}}
	end endgenerate

	// Assign outputs to the various slaves
	generate for(M=0; M<NS; M=M+1)
	begin : WRITE_SLAVE_OUTPUTS
		// {{{

		// Declarations
		// {{{
		reg			axi_awvalid;
		reg	[AW-1:0]	axi_awaddr;
		reg	[2:0]		axi_awprot;

		reg			axi_wvalid;
		reg	[DW-1:0]	axi_wdata;
		reg	[DW/8-1:0]	axi_wstrb;
		//
		reg			axi_bready;

		wire	sawstall, swstall, mbstall;
		// }}}
		assign	sawstall= (M_AXI_AWVALID[M]&& !M_AXI_AWREADY[M]);
		assign	swstall = (M_AXI_WVALID[M] && !M_AXI_WREADY[M]);
		assign	mbstall = (S_AXI_BVALID[mwindex[M]] && !S_AXI_BREADY[mwindex[M]]);

		// axi_awvalid
		// {{{
		initial	axi_awvalid = 0;
		always @(posedge S_AXI_ACLK)
		if (!S_AXI_ARESETN || !mwgrant[M])
			axi_awvalid <= 0;
		else if (!sawstall)
		begin
			axi_awvalid <= m_awvalid[mwindex[M]]
				&&(slave_awaccepts[mwindex[M]]);
		end
		// }}}

		// axi_awaddr, axi_awprot
		// {{{
		initial	axi_awaddr  = 0;
		initial	axi_awprot  = 0;
		always @(posedge S_AXI_ACLK)
		if (OPT_LOWPOWER && !S_AXI_ARESETN)
		begin
			axi_awaddr  <= 0;
			axi_awprot  <= 0;
		end else if (OPT_LOWPOWER && !mwgrant[M])
		begin
			axi_awaddr  <= 0;
			axi_awprot  <= 0;
		end else if (!sawstall)
		begin
			if (!OPT_LOWPOWER||(m_awvalid[mwindex[M]]&&slave_awaccepts[mwindex[M]]))
			begin
				axi_awaddr  <= m_awaddr[mwindex[M]];
				axi_awprot  <= m_awprot[mwindex[M]];
			end else begin
				axi_awaddr  <= 0;
				axi_awprot  <= 0;
			end
		end
		// }}}

		// axi_wvalid
		// {{{
		initial	axi_wvalid = 0;
		always @(posedge S_AXI_ACLK)
		if (!S_AXI_ARESETN || !mwgrant[M])
			axi_wvalid <= 0;
		else if (!swstall)
		begin
			axi_wvalid <= (m_wvalid[mwindex[M]])
					&&(slave_waccepts[mwindex[M]]);
		end
		// }}}

		// axi_wdata, axi_wstrb
		// {{{
		initial axi_wdata  = 0;
		initial axi_wstrb  = 0;
		always @(posedge S_AXI_ACLK)
		if (OPT_LOWPOWER && !S_AXI_ARESETN)
		begin
			axi_wdata  <= 0;
			axi_wstrb  <= 0;
		end else if (OPT_LOWPOWER && !mwgrant[M])
		begin
			axi_wdata  <= 0;
			axi_wstrb  <= 0;
		end else if (!swstall)
		begin
			if (!OPT_LOWPOWER || (m_wvalid[mwindex[M]]&&slave_waccepts[mwindex[M]]))
			begin
				axi_wdata  <= m_wdata[mwindex[M]];
				axi_wstrb  <= m_wstrb[mwindex[M]];
			end else begin
				axi_wdata  <= 0;
				axi_wstrb  <= 0;
			end
		end
		// }}}

		// axi_bready
		// {{{
		initial	axi_bready = 1;
		always @(posedge S_AXI_ACLK)
		if (!S_AXI_ARESETN || !mwgrant[M])
			axi_bready <= 1;
		else if (!mbstall)
			axi_bready <= 1;
		else if (M_AXI_BVALID[M]) // && mbstall
			axi_bready <= 0;
		// }}}

		//
		assign	M_AXI_AWVALID[M]         = axi_awvalid;
		assign	M_AXI_AWADDR[M*AW +: AW] = axi_awaddr;
		assign	M_AXI_AWPROT[M*3 +: 3]   = axi_awprot;
		//
		//
		assign	M_AXI_WVALID[M]             = axi_wvalid;
		assign	M_AXI_WDATA[M*DW +: DW]     = axi_wdata;
		assign	M_AXI_WSTRB[M*DW/8 +: DW/8] = axi_wstrb;
		//
		//
		assign	M_AXI_BREADY[M]             = axi_bready;
	end endgenerate


	generate for(M=0; M<NS; M=M+1)
	begin : READ_SLAVE_OUTPUTS
		// {{{
		// Declarations
		// {{{
		reg				axi_arvalid;
		reg	[C_AXI_ADDR_WIDTH-1:0]	axi_araddr;
		reg	[2:0]			axi_arprot;
		//
		reg				axi_rready;

		wire	arstall, srstall;
		// }}}
		assign	arstall= (M_AXI_ARVALID[M]&& !M_AXI_ARREADY[M]);
		assign	srstall = (S_AXI_RVALID[mrindex[M]]
						&& !S_AXI_RREADY[mrindex[M]]);

		// axi_arvalid
		// {{{
		initial	axi_arvalid = 0;
		always @(posedge S_AXI_ACLK)
		if (!S_AXI_ARESETN || !mrgrant[M])
			axi_arvalid <= 0;
		else if (!arstall)
		begin
			axi_arvalid <= m_arvalid[mrindex[M]] && slave_raccepts[mrindex[M]];
		end
		// }}}

		// axi_araddr, axi_arprot
		// {{{
		initial	axi_araddr  = 0;
		initial	axi_arprot  = 0;
		always @(posedge S_AXI_ACLK)
		if (OPT_LOWPOWER && !S_AXI_ARESETN)
		begin
			axi_araddr  <= 0;
			axi_arprot  <= 0;
		end else if (OPT_LOWPOWER && !mrgrant[M])
		begin
			axi_araddr  <= 0;
			axi_arprot  <= 0;
		end else if (!arstall)
		begin
			if (!OPT_LOWPOWER || (m_arvalid[mrindex[M]] && slave_raccepts[mrindex[M]]))
			begin
				if (NM == 1)
				begin
					axi_araddr  <= m_araddr[0];
					axi_arprot  <= m_arprot[0];
				end else begin
					axi_araddr  <= m_araddr[mrindex[M]];
					axi_arprot  <= m_arprot[mrindex[M]];
				end
			end else begin
				axi_araddr  <= 0;
				axi_arprot  <= 0;
			end
		end
		// }}}

		// axi_rready
		// {{{
		initial	axi_rready = 1;
		always @(posedge S_AXI_ACLK)
		if (!S_AXI_ARESETN || !mrgrant[M])
			axi_rready <= 1;
		else if (!srstall)
			axi_rready <= 1;
		else if (M_AXI_RVALID[M] && M_AXI_RREADY[M]) // && srstall
			axi_rready <= 0;
		// }}}

		//
		assign	M_AXI_ARVALID[M]         = axi_arvalid;
		assign	M_AXI_ARADDR[M*AW +: AW] = axi_araddr;
		assign	M_AXI_ARPROT[M*3 +: 3]   = axi_arprot;
		//
		assign	M_AXI_RREADY[M]          = axi_rready;
	end endgenerate

	// Return values
	generate for (N=0; N<NM; N=N+1)
	begin : WRITE_RETURN_CHANNEL
		// {{{
		reg		axi_bvalid;
		reg	[1:0]	axi_bresp;
		reg		i_axi_bvalid;
		wire	[1:0]	i_axi_bresp;
		wire		mbstall;

		initial	i_axi_bvalid = 1'b0;
		always @(*)
		if (wgrant[N][NS])
			i_axi_bvalid = m_wvalid[N] && slave_waccepts[N];
		else
			i_axi_bvalid = m_axi_bvalid[swindex[N]];

		assign	i_axi_bresp = m_axi_bresp[swindex[N]];

		assign	mbstall = S_AXI_BVALID[N] && !S_AXI_BREADY[N];

		// r_bvalid
		// {{{
		initial	r_bvalid[N] = 0;
		always @(posedge S_AXI_ACLK)
		if (!S_AXI_ARESETN)
			r_bvalid[N] <= 0;
		else if (mbstall && !r_bvalid[N] && !wgrant[N][NS])
			r_bvalid[N] <= swgrant[N] && i_axi_bvalid;
		else if (!mbstall)
			r_bvalid[N] <= 1'b0;
		// }}}

		// r_bresp
		// {{{
		initial	r_bresp[N] = 0;
		always @(posedge S_AXI_ACLK)
		if (OPT_LOWPOWER && !S_AXI_ARESETN)
			r_bresp[N] <= 0;
		else if (OPT_LOWPOWER && (!swgrant[N] || S_AXI_BREADY[N]))
			r_bresp[N] <= 0;
		else if (!r_bvalid[N])
		begin
			if (!OPT_LOWPOWER ||(i_axi_bvalid && !wgrant[N][NS] && mbstall))
			begin
				r_bresp[N] <= i_axi_bresp;
			end else
				r_bresp[N] <= 0;
		end
		// }}}

		// axi_bvalid
		// {{{
		initial	axi_bvalid = 0;
		always @(posedge S_AXI_ACLK)
		if (!S_AXI_ARESETN)
			axi_bvalid <= 0;
		else if (!mbstall)
			axi_bvalid <= swgrant[N] && (r_bvalid[N] || i_axi_bvalid);
		// }}}

		// axi_bresp
		// {{{
		initial	axi_bresp = 0;
		always @(posedge S_AXI_ACLK)
		if (OPT_LOWPOWER && !S_AXI_ARESETN)
			axi_bresp <= 0;
		else if (OPT_LOWPOWER && !swgrant[N])
			axi_bresp <= 0;
		else if (!mbstall)
		begin
			if (r_bvalid[N])
				axi_bresp <= r_bresp[N];
			else if (!OPT_LOWPOWER || i_axi_bvalid)
				axi_bresp <= i_axi_bresp;
			else
				axi_bresp <= 0;

			if (wgrant[N][NS] && (!OPT_LOWPOWER || i_axi_bvalid))
				axi_bresp <= INTERCONNECT_ERROR;
		end
		// }}}

		//
		assign	S_AXI_BVALID[N]       = axi_bvalid;
		assign	S_AXI_BRESP[N*2 +: 2] = axi_bresp;
	end endgenerate

	// m_axi_?r* values
	// {{{
	always @(*)
	begin
		m_axi_arvalid = 0;
		m_axi_arready = 0;
		m_axi_rvalid = 0;
		m_axi_rready = 0;

		m_axi_arvalid[NS-1:0] = M_AXI_ARVALID;
		m_axi_arready[NS-1:0] = M_AXI_ARREADY;
		m_axi_rvalid[NS-1:0]  = M_AXI_RVALID;
		m_axi_rready[NS-1:0]  = M_AXI_RREADY;
	end
	// }}}

	// Return values
	generate for (N=0; N<NM; N=N+1)
	begin : READ_RETURN_CHANNEL
		// {{{
		reg			axi_rvalid;
		reg	[1:0]		axi_rresp;
		reg	[DW-1:0]	axi_rdata;
		wire			srstall;
		reg			i_axi_rvalid;

		initial	i_axi_rvalid = 1'b0;
		always @(*)
		if (rgrant[N][NS])
			i_axi_rvalid = m_arvalid[N] && slave_raccepts[N];
		else
			i_axi_rvalid = m_axi_rvalid[srindex[N]];

		assign	srstall = S_AXI_RVALID[N] && !S_AXI_RREADY[N];

		initial	r_rvalid[N] = 0;
		always @(posedge S_AXI_ACLK)
		if (!S_AXI_ARESETN)
			r_rvalid[N] <= 0;
		else if (srstall && !r_rvalid[N])
			r_rvalid[N] <= srgrant[N] && !rgrant[N][NS]&&i_axi_rvalid;
		else if (!srstall)
			r_rvalid[N] <= 0;

		initial	r_rresp[N] = 0;
		initial	r_rdata[N] = 0;
		always @(posedge S_AXI_ACLK)
		if (OPT_LOWPOWER && !S_AXI_ARESETN)
		begin
			r_rresp[N] <= 0;
			r_rdata[N] <= 0;
		end else if (OPT_LOWPOWER && (!srgrant[N] || S_AXI_RREADY[N]))
		begin
			r_rresp[N] <= 0;
			r_rdata[N] <= 0;
		end else if (!r_rvalid[N])
		begin
			if (!OPT_LOWPOWER || (i_axi_rvalid && !rgrant[N][NS] && srstall))
			begin
				if (NS == 1)
				begin
					r_rresp[N] <= m_axi_rresp[0];
					r_rdata[N] <= m_axi_rdata[0];
				end else begin
					r_rresp[N] <= m_axi_rresp[srindex[N]];
					r_rdata[N] <= m_axi_rdata[srindex[N]];
				end
			end else begin
				r_rresp[N] <= 0;
				r_rdata[N] <= 0;
			end
		end

		initial	axi_rvalid = 0;
		always @(posedge S_AXI_ACLK)
		if (!S_AXI_ARESETN)
			axi_rvalid <= 0;
		else if (!srstall)
			axi_rvalid <= srgrant[N] && (r_rvalid[N] || i_axi_rvalid);

		initial	axi_rresp = 0;
		initial	axi_rdata = 0;
		always @(posedge S_AXI_ACLK)
		if (OPT_LOWPOWER && !S_AXI_ARESETN)
		begin
			axi_rresp <= 0;
			axi_rdata <= 0;
		end else if (OPT_LOWPOWER && !srgrant[N])
		begin
			axi_rresp <= 0;
			axi_rdata <= 0;
		end else if (!srstall)
		begin
			if (r_rvalid[N])
			begin
				axi_rresp <= r_rresp[N];
				axi_rdata <= r_rdata[N];
			end else if (!OPT_LOWPOWER || i_axi_rvalid)
			begin
				if (NS == 1)
				begin
					axi_rresp <= m_axi_rresp[0];
					axi_rdata <= m_axi_rdata[0];
				end else begin
					axi_rresp <= m_axi_rresp[srindex[N]];
					axi_rdata <= m_axi_rdata[srindex[N]];
				end

				if (rgrant[N][NS])
					axi_rresp <= INTERCONNECT_ERROR;
			end else begin
				axi_rresp <= 0;
				axi_rdata <= 0;
			end
		end

		assign	S_AXI_RVALID[N]        = axi_rvalid;
		assign	S_AXI_RRESP[N*2  +: 2] = axi_rresp;
		assign	S_AXI_RDATA[N*DW +: DW]= axi_rdata;
	end endgenerate

	// Count pending transactions
	generate for (N=0; N<NM; N=N+1)
	begin : COUNT_PENDING
		// {{{
		reg	[LGMAXBURST-1:0]	awpending, rpending,
						missing_wdata;
		//reg				rempty, awempty; // wempty;
		reg	r_wdata_expected;

		initial	awpending    = 0;
		initial	swempty[N]   = 1;
		initial	swfull[N]    = 0;
		always @(posedge S_AXI_ACLK)
		if (!S_AXI_ARESETN)
		begin
			awpending     <= 0;
			swempty[N]    <= 1;
			swfull[N]     <= 0;
		end else case ({(m_awvalid[N] && slave_awaccepts[N]),
				(S_AXI_BVALID[N] && S_AXI_BREADY[N])})
		2'b01: begin
			awpending     <= awpending - 1;
			swempty[N]    <= (awpending <= 1);
			swfull[N]     <= 0;
			end
		2'b10: begin
			awpending <= awpending + 1;
			swempty[N] <= 0;
			swfull[N]     <= &awpending[LGMAXBURST-1:1];
			end
		default: begin end
		endcase

		initial	missing_wdata = 0;
		always @(posedge S_AXI_ACLK)
		if (!S_AXI_ARESETN)
			missing_wdata <= 0;
		else begin
			missing_wdata <= missing_wdata
				+((m_awvalid[N] && slave_awaccepts[N])? 1:0)
				-((m_wvalid[N] && slave_waccepts[N])? 1:0);
		end

		initial	r_wdata_expected = 0;
		always @(posedge S_AXI_ACLK)
		if (!S_AXI_ARESETN)
			r_wdata_expected <= 0;
		else case({ m_awvalid[N] && slave_awaccepts[N],
				m_wvalid[N] && slave_waccepts[N] })
		2'b10: r_wdata_expected <= 1;
		2'b01: r_wdata_expected <= (missing_wdata > 1);
		default: begin end
		endcase


		initial	rpending     = 0;
		initial	srempty[N]   = 1;
		initial	srfull[N]    = 0;
		always @(posedge S_AXI_ACLK)
		if (!S_AXI_ARESETN)
		begin
			rpending  <= 0;
			srempty[N]<= 1;
			srfull[N] <= 0;
		end else case ({(m_arvalid[N] && slave_raccepts[N]),
				(S_AXI_RVALID[N] && S_AXI_RREADY[N])})
		2'b01: begin
			rpending      <= rpending - 1;
			srempty[N]    <= (rpending == 1);
			srfull[N]     <= 0;
			end
		2'b10: begin
			rpending      <= rpending + 1;
			srfull[N]     <= &rpending[LGMAXBURST-1:1];
			srempty[N]    <= 0;
			end
		default: begin end
		endcase

		assign	w_sawpending[N] = awpending;
		assign	w_srpending[N]  = rpending;

		assign	wdata_expected[N] = r_wdata_expected;

	end endgenerate

endmodule