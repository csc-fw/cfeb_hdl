`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:34:18 01/07/2015 
// Design Name: 
// Module Name:    blkscam 
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
module blkscam #(
	parameter TMR = 0,
	parameter LAT_12_5us = 0,
	parameter MTCH_3BX = 0
)(
    input CLK,
    input CLK150NS,
    input RSTIN,
    input ENBL50,
    input DISBL50,
    input RAWLCTIN,
    input RAWGTRIG,
    input [3:0] LOADPBLK,
    input [1:0] XL1DLYSET,
    output RDENA_B,
    output PUSH,
    output MOVERLAP,
    output DATAAVAIL,
    output OVLPINT,
    output LASTWORD,
    output ERRLOAD,
    output XCHECK,
    output OECRCMUX,
    output reg [15:0] DATAOUT,
    output [3:0] AD,
    output [6:0] ADR,
    output [6:0] OWADR,
    output [5:0] L1ANOUT,
    output [23:0] STATUS,
	 output [7:0] LEDS
    );

reg rst;
reg lct;
wire lct_srl1;
reg gtrg;
wire busy;
wire nodata;
wire pfifo1;
wire tempty;
wire empty_b;
wire full3;
wire full1;
wire xload;
wire lastwordd;

wire trgdone;
wire nogtrg;
wire fb_nodata;
wire scnd_blk;
wire scnd_shared;
wire dlscafull;
wire vdscafull;
wire scafull;
wire lctyena; 
wire selpatha; 
wire selpathb; 
wire selpathc; 
wire selpathd; 
wire wrena; 
wire enareg; 
wire preblkend; 
wire nbsel; 
wire plct;
wire lctdly;
wire nolct;
wire l1a_phase;
wire lct_phase_in;
wire lct_phase;
wire almostful;
wire popl1an;
wire dgscafull;
wire digidone;
wire d13out;
wire d14out;

wire [3:0] state;
wire [3:0] nfree_blks;
wire [7:0] nlct;
wire [7:0] nl1ablk;
wire [3:0] rsta;
wire [3:0] badr;
wire [3:0] fb_adr;
wire [3:0] radr;
wire [6:0] wadr;
wire [2:0] dscafull;
wire [11:0] lctadr;
wire [7:0] l1p;
wire [7:0] l1pout;
wire [5:0] l1anum;
wire [8:1] monitor;

initial begin
	lct = 0;
	gtrg = 0;
	rst = 0;
end

assign STATUS = {busy,nodata,PUSH,pfifo1,tempty,empty_b,full3,full1,nl1ablk[5:0],nlct[5:0],nfree_blks};
assign xload = full1 | full3;
assign LASTWORD = lastwordd | xload;

// Comment: Error message generation (Serious error need RESET from DAQMB to recover)
//   SCA full, not a serious error, send 1011001, just overwrite the same SCA block, and the error bit is carried in the data stream.
//   FPGA LCT fifo error, send 1011100, then the l1a FIFO full flag, then the number of LCT fifo cells used (4bits), and number of free SCA blocks (4bits).
//   FPGA L1A fifo error, send 1011010, then the lct FIFO full flag, then 8 bits of the number of L1A fifo cells used.

//assign DATAOUT[15:12] = xload ? 4'hB : 4'hz;
//assign DATAOUT[11:8]  = full1 ? {3'b100,full3} : full3 ? {3'b010,full1} : 4'hz;
//assign DATAOUT[7:0]   = full1 ? {nlct[3:0],nfree_blks} : full3 ? nl1ablk : 8'hzz;
//assign DATAOUT        = ndena ? {4'hB,3'b001,scafull,l1p} : 16'hzzzz;
//assign DATAOUT[15:13] = !(ndena | xload) ? {d15out,d14out,d13out} : 3'bzzz;

always @* begin
	casex ({ndena,full3,full1})
		3'b000: DATAOUT = {1'b0,d14out,d13out,1'b0,12'h000};
		3'b0x1: DATAOUT = {4'hB,3'b100,full3,nlct[3:0],nfree_blks};
		3'b010: DATAOUT = {4'hB,3'b010,full1,nl1ablk};
		3'b1xx: DATAOUT = {4'hB,3'b001,scafull,l1p};
	endcase
end

assign lctdly    = LOADPBLK[3] ? plct : lct;
srl_16dx1 lct_pblk_delay_i (.CLK(CLK),.CE(1'b1),.A({1'b0,LOADPBLK[2:0]}),.I(lct),.O(plct),.Q15(lct_srl1));

(* syn_useioff = "True" *)
always @(posedge CLK) begin
	lct <= RAWLCTIN;
	gtrg <= RAWGTRIG;
end
always @(posedge CLK) begin
	if(ENBL50)
		rst <= RSTIN;
end

scamcntrl  #(
	.TMR(TMR),
	.MTCH_3BX(MTCH_3BX)
)
scamcntrl_i (
	.CLK(CLK),
	.RST(rst),
	.LCTDLY(lctdly),
	.LOADPBLK(LOADPBLK),
	.DONE(trgdone),
	.NOGTRG(nogtrg),
	.NODATA(nodata),
	.FB_NODATA(fb_nodata),
	.SCND_BLK(scnd_blk),
	.SCND_SHARED(scnd_shared),
	.DLSCAFULL(dlscafull),
	.DSCAFULL(vdscafull),
	
	.STATE(state),
	.LCTYENA(lctyena),
	.SELA(selpatha),
	.SELB(selpathb),
	.SELC(selpathc),
	.SELD(selpathd),
	.WRENA(wrena),
	.ENAREG(enareg),
	.PREBLKEND(preblkend),
	.NBSEL(nbsel),
	.NOLCT(nolct)
);

nbadr #(
	.TMR(TMR),
	.MTCH_3BX(MTCH_3BX)
)
nbadr_i(
	.CLK(CLK),
	.RST(rst),
	.WRENA(wrena),
	.NBSEL(nbsel),
	.PATHASEL(selpatha),
	.PATHBSEL(selpathb),
	.PATHCSEL(selpathc),
	.PATHDSEL(selpathd),
	.ENAREG(enareg),
	.ENBL50(ENBL50),
	.DISBL50(DISBL50),
	.YGTRG(rsta),
	.NGTRG(badr),
	.FB_ADR(fb_adr),

	.VDSCAFULL(vdscafull),
	.VSCAFULL(scafull),
	.WADR(wadr),
	.DSCAFULL(dscafull),
	.NFREE_BLKS(nfree_blks),
	.LCTADR(lctadr),
	.W(OWADR),
	.LEDS(LEDS)
);

fifo1 #(.TMR(TMR))
fifo1_i(
	.CLK(CLK),
	.RST(rst),
	.LCT(lct),
	.POP(pfifo1),
	.PUSH(lctyena),
	.ENBL50(ENBL50),
	.DISBL50(DISBL50),
	.PREBLKEND(preblkend),
	.LOADPBLK(LOADPBLK),
	.DIN(lctadr),
	.DSCAFULL(dscafull),

	.DOUT(badr),
	.NLCT(nlct),
	.LCT_PHASE(lct_phase_in),
	.FULL_1(almostful),
	.EMPT_B(empty_b),
	.FULL(full1),
	.DLSCAFULL(dlscafull)
);

rdcntrl #(
	.TMR(TMR),
	.LAT_12_5us(LAT_12_5us),
	.MTCH_3BX(MTCH_3BX)
)
rdcntrl_i(
	.CLK(CLK),
	.RST(rst),
	.ENBL50(ENBL50),
	.DISBL50(DISBL50),
	.PBEND(preblkend),
	.TRGDONE(trgdone),
	.GTRG(gtrg),
	.LCT_SRL1(lct_srl1),
	.DLSCAFULL(dlscafull),
	.LCT_PH(lct_phase_in),
	.STATE(state),
	.XL1DLYSET(XL1DLYSET),
	.LOADPBLK(LOADPBLK),
	.BLKIN(badr),
	.POPL1AN(popl1an),

	.PFIFO1(pfifo1),
	.FULL(full3),
	.DGSCAFULL(dgscafull),
	.NOGTRG(nogtrg),
	.TEMPTY(tempty),
	.SCND_BLK(scnd_blk),
	.SCND_SHARED(scnd_shared),
	.DAV(DATAAVAIL),
	.L1A_PHASE_OUT(l1a_phase),
	.LCT_PH_OUT(lct_phase),
	.MOVLP(MOVERLAP),
	.NL1ABLK(nl1ablk),
	.L1POUT(l1pout),
	.BLKOUT(radr),
	.L1ANUM(l1anum)
);

readout #(
	.TMR(TMR),
	.MTCH_3BX(MTCH_3BX)
)
readout_i(
	.C25(CLK),
	.CLK(CLK150NS),
	.RST(rst),
	.GTRGEMPTY(tempty),
	.SCAFULL(scafull),
	.DGSCAFULL(dgscafull),
	.XLOAD(xload),
	.LCT_PHASE(lct_phase),
	.L1A_PHASE(l1a_phase),
	.SCND_BLK(scnd_blk),
	.SCND_SHARED(scnd_shared),
	.L1ABIN(l1pout),
	.RADR(radr),
	.L1ANUM(l1anum),
	.STATE(state),

	.POPL1AN(popl1an),
	.OVLPINT(OVLPINT),
	.NODATA(nodata),
	.FB_NODATA(fb_nodata),
	.PUSH(PUSH),
	.DDONE(trgdone),
	.RDENA_B(RDENA_B),
	.BUSY(busy),
	.DIGIDONE(digidone),
	.LASTWORD(lastwordd),
	.ERRLOAD(ERRLOAD),
	.XCHECK(XCHECK),
	.XCHK(OECRCMUX),
	.NDENA(ndena),
	.D13OUT(d13out),
	.D14OUT(d14out),
	.L1P(l1p),
	.L1ANOUT(L1ANOUT),
	.FB_ADR(fb_adr),
	.ADO(AD),
	.ADR(ADR),
	.RSTA(rsta),
	.MONITOR(monitor)
);


endmodule
