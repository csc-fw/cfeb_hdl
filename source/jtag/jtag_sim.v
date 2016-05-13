`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:42:44 02/02/2015
// Design Name:   jtag
// Module Name:   C:/Users/bylsma/Projects/CFEB/Firmware/cfeb12_5us_lat_hdl/source/jtag/jtag_sim.v
// Project Name:  cfeb12_5us_lat_hdl
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: jtag
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module jtag_sim;

	// Inputs
	reg CLK25;
	reg TCK;
	reg TMS;
	reg TDI;
	reg RST;
	wire [6:1] AMPOUT;
	reg [15:0] CSTATUS;

	// Outputs
	wire TDO;
	wire DACCLK;
	wire DACDAT;
	wire DAC_ENB_B;
	wire [3:0] LOADPBLK;
	wire [1:0] XL1DLYSET;
	wire [1:0] CMODE;
	wire [2:0] CTIME;
	wire [6:1] AMPIN;
	wire [6:1] AMPCLK;

	// Bidirs
	wire DMYSHIFT;

	wire tlrst;
	wire update;
	wire shift;
	wire btdi;
	wire sel1;
	wire sel2;
	wire drck1;
	wire drck2;
	wire tdo1;
	wire tdo2;

	// Instantiate the Unit Under Test (UUT)
	jtag#(
		.SIM(1),
		.TMR(0)
	)
		uut (
		.CLK25(CLK25),
		.RST(RST), 
		.UPDATE(update), 
		.SHIFT(shift), 
		.BTDI(btdi), 
		.SEL1(sel1), 
		.SEL2(sel2), 
		.DRCK1(drck1), 
		.DRCK2(drck2), 
		.AMPOUT(AMPOUT), 
		.CSTATUS(CSTATUS), 
		.TDO1(tdo1), 
		.TDO2(tdo2), 
		.DACCLK(DACCLK), 
		.DACDAT(DACDAT), 
		.DAC_ENB_B(DAC_ENB_B), 
		.DMYSHIFT(DMYSHIFT), 
		.LOADPBLK(LOADPBLK), 
		.XL1DLYSET(XL1DLYSET), 
		.CMODE(CMODE), 
		.CTIME(CTIME), 
		.AMPIN(AMPIN), 
		.AMPCLK(AMPCLK)
	);


BSCAN_VIRTEX_sim BSCAN_VIRTEX_sim_inst (
	.TDO(TDO),
	.DRCK1(drck1),     // Data register output for USER1 functions
	.DRCK2(drck2),     // Data register output for USER2 functions
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
	.TRST(RST),
	.TDI(TDI)
);

	
   parameter PERIOD = 24;
	parameter JPERIOD = 100;
	parameter ir_width = 5;
	parameter max_width = 300;

   reg [47:0] bky1sh,bky2sh,bky3sh,bky4sh,bky5sh,bky6sh;

   integer i;
	reg [7:0] jrst;
	reg [3:0] sir_hdr;
	reg [3:0] sdr_hdr;
	reg [2:0] trl;
	reg [ir_width-1:0] usr1;
	reg [ir_width-1:0] usr2;
	
	initial begin
		// Initialize Inputs
      CLK25 = 1'b0;
      forever
         #(PERIOD/2) CLK25 = ~CLK25;
	end

	initial begin
		// Initialize Inputs
		RST = 0;
		TCK = 1;
		TMS = 1;
		TDI = 0;
		CSTATUS = 16'h3d9c;
      jrst = 8'b00111111;
      sir_hdr = 4'b0011;
      sdr_hdr = 4'b0010;
		trl = 3'b001;
		usr1 = 5'd2; // usr1 instruction
		usr2 = 5'd3; // usr2 instruction
		

		// Wait 100 ns for global reset to finish
		#100;
		
		#(20*PERIOD);
		RST = 1;
		#(6*PERIOD);
		RST = 0;
		#(20*PERIOD);
		
        
// Function  Description
// ---------------------------------------
//   0     | No Op 
//   1     | SCAM Reset (not needed in DCFEB)
//   2     | DCFEB status reg shift only
//   3     | DCFEB status reg capture and shift
//   4     | Program Comparator DAC
//   5     | Set Extra L1a Delay
//   6     | 
//   7     | Set F5, F8, and F9 in one serial loop (daisy chained)
//   8     | Set Pre Block End (not needed in DCFEB)
//   9     | Set Comparator Mode and Timing bits
//  10     | Set Buckeye Mask for shifting (default 6'b111111)
//  11     | Shift data to/from Buckeye chips

		JTAG_reset;
		
		#(4*PERIOD);
		
		Set_Func(8'h05);           // Extra L1A Delay
		Set_User(usr2);            // User 2 for User Reg access
		Shift_Data(2,2'b10);       // xl1a data
		
		#(4*PERIOD);
		
		Set_Func(8'h08);           // Pre block end
		Set_User(usr2);            // User 2 for User Reg access
		Shift_Data(4,4'b0011);       // preblock data
		
		#(4*PERIOD);
		
		Set_Func(8'h09);           // Comp mode and timing
		Set_User(usr2);            // User 2 for User Reg access
		Shift_Data(5,5'b01001);       // Comp timing, comp mode data
		
		#(4*PERIOD);
		
		Set_Func(8'h07);           // daisy chained registers
		Set_User(usr2);            // User 2 for User Reg access
		Shift_Data(11,11'b11010010011);   // xl1a, pblock, C timing, C mode
		
		#(4*PERIOD);
		
		Set_Func(8'h0A);           // Buckeye mask
		Set_User(usr2);            // User 2 for User Reg access
		Shift_Data(6,6'b001000);       //buckeye mask
		
		#(4*PERIOD);
		
		Set_Func(8'h0B);           // Buckeye shift
		Set_User(usr2);            // User 2 for User Reg access
		Shift_Data(48,48'h3F78D2BC9AE1);       // data for one chip
		
		#(4*PERIOD);
		
		Set_Func(8'h03);           // capture and shift status
		Set_User(usr2);            // User 2 for User Reg access
		Shift_Data(32,32'h000000000000);       // return data is important
		
		#(4*PERIOD);
		
		Set_Func(8'h0A);           // Buckeye mask
		Set_User(usr2);            // User 2 for User Reg access
		Shift_Data(6,6'b111111);       //All buckeye
		
		#(4*PERIOD);
		
		Set_Func(8'h0B);           // Buckeye shift
		Set_User(usr2);            // User 2 for User Reg access
		Shift_Data(6*48,288'h111111111111222222222222333333333333444444444444555555555555666666666666);       // data for all chips
		
		#(4*PERIOD);
		
		Set_Func(8'h04);           // Program Comparator DAC
		Set_User(usr2);            // User 2 for User Reg access
		Shift_Data(12,12'h35b);       // data for DAC
		
		#(4*PERIOD);
		

	end

	
	// Buckeye shift registers
	
	always @(posedge AMPCLK[1])	   bky1sh <= {AMPIN[1],bky1sh[47:1]};
	always @(posedge AMPCLK[2])	   bky2sh <= {AMPIN[2],bky2sh[47:1]};
	always @(posedge AMPCLK[3])	   bky3sh <= {AMPIN[3],bky3sh[47:1]};
	always @(posedge AMPCLK[4])	   bky4sh <= {AMPIN[4],bky4sh[47:1]};
	always @(posedge AMPCLK[5])	   bky5sh <= {AMPIN[5],bky5sh[47:1]};
	always @(posedge AMPCLK[6])	   bky6sh <= {AMPIN[6],bky6sh[47:1]};
		
   assign AMPOUT = {bky6sh[0],bky5sh[0],bky4sh[0],bky3sh[0],bky2sh[0],bky1sh[0]};
	
	
task JTAG_reset;
begin
	// JTAG reset
	TMS = 1'b1;
	TDI = 1'b0;
	for(i=0;i<8;i=i+1) begin
		TMS = jrst[i];
		TCK = 1'b0;
		#(JPERIOD/2) TCK = 1'b1;
		#(JPERIOD/2);
	end
end
endtask

task Set_Func;
input [7:0] func;
begin
	Set_User(usr1);       // User 1 for instruction decode
	Shift_Data(8,func);   // Shift function code
end
endtask


task Set_User;
input [ir_width-1:0] usr;
begin
	// go to sir
	TDI = 1'b0;
	for(i=0;i<4;i=i+1) begin
		TMS = sir_hdr[i];
		TCK = 1'b0;
		#(JPERIOD/2) TCK = 1'b1;
		#(JPERIOD/2);
	end
	// shift instruction
	TMS = 1'b0;
	for(i=0;i<ir_width;i=i+1) begin
		if(i==ir_width-1)TMS = 1'b1;
		TDI = usr[i];       // User 1, 2, 3, or 4 instruction
		TCK = 1'b0;
		#(JPERIOD/2) TCK = 1'b1;
		#(JPERIOD/2);
	end
	// go to rti
	TDI = 1'b0;
	for(i=0;i<3;i=i+1) begin
		TMS = trl[i];
		TCK = 1'b0;
		#(JPERIOD/2) TCK = 1'b1;
		#(JPERIOD/2);
	end
end
endtask


task Shift_Data;
input integer width;
input [max_width-1:0] d;
begin
		// go to sdr
		TDI = 1'b0;
		for(i=0;i<4;i=i+1) begin
		   TMS = sdr_hdr[i];
			TCK = 1'b0;
			#(JPERIOD/2) TCK = 1'b1;
			#(JPERIOD/2);
		end
		// shift function data 
		TMS = 1'b0;
		for(i=0;i<width;i=i+1) begin
		   if(i==(width-1))TMS = 1'b1;
			TDI = d[i];
			TCK = 1'b0;
			#(JPERIOD/2) TCK = 1'b1;
			#(JPERIOD/2);
		end
		// go to rti
		TDI = 1'b0;
		for(i=0;i<3;i=i+1) begin
		   TMS = trl[i];
			TCK = 1'b0;
			#(JPERIOD/2) TCK = 1'b1;
			#(JPERIOD/2);
		end
end
endtask

      
endmodule

