`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:19:14 01/05/2015 
// Design Name: 
// Module Name:    cfeb_hdl 
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

module cfeb_hdl #(
	parameter TMR = 1,
	parameter SIM = 0
)(
    input [2:0] ENC_TRG, //{GLOBAL_RST,L1A,LCT}
    input CMSCLK,
    input CMPCLK,
    input [12:0] ADC1B,
    input [12:0] ADC2B,
    input [12:0] ADC3B,
    input [12:0] ADC4B,
    input [12:0] ADC5B,
    input [12:0] ADC6B,
    input [6:1] AMPOUT,
    input CMPFDBK,
    inout DMYSHIFT,
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
wire enbl50;
wire disbl50;
wire scam150ns;
wire lockrst;
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
wire [1:0] jcmode;
wire [2:0] jctime;

wire drck1;
wire drck2;
wire jrst;
wire sel1;
wire sel2;
wire shift;
wire btdi;
wire update;
wire tdo1;
wire tdo2;

wire trg_dcd;
wire mtch_3bx;
wire lat_12_5us;
reg [2:0]enc_trg;
reg lct;
reg l1a;
reg l1a_match;
reg resync;


initial begin
	enc_trg = 3'b000;
end

IBUFG CMSCLK_BUF(.O(clkin),.I(CMSCLK));

IBUFG CMPCLK_BUF(.O(cmpclkin),.I(CMPCLK));

IBUFG CMPFDBK_BUF(.O(cmpfdbkin),.I(CMPFDBK));

OBUF CMPMUX_BUF(.O(CMPMUX),.I(cmpmuxout));

OBUF CMPRST_BUF(.O(CMPRST),.I(resync));

(* syn_useioff = "True" *)
always @(negedge clk25ns)  // on falling edge
begin 
	RDENA_B <= rdena_b;
end

(* syn_useioff = "True" *)
always @(posedge clk25ns) begin
	enc_trg <= ENC_TRG; // 3bits 
end

always @* begin
	if(trg_dcd)
		case(enc_trg)
			3'd0: {resync, l1a_match, l1a, lct} = 4'b0000;
			3'd1: {resync, l1a_match, l1a, lct} = 4'b0001;
			3'd2: {resync, l1a_match, l1a, lct} = 4'b0011;
			3'd3: {resync, l1a_match, l1a, lct} = 4'b0111;
			3'd4: {resync, l1a_match, l1a, lct} = 4'b0010;
			3'd5: {resync, l1a_match, l1a, lct} = 4'b0110;
			3'd7: {resync, l1a_match, l1a, lct} = 4'b1000;
			default: {resync, l1a_match, l1a, lct} = 4'b0000;
		endcase
	else begin
		lct       = enc_trg[0];
		l1a       = enc_trg[1];
		l1a_match = enc_trg[1];
		resync    = enc_trg[2];;
	end
end

blkscam  #(
	.TMR(TMR)
)
blkscam_i (
	.CLK(clk25ns),
	.CLK150NS(scam150ns),
	.RSTIN(resync),
	.ENBL50(enbl50),
	.DISBL50(disbl50),
	.LCT(lct),
	.L1A(l1a),
	.L1A_MATCH(l1a_match),
	.TRG_DCD(trg_dcd),
	.LAT_12_5US(lat_12_5us),
	.MTCH_3BX(mtch_3bx),
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
	.RST(resync),
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
	.RST(resync),
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



generate
if(SIM==1) 
begin : jtag_sim
	
 /////////////////////////////////////////////////////////////////////////////
 //                                                                         //
 //  JTAG Access Ports for user function in the fabric (up to 4 interfaces) //
 //  For simulation with ISE 14.7, assumes Virtex6 device                   //
 /////////////////////////////////////////////////////////////////////////////
 
 wire capture1, capture2;
 wire jreset1,  jreset2;
 wire runtest1, runtest2;
 wire jshift1,  jshift2;
 wire tck1,     tck2;
 wire tdi1,     tdi2;
 wire tms1,     tms2;
 wire update1,  update2;
 
 assign jrst   = jreset1 | jreset2;
 assign shift  = jshift1 | jshift2;
 assign btdi   = tdi1    | tdi2;
 assign update = update1 | update2;
 
   BSCAN_VIRTEX6 #(.DISABLE_JTAG("FALSE"),.JTAG_CHAIN(1))  // User 1 for instruction decodes
   BSCAN_user1 (
      .CAPTURE(capture1), // 1-bit output CAPTURE output from TAP controller
      .DRCK(drck1_i),     // 1-bit output Data register output for USER functions
      .RESET(jreset1),    // 1-bit output Reset output for TAP controller
      .RUNTEST(runtest1), // 1-bit output State output asserted when TAP controller is in Run Test Idle state.
      .SEL(sel1),         // 1-bit output USER active output
      .SHIFT(jshift1),    // 1-bit output SHIFT output from TAP controller
      .TCK(tck1),         // 1-bit output Scan Clock output. Fabric connection to TAP Clock pin.
      .TDI(tdi1),         // 1-bit output TDI output from TAP controller
      .TMS(tms1),         // 1-bit output Test Mode Select input. Fabric connection to TAP.
      .UPDATE(update1),   // 1-bit output UPDATE output from TAP controller
      .TDO(tdo1)          // 1-bit input Data input for USER function
   );
  
   BSCAN_VIRTEX6 #(.DISABLE_JTAG("FALSE"),.JTAG_CHAIN(2))  // User 2 for data I/O
   BSCAN_user2 (
      .CAPTURE(capture2), // 1-bit output CAPTURE output from TAP controller
      .DRCK(drck2_i),     // 1-bit output Data register output for USER functions
      .RESET(jreset2),    // 1-bit output Reset output for TAP controller
      .RUNTEST(runtest2), // 1-bit output State output asserted when TAP controller is in Run Test Idle state.
      .SEL(sel2),         // 1-bit output USER active output
      .SHIFT(jshift2),    // 1-bit output SHIFT output from TAP controller
      .TCK(tck2),         // 1-bit output Scan Clock output. Fabric connection to TAP Clock pin.
      .TDI(tdi2),         // 1-bit output TDI output from TAP controller
      .TMS(tms2),         // 1-bit output Test Mode Select input. Fabric connection to TAP.
      .UPDATE(update2),   // 1-bit output UPDATE output from TAP controller
      .TDO(tdo2)          // 1-bit input Data input for USER function
   );
	
end
else
begin : jtag_bscan
	BSCAN_VIRTEX BSCAN_VIRTEX_inst (
		.DRCK1(drck1_i),     // Data register output for USER1 functions
		.DRCK2(drck2_i),     // Data register output for USER2 functions
		.RESET(jrst),     // Reset output from TAP controller
		.SEL1(sel1),       // USER1 active output
		.SEL2(sel2),       // USER2 active output
		.SHIFT(shift),     // SHIFT output from TAP controller
		.TDI(btdi),         // TDI output from TAP controller
		.UPDATE(update),   // UPDATE output from TAP controller
		.TDO1(tdo1),       // Data input for USER1 function
		.TDO2(tdo2)        // Data input for USER2 function
	);
end
endgenerate

BUFG jclk_buf1 (
	.O(drck1),     // Clock buffer output
	.I(drck1_i)    // Clock buffer input
);

BUFG jclk_buf2 (
	.O(drck2),     // Clock buffer output
	.I(drck2_i)    // Clock buffer input
);

jtag #(
	.TMR(TMR)
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
	.TRG_DCD(trg_dcd),
	.MTCH_3BX(mtch_3bx),
	.LAT_12_5US(lat_12_5us),
	.LOADPBLK(loadpblk),
	.XL1DLYSET(xl1dlyset),
	.CMODE(jcmode),
	.CTIME(jctime),
	.AMPIN(AMPIN),
	.AMPCLK(AMPCLK)
);

endmodule
