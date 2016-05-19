`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:46:55 02/05/2015 
// Design Name: 
// Module Name:    rdcntrl 
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
module rdcntrl #(
	parameter TMR = 0
)(
	input CLK,
	input RST,
	input ENBL50,
	input DISBL50,
	input PBEND,
	input TRGDONE,
	input L1A,
	input L1A_MATCH,
	input TRG_DCD,
	input LCT_SRL1,
	input DLSCAFULL,
	input LCT_PH,
	input [3:0] STATE,
	input [1:0] XL1DLYSET,
	input [3:0] LOADPBLK,
	input [3:0] BLKIN,
	input POPL1AN,
	input LAT_12_5US,
	input MTCH_3BX,

	output PFIFO1,
	output FULL,
	output DGSCAFULL,
	output NOL1A_MATCH,
	output TEMPTY,
	output SCND_BLK,
	output SCND_SHARED,
	output DAV,
	output L1A_PHASE_OUT,
	output LCT_PH_OUT,
	output MOVLP,
	output [7:0] NL1ABLK,
	output [7:0] L1POUT,
	output [3:0] BLKOUT,
	output [5:0] L1ANUM
);

reg [7:0] dl1a_pos;
reg [6:0] l1a_pos_sr;
wire [7:0] l1a_pos;
wire gmatch;
wire matchd;
wire no_matchd;
wire gmd;
wire mtd;
wire nmtd;
wire gmd_lpb;
wire mtd_lpb;
wire nmtd_lpb;
wire gmatchr_1;
reg  gmatchr;
reg dgmatchr;
wire matchr_1;
reg  matchr;
wire no_match_1;
reg l1,l2,l3,l4;
reg f1,f2,f3,f4;
reg g1,g2,g3;
wire pbend_1;
wire state1;
wire state3;
reg  lnol1a_match;
reg  yesl1a_match;
wire f3_scnd_shared;
wire f3push;
wire f3mt;
reg  df3mt;
wire l1mt;
wire [5:0] l1an;
reg  [5:0] dl1an;
reg l1a_phase_1;
reg l1a_phase;
wire dmyq1;
wire dmyq2;
wire dmyq3;
wire dmyq4;
wire dmyq5;
wire dmyq6;

assign pbend_1 = (STATE == 4'd12);
assign state1  = (STATE == 4'd1);
assign state3  = (STATE == 4'd3);
assign f3_scnd_shared = f2 & f3;
assign f3push = g2 | g3;
assign PFIFO1  = state3 & (yesl1a_match | lnol1a_match);
assign NOL1A_MATCH  = (lnol1a_match & !yesl1a_match) | (yesl1a_match & !f3push);
assign TEMPTY = f3mt | df3mt;

always @*
begin
	if(MTCH_3BX==1) begin
		lnol1a_match = l2 | l3;
		yesl1a_match = f2 | f3;
	end
	else begin
		lnol1a_match = l2 | l3 | l4;
		yesl1a_match = f2 | f3 | f4;
	end
end

fifo3 #(.TMR(TMR))
fifo3_i(
	.CLK(CLK),
	.RST(RST),
	.PUSH(f3push),
	.POP(TRGDONE),
	.CEW(state1),
	.CER(state3),
	.LCT_PH_IN(LCT_PH),
	.DLSCAFULL(DLSCAFULL),
	.SCND_BLK_IN(f3),
	.SCND_SH_IN(f3_scnd_shared),
	.BLKIN(BLKIN),
	.L1PIN(dl1a_pos),
	.EMPTY(f3mt),
	.FULL(FULL),
	.LCT_PH_OUT(LCT_PH_OUT),
	.DGSCAFULL(DGSCAFULL),
	.SCND_BLK_OUT(SCND_BLK),
	.SCND_SH_OUT(SCND_SHARED),
	.BLKOUT(BLKOUT),
	.L1POUT(L1POUT),
	.NL1ABLK(NL1ABLK)
);

l1an_fifo #(.TMR(TMR))
l1an_fifo_i(
	.CLK(CLK),
	.RST(RST),
	.PUSH(gmatch),
	.POP(POPL1AN),
	.L1A_PHASE(l1a_phase),
	.DL1AN(dl1an),
	.L1A_PHASE_OUT(L1A_PHASE_OUT),
	.EMPTY(l1mt),
	.FULL(l1full),
	.L1ANUM(L1ANUM)
);

trigreg #(
	.TMR(TMR)
)
trigreg_i(
	.CLK(CLK),
	.RST(RST),
	.LCT_SRL1(LCT_SRL1),
	.L1A(L1A),
	.L1A_MATCH(L1A_MATCH),
	.TRG_DCD(TRG_DCD),
	.LAT_12_5US(LAT_12_5US),
	.MTCH_3BX(MTCH_3BX),
	.XL1DLYSET(XL1DLYSET),
	.MATCHR(matchd),
	.NO_MATCH(no_matchd),
	.GMATCH(gmatch),
	.DAV(DAV),
	.MISS_MATCH(MOVLP)
);

   
srl_nx1 #(.Depth(9))   gmatchd_i (.CLK(CLK),.CE(1'b1),.I(gmatch),   .O(gmd));
srl_nx1 #(.Depth(7))    matchd_i (.CLK(CLK),.CE(1'b1),.I(matchd),   .O(mtd));
srl_nx1 #(.Depth(7)) no_matchd_i (.CLK(CLK),.CE(1'b1),.I(no_matchd),.O(nmtd));

srl_16dx1   gmatchd_lpb_i (.CLK(CLK),.CE(1'b1),.A({1'b0,LOADPBLK[2:0]}),.I(gmd), .O(gmd_lpb),.Q15(dmyq4));
srl_16dx1    matchd_lpb_i (.CLK(CLK),.CE(1'b1),.A({1'b0,LOADPBLK[2:0]}),.I(mtd), .O(mtd_lpb),.Q15(dmyq5));
srl_16dx1 no_matchd_lpb_i (.CLK(CLK),.CE(1'b1),.A({1'b0,LOADPBLK[2:0]}),.I(nmtd),.O(nmtd_lpb),.Q15(dmyq6));

assign gmatchr_1  = LOADPBLK[3] ? gmd_lpb  : gmd;
assign  matchr_1  = LOADPBLK[3] ? mtd_lpb  : mtd;
assign no_match_1 = LOADPBLK[3] ? nmtd_lpb : nmtd;


always @(posedge CLK or posedge RST) begin
	if(RST)
		df3mt <= 1'b1;
	else
		if(state1)
			df3mt <= f3mt;
end

always @(posedge CLK or posedge RST) begin
	if(RST)
		begin
			gmatchr <= 1'b0;
			matchr  <= 1'b0;
		end
	else
		begin
			gmatchr <= gmatchr_1;
			matchr  <= matchr_1;
		end
end

always @(posedge CLK or posedge RST) begin
	if(RST)
		begin
			l1 <= 1'b0;
			l2 <= 1'b0;
			l3 <= 1'b0;
			l4 <= 1'b0;
			f1 <= 1'b0;
			f2 <= 1'b0;
			f3 <= 1'b0;
			f4 <= 1'b0;
			g1 <= 1'b0;
			g2 <= 1'b0;
			g3 <= 1'b0;
		end
	else
		begin
			l1 <= no_match_1 | (l1 & !PBEND);
			f1 <= matchr_1   | (f1 & !PBEND);
			g1 <= gmatchr_1  | (11 & !pbend_1);
			if(PBEND)
				begin
					l2 <= l1;
					l3 <= l2;
					l4 <= l3;
					f2 <= f1;
					f3 <= f2;
					f4 <= f3;
				end
			if(pbend_1)
				begin
					g2 <= g1;
					g3 <= g2;
				end
		end
end

always @(posedge CLK or posedge RST) begin
	if(RST)
		dgmatchr <= 1'b0;
	else
		if(ENBL50)
			dgmatchr <= gmatchr;
end

assign l1a_pos = {gmatchr | dgmatchr,l1a_pos_sr};

always @(posedge CLK or posedge RST) begin
	if(RST)
		l1a_pos_sr <= 7'h00;
	else
		if(DISBL50)
			l1a_pos_sr <= {l1a_pos[7],l1a_pos_sr[6:1]};
end

always @(posedge CLK or posedge RST) begin
	if(RST)
		dl1a_pos <= 8'h00;
	else
		if(pbend_1)
			dl1a_pos <= l1a_pos;
end

cbnce #(.Width(6),.TMR(TMR)) l1a_counter_i (.CLK(CLK),.RST(RST),.CE(L1A),.Q(l1an));

always @(posedge CLK) begin
	if(L1A)
		l1a_phase_1 <= ENBL50;
end
always @(posedge CLK) begin
	dl1an <= l1an;
	l1a_phase <= l1a_phase_1;
end

endmodule
