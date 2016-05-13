`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    12:38:18 02/04/2015 
// Design Name: 
// Module Name:    BSCAN_VIRTEX_sim 
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
module BSCAN_VIRTEX_sim(
    input TCK,
    input TMS,
    input TDI,
    input TRST,
    input TDO1,
    input TDO2,
    output reg TDO,
    output reg DRCK1,
    output reg DRCK2,
    output reg RESET,
    output reg SEL1,
    output reg SEL2,
    output reg SHIFT,
    output BTDI,
    output reg UPDATE
    );

reg [4:0] ir;
wire capture_dr;
wire rtidle;
wire shift_dr;
wire shift_ir;
wire tlreset;
wire update_dr;
wire update_ir;

assign BTDI = TDI;


JTAG_TAP_ctrl JTAG_TAP_ctrl_i (
	.CAPTURE_DR(capture_dr),
	.RTIDLE(rtidle),
	.SHIFT_DR(shift_dr),
	.SHIFT_IR(shift_ir),
	.TLRESET(tlreset),
	.UPDATE_DR(update_dr),
	.UPDATE_IR(update_ir),
	.TCK(TCK),
	.TDI(TDI),
	.TMS(TMS),
	.TRST(TRST) 
);

always @(posedge TCK or posedge TRST) begin
	if(TRST)
	  ir <= 5'd0;
	else
		if(shift_ir)
			ir <= {TDI,ir[4:1]};
		else
			ir <= ir;
end

always @(negedge TCK or posedge TRST) begin
	if(TRST)
		begin
			SEL1 <= 1'b0;
			SEL2 <= 1'b0;
		end
	else
		if(update_ir)
			begin
				SEL1 <= (ir == 5'd2);
				SEL2 <= (ir == 5'd3);
			end
		else 
			begin
				SEL1 <= SEL1;
				SEL2 <= SEL2;
			end
end

always @(negedge TCK or posedge TRST) begin
	if(TRST)
		begin
			RESET  <= 1'b0;
			SHIFT  <= 1'b0;
			UPDATE <= 1'b0;
		end
	else
		begin
			RESET  <= tlreset;
			SHIFT  <= shift_dr;
			UPDATE <= update_dr;
		end
end

always @(negedge TCK or posedge TRST) begin
	if(TRST)
		TDO <= 1'bz;
	else
		if(shift_ir)
			TDO <= ir[0];
		else if(shift_dr)
		   if(SEL1)
				TDO <= TDO1;
			else if(SEL2)
				TDO <= TDO2;
			else
				TDO <= 1'bz;
		else
			TDO <= 1'bz;
end

always @* begin
	if(capture_dr || shift_dr)
		if(SEL1)
			begin
				DRCK1 <= TCK;
				DRCK2 <= 1'b1;
			end
		else if(SEL2)
			begin
				DRCK1 <= 1'b1;
				DRCK2 <= TCK;
			end
		else
			begin
				DRCK1 <= 1'b1;
				DRCK2 <= 1'b1;
			end
	else
		begin
			DRCK1 <= 1'b1;
			DRCK2 <= 1'b1;
		end
end

endmodule
