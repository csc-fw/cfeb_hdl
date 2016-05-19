`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:56:31 02/05/2015 
// Design Name: 
// Module Name:    readout 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module readout #(
	parameter TMR = 0
)(
	input C25,
	input CLK,
	input RST,
	input L1AEMPTY,
	input SCAFULL,
	input DGSCAFULL,
	input XLOAD,
	input LCT_PHASE,
	input L1A_PHASE,
	input SCND_BLK,
	input SCND_SHARED,
	input [7:0] L1ABIN,
	input [3:0] RADR,
	input [5:0] L1ANUM,
	input [3:0] STATE,

	output POPL1AN,
	output reg OVLPINT,
	output reg NODATA,
	output reg FB_NODATA,
	output PUSH,
	output reg DDONE,
	output RDENA_B,
	output reg BUSY,
	output reg DIGIDONE,
	output LASTWORD,
	output reg ERRLOAD,
	output reg XCHECK,
	output XCHK,
	output reg NDENA,
	output reg D13OUT,
	output reg D14OUT,
	output reg [7:0] L1P,
	output reg [5:0] L1ANOUT,
	output reg [3:0] FB_ADR,
	output [3:0] ADO,
	output [6:0] ADR,
	output reg [3:0] RSTA,
	output [8:1] MONITOR
);

wire clr_gc;
wire clr_done;
wire clr_pstart;
wire clr_sce;
wire ce_fb;
reg rdena;
wire tc;
wire upsie;
wire ceshift;
wire ce_ss;
reg tc_1;
reg dlyhtc;
reg plast;
reg ldone;
wire ce1;
reg ce5;
wire done;
wire dup_done;
reg done_1;
wire doread;
reg yes;
wire yce;
reg pstart;
reg start;
reg busy_1;
reg lct_phase_bit;
wire l1a_phase_bit;
reg scnd_blk_1;
reg scnd_shared_1;
reg [6:0] l1m;
reg [7:0] l1pbn;
wire l1pb0;
reg [1:0] l1pcnt;
wire [3:0] ad;
wire [2:0] smp;
wire read;
wire one;
wire overlap;
wire doverlap;
reg ndload;
reg psh_1;
reg psh;
reg pshm1;
reg pshm2;
reg pshm3;
wire last;
reg last_1;
reg last_2;
reg last_3;
reg read_1;
reg read_2;
reg read_3;
reg bsrd_1;
reg ndbsrd_1;
reg ndbsrd_2;
reg ndbsrd_3;
reg sce;
reg sce_1;
wire popena;
reg l1preg;
reg scablock;
wire serial;
wire dserial;
wire dmy1;
wire dmy2;
wire dmy3;
wire lepush;


initial begin
	D13OUT = 0;
	D14OUT = 0;
end

assign clr_gc     = RST | RDENA_B;
assign clr_done   = RST | (DDONE & ce5);
assign clr_pstart = RST | start;
assign clr_sce    = RST | sce_1;
assign ce_fb      = (yce & !scnd_blk_1) | (yce & scnd_blk_1 & scnd_shared_1);
assign ADR = {RSTA,smp};
assign RDENA_B = !rdena;
assign PUSH = psh | ERRLOAD;
assign LASTWORD = DIGIDONE;
assign XCHK = psh_1 & !psh;
assign POPL1AN = l1pbn[0] & popena;
assign MONITOR = {done,l1pb0,BUSY,read,CLK,ceshift,start,l1pbn[0]};
assign last = plast & (tc_1 | (NODATA & read_1));
assign ce1 = (STATE == 4'd1);
assign done     = (tc | (BUSY & NODATA & !start & !l1pbn[0]) | (BUSY  & !read & !start & !l1pbn[0])) & ((upsie & (smp == 3'b100)) | (!upsie & (smp == 3'b000))) ;
assign dup_done = (tc | (BUSY & NODATA & !start & !l1pbn[0]) | (BUSY  & !read & !start & !l1pbn[0])) & ((upsie & (smp == 3'b100)) | (!upsie & (smp == 3'b000))) ;
assign doread  = !BUSY & !L1AEMPTY & !done & !done_1 & !ldone & !DDONE;
assign yce = doread & !yes;
assign ceshift = !done_1 & (dlyhtc | !read | (NODATA & BUSY & !dup_done));
assign ce_ss = ceshift | start;
assign one     = (l1pcnt == 2'd1);
assign overlap = (l1pcnt == 2'd2);
assign read    = one | overlap;
assign l1a_phase_bit = l1m[6];
assign popena = sce & ! sce_1;
assign serial = ad[3] ? scablock : l1preg;
assign upsie = (RADR[0] ^ RADR[1]) ~^ (RADR[2] ^ RADR[3]);
assign lepush = pshm1 & !psh; 


always @(posedge C25) begin
	ce5 <= (STATE == 4'd4);
	sce_1 <= sce;
end
always @(posedge C25 or posedge RST) begin
	if(RST)
		yes    <= 1'b0;
	else
		yes <= doread;
end

always @(posedge C25 or posedge clr_pstart) begin
	if(clr_pstart)
		pstart <= 1'b0;
	else
		if(yce)
			pstart <= 1'b1;
end

always @(posedge C25 or posedge RST) begin
	if(RST)
		l1m <= 7'h00;
	else
		if(POPL1AN)
			l1m <= {L1A_PHASE,L1ANUM};
end

always @(posedge C25 or posedge RST) begin
	if(RST)
		L1ANOUT <= 6'h00;
	else
		if(popena)
			L1ANOUT <= l1m[5:0];
end

always @(posedge C25 or posedge RST) begin
	if(RST)
		begin
			RSTA          <= 4'h0;
			L1P           <= 8'h00;
			lct_phase_bit <= 1'b0;
			NODATA        <= 1'b0;
			scnd_blk_1    <= 1'b0;
			scnd_shared_1 <= 1'b0;
		end
	else
		if(yce)
			begin
				RSTA          <= RADR;
				L1P           <= L1ABIN;
				lct_phase_bit <= LCT_PHASE;
				NODATA        <= DGSCAFULL;
				scnd_blk_1    <= SCND_BLK;
				scnd_shared_1 <= SCND_SHARED;
			end
end

always @(posedge C25 or posedge RST) begin
	if(RST)
		begin
			FB_ADR    <= 4'h0;
			FB_NODATA <= 1'b0;
		end
	else
		if(ce_fb)
			begin
				FB_ADR    <= RSTA;
				FB_NODATA <= NODATA;
			end
end

always @(posedge C25 or posedge clr_done) begin
	if(clr_done)
		DDONE <= 1'b0;
	else
		if(ce1)
			DDONE <= ldone;
		else
			DDONE <= DDONE;
end


always @(posedge CLK or posedge clr_sce) begin
	if(clr_sce)
		sce <= 1'b0;
	else
		sce <= start | ceshift;
end

always @(negedge CLK or posedge RST) begin
	if(RST)
		begin
			start <= 1'b0;
			BUSY <= 1'b0;
		end
	else
		begin
			start <= pstart;
			BUSY <= !done & (pstart | BUSY);
		end
end

always @(posedge CLK or posedge RST) begin
	if(RST)
		begin
			busy_1 <= 1'b0;
			pshm3  <= 1'b0;
			pshm2  <= 1'b0;
			pshm1  <= 1'b0;
			psh    <= 1'b0;
			psh_1  <= 1'b0;
			last_1 <= 1'b0;
			last_2 <= 1'b0;
			last_3 <= 1'b0;
			DIGIDONE <= 1'b0;
			read_1 <= 1'b0;
			read_2 <= 1'b0;
			read_3 <= 1'b0;
			ndload <= 1'b0;
			bsrd_1 <= 1'b0;
			ndbsrd_1 <= 1'b0;
			ndbsrd_2 <= 1'b0;
			ndbsrd_3 <= 1'b0;
			NDENA <= 1'b0;
		end
	else
		begin
			busy_1 <= BUSY;
			pshm3  <= rdena;
			pshm2  <= pshm3;
			pshm1  <= pshm2;
			psh    <= pshm1;
			psh_1  <= psh;
			last_1 <= last;
			last_2 <= last_1;
			last_3 <= last_2;
			DIGIDONE <= last_3;
			read_1 <= BUSY & busy_1 & read & NODATA;
			read_2 <= read_1;
			read_3 <= read_2;
			ndload <= read_3;
			bsrd_1 <= BUSY & read;
			ndbsrd_1 <= NODATA & bsrd_1;
			ndbsrd_2 <= ndbsrd_1;
			ndbsrd_3 <= ndbsrd_2;
			NDENA <= ndbsrd_3;
		end
end

always @(negedge CLK or posedge RST) begin
	if(RST)
		XCHECK <= 1'b0;
	else
		XCHECK <= XCHK;
end
always @(posedge CLK or posedge RST) begin
	if(RST)
		l1pbn <= 8'h00;
	else
		if(start)
			l1pbn <= L1P;
		else if(ceshift)
			l1pbn <= {1'b0,l1pbn[7:1]};
		else
			l1pbn <= l1pbn;
end

srl_nx1 #(.Depth(8)) l1p_dly_i (.CLK(!CLK),.CE(ce_ss),.I(l1pbn[0]),.O(l1pb0));

always @(negedge CLK or posedge RST) begin
	if(RST)
		l1pcnt <= 2'b00;
	else
		if(ce_ss & (l1pbn[0] ^ l1pb0))
			if(l1pbn[0])
				l1pcnt <= l1pcnt + 1;
			else
				l1pcnt <= l1pcnt - 1;
		else
			l1pcnt <= l1pcnt;
end


srl_nx1 #(.Depth(4)) overlap_dly_i (.CLK(!CLK),.CE(1'b1),.I(overlap),.O(doverlap));

always @(posedge CLK or posedge RST) begin
	if(RST)
		OVLPINT <= 1'b1;
	else
		if(ndload | pshm1)
			OVLPINT <= !doverlap;
		else
			OVLPINT <= OVLPINT;
end

always @(posedge CLK) begin
	ERRLOAD <= XLOAD | ndload;
end

cb4gray #(.TMR(TMR))
gray_ch_cnt_i (.CLK(CLK),.RST(clr_gc),.CE(rdena),.Q(ADO),.QI(ad),.TC(tc));

rcap_gcnt #(.TMR(TMR))
gray_samp_cnt_i (.CLK(CLK),.RST(RST),.CE(ceshift),.START(start),.UPSIE(upsie),.SAMP(smp));

always @(posedge CLK or posedge RST) begin
	if(RST)
		begin
			tc_1 <= 1'b0;
			rdena <= 1'b0;
		end
	else
		begin
			tc_1 <= tc;
			rdena <= (BUSY && read && !start && !tc && !NODATA);
		end
end

always @(negedge CLK or posedge RST) begin
	if(RST)
		begin
			dlyhtc <= 1'b0;
			done_1 <= 1'b0;
		end
	else
		begin
			dlyhtc <= tc;
			done_1 <= done;
		end
end

always @(posedge CLK or posedge clr_done) begin
	if(clr_done)
		begin
			plast <= 1'b0;
			ldone <= 1'b0;
		end
	else
		begin
			if(tc | NODATA)
				plast <= l1pb0;
			else
				plast <= plast;
			if(!BUSY & busy_1)
				ldone <= 1'b1;
			else
				ldone <= ldone;
		end
end

always @* begin
	case (ad[2:0])
		3'b000: l1preg = L1P[0];
		3'b001: l1preg = L1P[1];
		3'b010: l1preg = L1P[2];
		3'b011: l1preg = L1P[3];
		3'b100: l1preg = L1P[4];
		3'b101: l1preg = L1P[5];
		3'b110: l1preg = L1P[6];
		3'b111: l1preg = L1P[7];
	endcase
end

always @* begin
	case (ad[2:0])
		3'b000: scablock = RSTA[0];
		3'b001: scablock = RSTA[1];
		3'b010: scablock = RSTA[2];
		3'b011: scablock = RSTA[3];
		3'b100: scablock = l1a_phase_bit;
		3'b101: scablock = lct_phase_bit;
		3'b110: scablock = SCAFULL;
		3'b111: scablock = 1'b0;
	endcase
end


srl_nx1 #(.Depth(3)) serial_dly_i (.CLK(CLK),.CE(1'b1),.I(serial),.O(dserial));

always @(negedge CLK) begin
	D13OUT <= dserial;
end
always @(posedge CLK) begin
	if(lepush) D14OUT <= !overlap;
end

endmodule
