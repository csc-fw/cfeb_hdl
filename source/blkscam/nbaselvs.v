`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    15:01:31 02/09/2015 
// Design Name: 
// Module Name:    nbaselvs 
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
module nbaselvs #(
	parameter TMR = 0
)(
    input CLK,
    input RST,
    input WRENA,
    input SELA,
    input NBSEL,
    input [3:0] BADR,
    input [3:0] RDADR,
    output reg [3:0] NADR,
    output [15:0] BMEM,
    output [3:0] NFREE_BLKS,
    output reg SCAFULL
    );

wire [14:0] out;
wire [14:0] dmy;
wire [15:0] dmmy;
wire [3:0] wradr;
wire [3:0] adr;
wire [3:0] selb;
wire hp;
wire mpap;
wire mpbp;
wire mpa;
wire mpb;
wire lp;
wire lpp;
wire np;
wire data;
wire ena;
(* syn_preserve = "True" *)reg sf_clr;
(* syn_preserve = "True" *)reg lrst;
reg dly_data;
reg dly_wrena;
reg dly_sela;
reg dly_scafull;
wire bf_ce;
wire ena_bf_ce;
wire dis_bf_ce;

assign hp   = |out[3:0];                              // High priority group
assign mpap = |out[6:4]; 
assign mpbp = |out[9:7]; 
assign lpp  = |out[13:10]; 
assign mpa  = (!hp &  mpap);                          // Medium priority group A
assign mpb  = (!hp & !mpap & mpbp);                   // Medium priority group B
assign lp   = (!hp & !mpap & !mpbp & lpp);            // Low priority group
assign np   = (!hp & !mpap & !mpbp & !lpp & out[14]); // No priority group
assign selb[0] = (hp & !out[0]) | (mpa & !out[4] & !out[5]) | (mpb & !out[7]) | (lp & !out[10] & !out[11] & !out[12]);
assign selb[1] = ((hp & !out[1]) | out[0]) | (mpa & !out[4] & out[5]) | (mpb & (out[7] | (!out[8] & out[9]))) | (lp & !out[10] & !out[11] & out[12]);
assign selb[2] = (out[0] | out[1] | (!out[2] & out[3])) | (mpa & out[4]) | (mpb & (out[7] | !out[8])) | (lp & !out[10] & out[11]);
assign selb[3] = (out[0] | out[1] | out[2]) | mpa | (lp & out[10]);

assign data  = SELA ? 1'b0 : !(&((BADR | adr | 4'h6)));
assign wradr = BADR | adr;
assign ena   = lrst | WRENA;
assign ena_bf_ce = dly_wrena & !(!dly_data & (NFREE_BLKS == 0));
assign dis_bf_ce = dly_sela & dly_scafull;
assign bf_ce     = ena_bf_ce & !dis_bf_ce;

  
cbnce #(.Width(4),.TMR(TMR)) mem_init_i (.CLK(CLK),.RST(!RST),.CE(lrst),.Q(adr));

always @(posedge CLK or posedge RST) begin
	if(RST)
		sf_clr <= 1'b1;
	else
		if(NBSEL)
			sf_clr <= RST;
end

always @(posedge CLK or posedge sf_clr) begin
	if(sf_clr)
		SCAFULL <= 1'b0;
	else
		if(NBSEL)
			SCAFULL <= !(hp | mpap | mpbp | lpp | out[14]);
end

always @(posedge CLK) begin
	if(NBSEL)
		NADR <= (RDADR & selb) | (~RDADR & ~selb);
end

always @(posedge CLK) begin
	lrst        <= RST;
	dly_data    <= data;
	dly_wrena   <= WRENA;
	dly_sela    <= SELA;
	dly_scafull <= SCAFULL;
end

udl_cnt #(.Width(4),.TMR(TMR)) free_blks_i(.CLK(CLK),.RST(1'b0),.CE(bf_ce),.L(RST),.UP(dly_data),.D(4'h9),.Q(NFREE_BLKS));

RAM16X1D #(.INIT(16'h55FF))
nb0_ram (.DPO(out[ 0]),.SPO(dmy[ 0]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0(~RDADR[0]),.DPRA1( RDADR[1]),.DPRA2( RDADR[2]),.DPRA3( RDADR[3]),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
nb1_ram (.DPO(out[ 1]),.SPO(dmy[ 1]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0( RDADR[0]),.DPRA1(~RDADR[1]),.DPRA2( RDADR[2]),.DPRA3( RDADR[3]),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
nb2_ram (.DPO(out[ 2]),.SPO(dmy[ 2]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0( RDADR[0]),.DPRA1( RDADR[1]),.DPRA2(~RDADR[2]),.DPRA3( RDADR[3]),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
nb3_ram (.DPO(out[ 3]),.SPO(dmy[ 3]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0( RDADR[0]),.DPRA1( RDADR[1]),.DPRA2( RDADR[2]),.DPRA3(~RDADR[3]),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
nb4_ram (.DPO(out[ 4]),.SPO(dmy[ 4]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0(~RDADR[0]),.DPRA1(~RDADR[1]),.DPRA2( RDADR[2]),.DPRA3( RDADR[3]),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
nb5_ram (.DPO(out[ 5]),.SPO(dmy[ 5]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0(~RDADR[0]),.DPRA1( RDADR[1]),.DPRA2(~RDADR[2]),.DPRA3( RDADR[3]),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
nb6_ram (.DPO(out[ 6]),.SPO(dmy[ 6]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0( RDADR[0]),.DPRA1(~RDADR[1]),.DPRA2(~RDADR[2]),.DPRA3( RDADR[3]),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
nb7_ram (.DPO(out[ 7]),.SPO(dmy[ 7]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0(~RDADR[0]),.DPRA1( RDADR[1]),.DPRA2( RDADR[2]),.DPRA3(~RDADR[3]),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
nb8_ram (.DPO(out[ 8]),.SPO(dmy[ 8]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0( RDADR[0]),.DPRA1(~RDADR[1]),.DPRA2( RDADR[2]),.DPRA3(~RDADR[3]),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
nb9_ram (.DPO(out[ 9]),.SPO(dmy[ 9]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0( RDADR[0]),.DPRA1( RDADR[1]),.DPRA2(~RDADR[2]),.DPRA3(~RDADR[3]),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
nba_ram (.DPO(out[10]),.SPO(dmy[10]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0(~RDADR[0]),.DPRA1(~RDADR[1]),.DPRA2(~RDADR[2]),.DPRA3( RDADR[3]),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
nbb_ram (.DPO(out[11]),.SPO(dmy[11]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0(~RDADR[0]),.DPRA1(~RDADR[1]),.DPRA2( RDADR[2]),.DPRA3(~RDADR[3]),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
nbc_ram (.DPO(out[12]),.SPO(dmy[12]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0(~RDADR[0]),.DPRA1( RDADR[1]),.DPRA2(~RDADR[2]),.DPRA3(~RDADR[3]),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
nbd_ram (.DPO(out[13]),.SPO(dmy[13]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0( RDADR[0]),.DPRA1(~RDADR[1]),.DPRA2(~RDADR[2]),.DPRA3(~RDADR[3]),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
nbe_ram (.DPO(out[14]),.SPO(dmy[14]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0(~RDADR[0]),.DPRA1(~RDADR[1]),.DPRA2(~RDADR[2]),.DPRA3(~RDADR[3]),.WCLK(CLK),.WE(ena));

RAM16X1D #(.INIT(16'h55FF))
bm0_ram (.DPO(BMEM[ 0]),.SPO(dmmy[ 0]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0(1'b0),.DPRA1(1'b0),.DPRA2(1'b0),.DPRA3(1'b0),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
bm1_ram (.DPO(BMEM[ 1]),.SPO(dmmy[ 1]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0(1'b1),.DPRA1(1'b0),.DPRA2(1'b0),.DPRA3(1'b0),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
bm2_ram (.DPO(BMEM[ 2]),.SPO(dmmy[ 2]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0(1'b0),.DPRA1(1'b1),.DPRA2(1'b0),.DPRA3(1'b0),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
bm3_ram (.DPO(BMEM[ 3]),.SPO(dmmy[ 3]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0(1'b1),.DPRA1(1'b1),.DPRA2(1'b0),.DPRA3(1'b0),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
bm4_ram (.DPO(BMEM[ 4]),.SPO(dmmy[ 4]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0(1'b0),.DPRA1(1'b0),.DPRA2(1'b1),.DPRA3(1'b0),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
bm5_ram (.DPO(BMEM[ 5]),.SPO(dmmy[ 5]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0(1'b1),.DPRA1(1'b0),.DPRA2(1'b1),.DPRA3(1'b0),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
bm6_ram (.DPO(BMEM[ 6]),.SPO(dmmy[ 6]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0(1'b0),.DPRA1(1'b1),.DPRA2(1'b1),.DPRA3(1'b0),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
bm7_ram (.DPO(BMEM[ 7]),.SPO(dmmy[ 7]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0(1'b1),.DPRA1(1'b1),.DPRA2(1'b1),.DPRA3(1'b0),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
bm8_ram (.DPO(BMEM[ 8]),.SPO(dmmy[ 8]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0(1'b0),.DPRA1(1'b0),.DPRA2(1'b0),.DPRA3(1'b1),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
bm9_ram (.DPO(BMEM[ 9]),.SPO(dmmy[ 9]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0(1'b1),.DPRA1(1'b0),.DPRA2(1'b0),.DPRA3(1'b1),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
bma_ram (.DPO(BMEM[10]),.SPO(dmmy[10]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0(1'b0),.DPRA1(1'b1),.DPRA2(1'b0),.DPRA3(1'b1),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
bmb_ram (.DPO(BMEM[11]),.SPO(dmmy[11]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0(1'b1),.DPRA1(1'b1),.DPRA2(1'b0),.DPRA3(1'b1),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
bmc_ram (.DPO(BMEM[12]),.SPO(dmmy[12]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0(1'b0),.DPRA1(1'b0),.DPRA2(1'b1),.DPRA3(1'b1),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
bmd_ram (.DPO(BMEM[13]),.SPO(dmmy[13]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0(1'b1),.DPRA1(1'b0),.DPRA2(1'b1),.DPRA3(1'b1),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
bme_ram (.DPO(BMEM[14]),.SPO(dmmy[14]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0(1'b0),.DPRA1(1'b1),.DPRA2(1'b1),.DPRA3(1'b1),.WCLK(CLK),.WE(ena));
RAM16X1D #(.INIT(16'h55FF))
bmf_ram (.DPO(BMEM[15]),.SPO(dmmy[15]),.A0(wradr[0]),.A1(wradr[1]),.A2(wradr[2]),.A3(wradr[3]),.D(data),.DPRA0(1'b1),.DPRA1(1'b1),.DPRA2(1'b1),.DPRA3(1'b1),.WCLK(CLK),.WE(ena));

endmodule
