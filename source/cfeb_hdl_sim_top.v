`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:19:14 01/05/2015 
// Design Name: 
// Module Name:    cfeb_hdl_sim_top
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

module cfeb_hdl_sim_top #(
	parameter TMR = 0
)(
	input TDI,
	input TMS,
	input TCK,
	input LCT,
	input GTRG,
	input CMSCLK,
	input CMPCLK,
	input GLOBAL_RST,
	input [12:0] ADC1B,
	input [12:0] ADC2B,
	input [12:0] ADC3B,
	input [12:0] ADC4B,
	input [12:0] ADC5B,
	input [12:0] ADC6B,
	input [6:1] AMPOUT,
	input CMPFDBK,
	inout DMYSHIFT,
	output TDO,
	output reg RDENA_B,
	output MOVLAP,
	output DATAAVAIL,
	output [3:0] CHADR,
	output [6:0] RADR,
	output [6:0] WADR,
	output LPUSH_B,
	output ENDWORD,
	output SCAWRITE,
	output ADC150NS,
	output CMPRST,
	output [15:0] OUT,
	output OVERLAP,
	output CMPMUX,
	output DACCLK,
	output DACDAT,
	output DAC_ENB_B,
	output [1:0] CMODE,
	output [2:0] CTIME,
	output [6:1] AMPIN,
	output [6:1] AMPCLK,
	output [7:0] LEDS
);

wire clkin;
wire cmpclkin;
wire cmpfdbkin;
wire cmpmuxout;
wire grst;
wire enbl50;
wire disbl50;
wire scam150ns;
wire lockrst;
reg  sync_rst;
(* PERIOD = "24ns" *) wire clk25ns;
wire rdena_b;
wire push;
wire ovlpint;
wire lastword;
wire dataload;
wire crccheck;
wire oecrcmux;
wire [15:0] data;
wire [23:0] status;
wire [5:0] l1anout;
wire [6:1] adcen_b;

wire [3:0] loadpblk;
wire [1:0] xl1dlyset;

wire drck1;
wire drck2;
wire drck1_i;
wire drck2_i;
wire jrst;
wire sel1;
wire sel2;
wire shift;
wire btdi;
wire update;
wire tdo1;
wire tdo2;


IBUFG CMSCLK_BUF(.O(clkin),.I(CMSCLK));

IBUFG CMPCLK_BUF(.O(cmpclkin),.I(CMPCLK));

IBUFG CMPFDBK_BUF(.O(cmpfdbkin),.I(CMPFDBK));

IBUF GLOBAL_RST_BUF(.O(grst),.I(GLOBAL_RST));

OBUF CMPMUX_BUF(.O(CMPMUX),.I(cmpmuxout));

OBUF CMPRST_BUF(.O(CMPRST),.I(sync_rst));

(* syn_useioff = "True" *)
always @(negedge clk25ns)  // on falling edge
begin 
	RDENA_B <= rdena_b;
end

always @(posedge clk25ns)
begin
	sync_rst <= grst;
end

blkscam  #(.TMR(TMR))
blkscam_i (
	.ENBL50(enbl50),
	.DISBL50(disbl50),
	.CLK150NS(scam150ns),
	.RAWLCTIN(LCT),
	.RAWGTRIG(GTRG),
	.RSTIN(sync_rst),
	.CLK(clk25ns),
	.LOADPBLK(loadpblk),
	.XL1DLYSET(xl1dlyset),
	
	.RDENA_B(rdena_b),
	.PUSH(push),
	.MOVERLAP(MOVLAP),
	.DATAAVAIL(DATAAVAIL),
	.OVLPINT(ovlpint),
	.LASTWORD(lastword),
	.ERRLOAD(dataload),
	.XCHECK(crccheck),
	.OECRCMUX(oecrcmux),
	.DATAOUT(data),
	.AD(CHADR),
	.ADR(RADR),
	.OWADR(WADR),
	.L1ANOUT(l1anout),
	.STATUS(status),
	.LEDS(LEDS)
);

blkcpld   #(.TMR(TMR))
blkcpld_i (
	.CLKIN(clkin),
	.CMPCLKIN(cmpclkin),
	.CMPFDBKIN(cmpfdbkin),
	.RST(sync_rst),
	.PUSH(push),
	.LASTWORD(lastword),
	.XLOAD(dataload),
	.SENDCHECK(crccheck),
	
	.LOCKRST(lockrst),
	.CLK(clk25ns),
	.CMPMUXOUT(cmpmuxout),
	.EN50(enbl50),
	.DIS50(disbl50),
	.SCAM150(scam150ns),
	.OEN_B(adcen_b),
	.LPUSH_B(LPUSH_B),
	.END(ENDWORD),
	.SCAWRITE(SCAWRITE),
	.ADCCLK(ADC150NS)
);

blkmux
blkmux_i (
	.CLK25(clk25ns),
	.CLK150(scam150ns),
	.RST(sync_rst),
	.START(push),
	.OECRC(oecrcmux),
	.DLOAD(dataload),
	.OVLPINT(ovlpint),
	.DATA(data),
	.OE_B(adcen_b),
	.K1ADC(ADC1B),
	.K2ADC(ADC2B),
	.K3ADC(ADC3B),
	.K4ADC(ADC4B),
	.K5ADC(ADC5B),
	.K6ADC(ADC6B),
	.L1ANOUT(l1anout),
	.STATUS(status),
	
	.OVERLAP(OVERLAP),
	.OUT(OUT)
);


wire tlrst;

BSCAN_VIRTEX_sim BSCAN_VIRTEX_sim_inst (
	.TDO(TDO),
	.DRCK1(drck1_i),     // Data register output for USER1 functions
	.DRCK2(drck2_i),     // Data register output for USER2 functions
	.RESET(tlrst),     // Reset output from TAP controller
	.SEL1(sel1),       // USER1 active output
	.SEL2(sel2),       // USER2 active output
	.SHIFT(shift),     // SHIFT output from TAP controller
	.BTDI(btdi),         // TDI output from TAP controller
	.UPDATE(update),   // UPDATE output from TAP controller
	.TDO1(tdo1),       // Data input for USER1 function
	.TDO2(tdo2),        // Data input for USER2 function
	.TCK(TCK),
	.TMS(TMS),
	.TRST(grst),
	.TDI(TDI)
);

BUFG jclk_buf1 (
	.O(drck1),     // Clock buffer output
	.I(drck1_i)    // Clock buffer input
);

BUFG jclk_buf2 (
	.O(drck2),     // Clock buffer output
	.I(drck2_i)    // Clock buffer input
);

jtag #(
	.TMR(0)
)
jtag_i (
	.CLK25(clk25ns),
	.RST(lockrst),
	.UPDATE(update),
	.SHIFT(shift),
	.BTDI(btdi),
	.SEL1(sel1),
	.SEL2(sel2),
	.DRCK1(drck1),
	.DRCK2(drck2),
	.AMPOUT(AMPOUT),
	.CSTATUS(status[15:0]),
	.TDO1(tdo1),
	.TDO2(tdo2),
	.DACCLK(DACCLK),
	.DACDAT(DACDAT),
	.DAC_ENB_B(DAC_ENB_B),
	.DMYSHIFT(DMYSHIFT),
	.LOADPBLK(loadpblk),
	.XL1DLYSET(xl1dlyset),
	.CMODE(CMODE),
	.CTIME(CTIME),
	.AMPIN(AMPIN),
	.AMPCLK(AMPCLK)
);

endmodule
