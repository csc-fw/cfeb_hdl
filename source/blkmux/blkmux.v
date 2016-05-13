`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:22:03 01/07/2015 
// Design Name: 
// Module Name:    blkmux 
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
module blkmux (
    input CLK25,
    input CLK150,
    input RST,
    input START,
    input OECRC,
    input DLOAD,
    input OVLPINT,
    input [15:0] DATA,
    input [6:1] OE_B,
    input [12:0] K1ADC,
    input [12:0] K2ADC,
    input [12:0] K3ADC,
    input [12:0] K4ADC,
    input [12:0] K5ADC,
    input [12:0] K6ADC,
    input [5:0] L1ANOUT,
    input [23:0] STATUS,
    output reg OVERLAP,
    output reg [15:0] OUT
    );

reg [15:1] crc;
wire [15:1] dlycrc;
reg [7:1] oen_b;
reg [15:0] datamx;
reg [12:0] adc1b;
reg [12:0] adc2b;
reg [12:0] adc3b;
reg [12:0] adc4b;
reg [12:0] adc5b;
reg [12:0] adc6b;
reg [15:0] datax;
reg oecheck_b;
wire d_oecheck_b;
reg oecheck_1;
reg ovrlp;
reg ovrlp_1;
reg oecrc_1;
reg oecrc_b;
reg oecrc_b_1;
reg oecrcout_b;
reg oecnt1_b;
reg oecnt3_b;
reg oecrcrev_b;
reg oec;
reg oecrc5;
wire clr_oec;
wire selhb;
reg st_crc;
reg start_1;
reg clr_clr;
reg clr_crc;

initial begin
	oecrc_b = 1'b1;
end

assign selhb    = |STATUS[14:12];
assign clr_oec  = RST | !d_oecheck_b;

always @(posedge CLK25)
begin
	oen_b      <=  {1'b0,OE_B} | {!DLOAD,{6{DLOAD}}} | {1'b0,{6{!oecheck_b}}};
	oecheck_b  <= !oecrc5;
	oecheck_1  <= !oecheck_b;
	
	oecrc_1    <=  OECRC;
	oecrc_b    <= !(oecrc5 & oecheck_b);
	oecrc_b_1  <=  oecrc_b;
	oecrcout_b <=  oecrc_b_1;
	oecnt1_b   <=  oecrcout_b;
	oecnt3_b   <=  oecnt1_b;
	oecrcrev_b <=  oecnt3_b;
end

always @(posedge CLK25 or posedge clr_oec) begin
	if(clr_oec) begin
		oec    <= 1'b0;
		oecrc5 <= 1'b0;
	end
	else begin
		if(OECRC & !oecrc_1) oec <= 1'b1;
		if(!oen_b[4])     oecrc5 <= (OECRC & !oecrc_1) | oec;
	end
end

srl_nx1 #(.Depth(3)) oec_delay_i (.CLK(CLK25),.CE(1'b1),.I(oecheck_b),.O(d_oecheck_b));


(* syn_useioff = "True" *)
always @(negedge CLK150)
begin
	adc1b <= K1ADC;
	adc2b <= K2ADC;
	adc3b <= K3ADC;
	adc4b <= K4ADC;
	adc5b <= K5ADC;
	adc6b <= K6ADC;
end

always @(negedge CLK150)
begin
	datax <= DATA;
	ovrlp <= OVLPINT;
end

always @(posedge CLK25)
begin
	ovrlp_1 <= ovrlp;
	case (oen_b)
		7'b1111110: datamx <= {datax[15:13],adc1b};
		7'b1111101: datamx <= {datax[15:13],adc2b};
		7'b1111011: datamx <= {datax[15:13],adc3b};
		7'b1110111: datamx <= {datax[15:13],adc4b};
		7'b1101111: datamx <= {datax[15:13],adc5b};
		7'b1011111: datamx <= {datax[15:13],adc6b};
		7'b0111111: datamx <=  datax;              // for "B" codes when no data is available to digitize
		default:    datamx <= {datax[15:13],1'b0,12'hBAD};
	endcase
end
(* syn_useioff = "True" *)
always @(posedge CLK25)
begin
	OVERLAP <= ovrlp_1;
	case ({oecrcrev_b,oecnt3_b,oecnt1_b,oecrcout_b})
		4'b1110: OUT <= {datamx[15],crc};
		4'b1101: OUT <= {datamx[15],3'b111,STATUS[19:16],STATUS[7:0]};
		4'b1011: OUT <= {datamx[15],3'b111,L1ANOUT,selhb,(selhb ? STATUS[14:11] : STATUS[11:8]),(|STATUS[15:13])};
		4'b0111: OUT <= {datamx[15],~dlycrc};
		default: OUT <= datamx;
	endcase
end

srl_nxm #(.Depth(3),.Width(15)) crc_delay_i (.CLK(CLK25),.CE(1'b1),.I(crc),.O(dlycrc));

always @(posedge CLK25)
begin
	clr_clr <= !oen_b[1];
	start_1 <= START;
end
always @(posedge CLK25 or posedge clr_clr)
begin
	if(clr_clr) begin
		clr_crc <= 1'b0;
		st_crc  <= 1'b0;
	end
	else begin
		if(START & !start_1)
			st_crc <= 1'b1; 
		if(!oen_b[5])
			clr_crc <= (START & !start_1) | st_crc;
	end
end

always @(posedge CLK25 or posedge clr_crc)
begin
	if(clr_crc)
		crc <= 15'h0000;
	else
		crc <= CRC15_D13(datamx[12:0],crc);
;
end

function [14:0] CRC15_D13 (input [12:0] d, input [14:0] c);
  reg [14:0] newcrc;
  begin
	 newcrc[0] =   d[0] ^                  c[2];
	 newcrc[1] =   d[0] ^  d[1] ^  c[2] ^  c[3];
	 newcrc[2] =   d[1] ^  d[2] ^  c[3] ^  c[4];
	 newcrc[3] =   d[2] ^  d[3] ^  c[4] ^  c[5];
	 newcrc[4] =   d[3] ^  d[4] ^  c[5] ^  c[6];
	 newcrc[5] =   d[4] ^  d[5] ^  c[6] ^  c[7];
	 newcrc[6] =   d[5] ^  d[6] ^  c[7] ^  c[8];
	 newcrc[7] =   d[6] ^  d[7] ^  c[8] ^  c[9];
	 newcrc[8] =   d[7] ^  d[8] ^  c[9] ^ c[10];
	 newcrc[9] =   d[8] ^  d[9] ^ c[10] ^ c[11];
	 newcrc[10] =  d[9] ^ d[10] ^ c[11] ^ c[12];
	 newcrc[11] = d[10] ^ d[11] ^ c[12] ^ c[13];
	 newcrc[12] = d[11] ^ d[12] ^ c[13] ^ c[14];
	 newcrc[13] = d[12]         ^ c[14] ^  c[0];
	 newcrc[14] =                          c[1];
	 CRC15_D13 = newcrc;
  end
endfunction


endmodule
