`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:56:13 01/23/2015 
// Design Name: 
// Module Name:    jtag 
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

//////////////////////////////////////////////////////////////////////////////////
//
// JTAG Instruction Decode
//--------------------------------
// OpCode | Function
//--------------------------------
//    0   | NoOp
//    1   | SCAM Reset
//    2   | Check CFEB status, Shift only
//    3   | Check CFEB status, Capture and shift
//    4   | Program Comparator DAC
//    5   | Load extra L1A delay
//    6   | Load cfeb_config register with TRG_DCD,MTCH_3BX,LAT_12_5US
//    7   | Load f5, f8, and f9
//    8   | Load PRE_BLOCK_END
//    9   | Load Comparator MODE and TIME
//   10   | Buckeye mask, default 111111
//   11   | Buckeye shift in/shift out
//

module jtag #(
	parameter TMR = 0
)(
	input CLK25,
	input RST,
	input UPDATE,
	input SHIFT,
	input BTDI,
	input SEL1,
	input SEL2,
	input DRCK1,
	input DRCK2,
	input [6:1] AMPOUT,
	input [15:0] CSTATUS,
	output TDO1,
	output TDO2,
	output DACCLK,
	output DACDAT,
	output DAC_ENB_B,
	inout  DMYSHIFT,
	output TRG_DCD,
	output MTCH_3BX,
	output LAT_12_5US,
	output [3:0] LOADPBLK,
	output [1:0] XL1DLYSET,
	output [1:0] CMODE,
	output [2:0] CTIME,
	output [6:1] AMPIN,
	output [6:1] AMPCLK
);

wire [31:16] jstatus;
reg [15:0] f;
reg [7:0] dcmd;
wire lxdlyout;
wire pbeout;
wire tdof232;
wire tdof62;
wire tdof82;
wire tdof92;
wire tdofa2;
wire tdofb2;
wire tdof52;
wire dsy7;	
wire dmy2;	
wire dmy3;	
wire dmy4;	
wire dshift;
reg dly_update;
wire [6:1] bky_mask;

initial
begin
	f = 0;
	dcmd = 0;
	dly_update = 0;
end

assign TDO2 = tdof232 | tdof62 | tdof82 | tdof92 | tdofa2 | tdofb2 | tdof52;
assign jstatus = {2'b10,TRG_DCD,MTCH_3BX,LAT_12_5US,XL1DLYSET,LOADPBLK,CTIME,CMODE};
assign TDO1 = dcmd[0];

//
// instruction decode
//
always @(posedge DRCK1) begin
	if(SEL1 & SHIFT)
		dcmd <= {BTDI,dcmd[7:1]};
end

always @(posedge CLK25) begin
	dly_update <= UPDATE;
end
always @(posedge CLK25) begin
	if(UPDATE & !dly_update)
		case (dcmd[3:0])
			4'h0:   f <= 16'h0001;
			4'h1:   f <= 16'h0002;
			4'h2:   f <= 16'h0004;
			4'h3:   f <= 16'h0008;
			4'h4:   f <= 16'h0010;
			4'h5:   f <= 16'h0020;
			4'h6:   f <= 16'h0040;
			4'h7:   f <= 16'h0080;
			4'h8:   f <= 16'h0100;
			4'h9:   f <= 16'h0200;
			4'hA:   f <= 16'h0400;
			4'hB:   f <= 16'h0800;
			4'hC:   f <= 16'h1000;
			4'hD:   f <= 16'h2000;
			4'hE:   f <= 16'h4000;
			4'hF:   f <= 16'h8000;
		endcase
end

  
//
// JTAG User Functions  Uses User 2 BSCAN signals
//
//
// JTAG Extra L1A Delay Register
//
// Load 00: The LCT to L1A latency is 2900ns
// Load 01: The LCT to L1A latency is 3300ns
// Load 10: The LCT to L1A latency is 3700ns
// Load 11: The LCT to L1A latency is 4100ns
// default is 01: set to 3300ns, same as current setting (MTCC with EMU trigger)

user_wr_reg #(.width(2), .def_value(2'b01), .TMR(TMR))
load_xl1dly(
	.CLK25(CLK25),
	.DRCK(DRCK2),        // Data Reg Clock
	.FSEL(f[5]),        // Function select
	.SEL(SEL2),        // User 2 mode active
	.TDI(BTDI),          // Serial Test Data In
	.DSY_IN(BTDI),       // Serial Daisy chained data in
	.SHIFT(SHIFT),      // Shift state
	.UPDATE(UPDATE),    // Update state
	.RST(RST),          // Reset default state
	.DSY_CHAIN(f[7]),   // Daisy chain mode
	.PO(XL1DLYSET),     // Parallel output
	.TDO(tdof52),        // Serial Test Data Out
	.DSY_OUT(lxdlyout));// Daisy chained serial data out

//
// JTAG Pre block end register  
//	
user_wr_reg #(.width(4), .def_value(4'h9), .TMR(TMR))
load_preblk(
	.CLK25(CLK25),
	.DRCK(DRCK2),        // Data Reg Clock
	.FSEL(f[8]),        // Function select
	.SEL(SEL2),        // User 2 mode active
	.TDI(BTDI),         // Serial Test Data In
	.DSY_IN(lxdlyout),  // Serial Daisy chained data in
	.SHIFT(SHIFT),      // Shift state
	.UPDATE(UPDATE),    // Update state
	.RST(RST),          // Reset default state
	.DSY_CHAIN(f[7]),   // Daisy chain mode
	.PO(LOADPBLK),      // Parallel output
	.TDO(tdof82),        // Serial Test Data Out
	.DSY_OUT(pbeout));  // Daisy chained serial data out

//
// JTAG Comparator Mode and Timing bits Register
//
user_wr_reg #(.width(5), .def_value(5'b01010), .TMR(TMR))
comparator(
	.CLK25(CLK25),
	.DRCK(DRCK2),        // Data Reg Clock
	.FSEL(f[9]),        // Function select
	.SEL(SEL2),        // User 2 mode active
	.TDI(BTDI),         // Serial Test Data In
	.DSY_IN(pbeout),    // Serial Daisy chained data in
	.SHIFT(SHIFT),      // Shift state
	.UPDATE(UPDATE),    // Update state
	.RST(RST),          // Reset default state
	.DSY_CHAIN(f[7]),   // Daisy chain mode
	.PO({CTIME,CMODE}),      // Parallel output
	.TDO(tdof92),        // Serial Test Data Out
	.DSY_OUT(dsy7));  // Daisy chained serial data out


//
// JTAG to Comparator DAC
//
IOBUF
DmyShiftDly_i (
	.O(dshift),     // Buffer output
	.IO(DMYSHIFT),   // Buffer inout port (connect directly to top-level port)
	.I(SHIFT),     // Buffer input
	.T(1'b0)      // 3-state enable input, high=input, low=output
);
PULLDOWN DmyShiftDlyPD_i (.O(DMYSHIFT));

assign cdac_ena  = dshift & SEL2 & f[4];
assign DAC_ENB_B = !cdac_ena;
assign DACDAT    = cdac_ena & BTDI;
assign DACCLK    = cdac_ena & DRCK2;

	
//
// Status capture and shift
//
   user_cap_reg #(.width(32))
   status1(
      .DRCK(DRCK2),        // Data Reg Clock
      .FSH(f[2]),         // Shift Function
      .FCAP(f[3]),        // Capture Function
      .SEL(SEL2),        // User 2 mode active
      .TDI(BTDI),          // Serial Test Data In
      .SHIFT(SHIFT),      // Shift state
      .RST(RST),       // Reset default state
		.BUS({jstatus,CSTATUS}), // Bus to capture
      .TDO(tdof232));      // Serial Test Data Out

	
//
// JTAG Buckeye mask register for which amplifiers are in the shift loop.
//
	
user_wr_reg #(.width(6), .def_value(6'b111111), .TMR(TMR))
buckeye_mask(
	.CLK25(CLK25),
	.DRCK(DRCK2),       // Data Reg Clock
	.FSEL(f[10]),       // Function select
	.SEL(SEL2),         // User 2 mode active
	.TDI(BTDI),         // Serial Test Data In
	.DSY_IN(1'b0),      // Serial Daisy chained data in
	.SHIFT(SHIFT),      // Shift state
	.UPDATE(UPDATE),    // Update state
	.RST(RST),          // Reset default state
	.DSY_CHAIN(1'b0),   // Daisy chain mode
	.PO(bky_mask),      // Parallel output
	.TDO(tdofa2),        // Serial Test Data Out
	.DSY_OUT(dmy2));    // Daisy chained serial data out

//
// JTAG Buckeye shift clocks data mutiplexers
//
bky_shift 
bky_shift1 (
	.DRCK(DRCK2),       // Data Reg Clock
	.SEL(SEL2),         // User 2 mode active
	.F(f[11]),          // Function select
	.TDI(BTDI),         // Serial Test Data In
	.MASK(bky_mask),    // Mask of which amplifiers to include in shift loop
	.SHIFT(dshift),     // Shift state
	.DRTN(AMPOUT),     // Serial data returned from amplifiers
	.DSND(AMPIN),      // Serial data sent to amplifiers
	.BCLK(AMPCLK),     // Shift clock for amplifiers
	.TDO(tdofb2)        // Test data out of the complete loop
);
		

//
// JTAG configuration register
// selects operating mode -- 4 bits {reserved,trg_decode,3bx_matching,12.5us L1A latency}
//
user_wr_reg #(.width(4), .def_value(4'b0000), .TMR(TMR))
cfeb_config (
	.CLK25(CLK25),
	.DRCK(DRCK2),        // Data Reg Clock
	.FSEL(f[6]),        // Function select
	.SEL(SEL2),        // User 2 mode active
	.TDI(BTDI),         // Serial Test Data In
	.DSY_IN(1'b0),    // Serial Daisy chained data in
	.SHIFT(SHIFT),      // Shift state
	.UPDATE(UPDATE),    // Update state
	.RST(RST),          // Reset default state
	.DSY_CHAIN(1'b0),   // Daisy chain mode
	.PO({dmy3,TRG_DCD,MTCH_3BX,LAT_12_5US}), // Parallel output
	.TDO(tdof62),        // Serial Test Data Out
	.DSY_OUT(dmy4));  // Daisy chained serial data out



endmodule
