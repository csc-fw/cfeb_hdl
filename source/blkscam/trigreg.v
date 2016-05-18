`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:19:18 02/10/2015 
// Design Name: 
// Module Name:    trigreg 
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
module trigreg #(
	parameter TMR = 0,
	parameter LAT_12_5us = 0,
	parameter MTCH_3BX = 0
)(
	input CLK,
	input RST,
	input LCT_SRL1,
	input GIN,
	input [1:0] XL1DLYSET,
	output reg MATCHR,
	output reg NO_MATCH,
	output reg GMATCH,
	output reg MATCH, //DAV
	output reg MISS_MATCH
);

reg lct_fdc1;
reg lct_fdc2;
reg lct_fdc3;
wire lct_srl2;
wire lct_srl3;
wire l1dly0;
wire l1dly1;
wire l1dly2;
wire l1dly3;
reg llout_m1;
reg llout0;
reg llout_p1;
reg llout_p2;
reg llout_p3;
wire lct_window;
wire l1a_window;
wire prematch;
wire match_disable;
wire pmatch;
wire pmiss;
wire pno;
reg  pno_p1;
reg  pno_p2;
wire pyes;
reg  pyes_p1;
reg  pyes_p2;
wire no_match_1;
wire matchr_1;
reg gin1;
reg gin2;
reg gin3;
reg gin4;
wire overlap;
wire medge;
wire [1:0] qovr;

initial begin
	lct_fdc1 = 0;
	lct_fdc2 = 0;
	lct_fdc3 = 0;
end

generate
if(MTCH_3BX==1) 
begin : mtchlog_3bx
	assign lct_window = llout_m1 | llout0 | llout_p1;
	assign l1a_window = GIN | gin1 | gin2;
	assign pno        = llout0 & !l1a_window;
	assign pyes       = llout0 &  l1a_window;
	assign no_match_1 = pno_p2;
	assign matchr_1   = pyes_p2;
end
else
begin : mtchlog_nbx
	assign lct_window = llout_m1 | llout0 | llout_p1 | llout_p2 | llout_p3;
	assign l1a_window = GIN | gin1 | gin2 | gin3 | gin4;
	assign pno        = llout_p2 & !l1a_window;
	assign pyes       = llout_p2 &  l1a_window;
	assign no_match_1 = pno;
	assign matchr_1   = pyes;
end
endgenerate

assign prematch      = lct_window & gin1;
assign match_disable = overlap & !medge;
assign pmatch        = prematch & !match_disable;
assign pmiss         = prematch & match_disable;
assign overlap       = qovr[1];

always @(posedge CLK or posedge RST) begin
	if(RST)
		begin
			gin1     <= 1'b0;
			gin2     <= 1'b0;
			gin3     <= 1'b0;
			gin4     <= 1'b0;
			pno_p1   <= 1'b0;
			pno_p2   <= 1'b0;
			pyes_p1  <= 1'b0;
			pyes_p2  <= 1'b0;
			NO_MATCH <= 1'b0;
			MATCHR   <= 1'b0;
			GMATCH   <= 1'b0;
		end
	else
		begin
			gin1     <= GIN;
			gin2     <= gin1;
			gin3     <= gin2;
			gin4     <= gin3;
			pno_p1   <= pno;
			pno_p2   <= pno_p1;
			pyes_p1  <= pyes;
			pyes_p2  <= pyes_p1;
			NO_MATCH <= no_match_1;
			MATCHR   <= matchr_1;
			GMATCH   <= pmatch;
		end
end

always @(posedge CLK) begin
	lct_fdc1 <= LCT_SRL1;
	lct_fdc2 <= lct_srl2;
	lct_fdc3 <= lct_srl3;
end

//srl_nx1 #(.Depth(16))  lct_delay_1i (.CLK(CLK),.CE(1'b1),.I(LIN),     .O(lct_srl1)); // Moved up to blkscam level
srl_nx1 #(.Depth(16))  lct_delay_2i (.CLK(CLK),.CE(1'b1),.I(lct_fdc1),.O(lct_srl2));
srl_nx1 #(.Depth(16))  lct_delay_3i (.CLK(CLK),.CE(1'b1),.I(lct_fdc2),.O(lct_srl3));
generate
if(LAT_12_5us==1) 
begin : lat_12_5us
	srl_nx1 #(.Depth(432)) lct_delay_4i (.CLK(CLK),.CE(1'b1),.I(lct_fdc3),.O(l1dly0));
end
else
begin : lat_3_2us
	srl_nx1 #(.Depth(64)) lct_delay_4i (.CLK(CLK),.CE(1'b1),.I(lct_fdc3),.O(l1dly0));
end
endgenerate
srl_nx1 #(.Depth(16))  lct_delay_5i (.CLK(CLK),.CE(1'b1),.I(l1dly0),  .O(l1dly1));
srl_nx1 #(.Depth(16))  lct_delay_6i (.CLK(CLK),.CE(1'b1),.I(l1dly1),  .O(l1dly2));
srl_nx1 #(.Depth(16))  lct_delay_7i (.CLK(CLK),.CE(1'b1),.I(l1dly2),  .O(l1dly3));


always @(posedge CLK or posedge RST) begin
	if(RST)
		begin
			llout_m1 <= 1'b0;
			llout0  <= 1'b0;
			llout_p1 <= 1'b0;
			llout_p2 <= 1'b0;
			llout_p3 <= 1'b0;
		end
	else
		begin
			case (XL1DLYSET)
				2'b00: llout_m1 <= l1dly0;
				2'b01: llout_m1 <= l1dly1;
				2'b10: llout_m1 <= l1dly2;
				2'b11: llout_m1 <= l1dly3;
			endcase
			llout0   <= llout_m1;
			llout_p1 <= llout0;
			llout_p2 <= llout_p1;
			llout_p3 <= llout_p2;
		end
		
end

(* syn_useioff = "True" *)
always @(posedge CLK) begin
	MATCH      <= pmatch;
	MISS_MATCH <= pmiss;
end

srl_nx1 #(.Depth(16))  medge_srl_i (.CLK(CLK),.CE(1'b1),.I(pmatch),  .O(medge));

udl_cnt #(.Width(2),.TMR(TMR)) overlap_cnt_i(.CLK(CLK),.RST(RST),.CE(medge ^ pmatch),.L(1'b0),.UP(pmatch),.D(2'b00),.Q(qovr));

endmodule
