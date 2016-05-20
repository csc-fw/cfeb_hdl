`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:21:06 02/05/2015 
// Design Name: 
// Module Name:    scamcntrl 
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
module scamcntrl #(
	parameter TMR = 0
)(
	input CLK,
	input RST,
	input LCTDLY,
	input [3:0] LOADPBLK,
	input DONE,
	input NOL1A_MATCH,
	input NODATA,
	input FB_NODATA,
	input SCND_BLK,
	input SCND_SHARED,
	input DLSCAFULL,
	input DSCAFULL,
	input MTCH_3BX,

	output [3:0] STATE,
	output LCTYENA,
	output SELA,
	output SELB,
	output reg SELC,
	output reg SELD,
	output WRENA,
	output ENAREG,
	output PREBLKEND,
	output NBSEL,
	output NOLCT
);

wire lctsave;
wire [3:0] lctinblk;
reg lct_frst;
reg lct_scnd;
reg lct_thrd;
reg llct;

always @*
begin
	if(MTCH_3BX==1) begin
		SELC      = DONE & SCND_BLK & !SCND_SHARED & !NODATA &(STATE == 4'd2);
		SELD      = DONE & SCND_BLK & !FB_NODATA & (STATE == 4'd4);
		llct      = lct_frst | lct_scnd;
	end
	else begin
		SELC      = DONE & !NODATA &(STATE == 4'd2);
		SELD      = 1'b0;
		llct      = lct_frst | lct_scnd | lct_thrd;
	end
end

assign lctsave   = |{lctinblk,LCTDLY}; // OR reduction.
assign LCTYENA   = llct & (STATE == 4'd14); 
assign NOLCT     = !llct & !DSCAFULL & (STATE == 4'd14); 
assign PREBLKEND = (STATE == 4'd13);
assign SELA      = (STATE == 4'd5);
assign SELB      = NOL1A_MATCH & !DLSCAFULL & (STATE == 4'd3);
assign ENAREG    = (STATE == 4'd15);
assign NBSEL     = (STATE == 4'd14);
assign WRENA     = SELA | SELB | SELC | SELD | NOLCT;

cbnce #(.Width(4),.TMR(TMR)) state_cnt_i (.CLK(CLK),.RST(RST),.CE(1'b1),.Q(STATE));

cbncer #(.Width(4),.TMR(TMR)) lct_cnt_i (.CLK(CLK),.SRST(PREBLKEND),.CE(LCTDLY),.Q(lctinblk));

always @(posedge CLK or posedge RST) begin
	if(RST)
		begin
			lct_frst <= 1'b0;
			lct_scnd <= 1'b0;
			lct_thrd <= 1'b0;
		end
	else
		if(PREBLKEND)
			begin
				lct_frst <= lctsave;
				lct_scnd <= lct_frst;
				lct_thrd <= lct_scnd;
			end
end

endmodule
