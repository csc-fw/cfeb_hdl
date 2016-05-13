`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   14:20:55 02/11/2015
// Design Name:   cfeb12_5_lat_hdl_sim_top
// Module Name:   C:/Users/bylsma/Projects/CFEB/Firmware/cfeb12_5us_lat_hdl/source/cfeb12_5_lat_hdl_sim.v
// Project Name:  cfeb12_5us_lat_hdl
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: cfeb12_5_lat_hdl_sim_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module cfeb12_5_lat_hdl_sim;

	// Inputs
	reg TDI;
	reg TMS;
	reg TCK;
	reg LCT;
	reg GTRG;
	reg CMSCLK;
	reg CMPCLK;
	reg GLOBAL_RST;
	reg [12:0] ADC1B;
	reg [12:0] ADC2B;
	reg [12:0] ADC3B;
	reg [12:0] ADC4B;
	reg [12:0] ADC5B;
	reg [12:0] ADC6B;
	wire [6:1] AMPOUT;
	wire CMPFDBK;

	// Outputs
	wire TDO;
	wire RDENA_B;
	wire MOVLAP;
	wire DATAAVAIL;
	wire [3:0] CHADR;
	wire [6:0] RADR;
	wire [6:0] WADR;
	wire LPUSH_B;
	wire ENDWORD;
	wire SCAWRITE;
	wire ADC150NS;
	wire CMPRST;
	wire [15:0] OUT;
	wire OVERLAP;
	wire CMPMUX;
	wire DACCLK;
	wire DACDAT;
	wire DAC_ENB_B;
	wire [1:0] CMODE;
	wire [2:0] CTIME;
	wire [6:1] AMPIN;
	wire [6:1] AMPCLK;
	wire [7:0] LEDS;

	// Bidirs
	wire DMYSHIFT;

	// Instantiate the Unit Under Test (UUT)
	cfeb12_5_lat_hdl_sim_top #(
		.TMR(1'b0)
	) uut (
		.TDI(TDI), 
		.TMS(TMS), 
		.TCK(TCK), 
		.LCT(LCT), 
		.GTRG(GTRG), 
		.CMSCLK(CMSCLK), 
		.CMPCLK(CMPCLK), 
		.GLOBAL_RST(GLOBAL_RST), 
		.ADC1B(ADC1B), 
		.ADC2B(ADC2B), 
		.ADC3B(ADC3B), 
		.ADC4B(ADC4B), 
		.ADC5B(ADC5B), 
		.ADC6B(ADC6B), 
		.AMPOUT(AMPOUT), 
		.CMPFDBK(CMPFDBK), 
		.DMYSHIFT(DMYSHIFT), 
		.TDO(TDO), 
		.RDENA_B(RDENA_B), 
		.MOVLAP(MOVLAP), 
		.DATAAVAIL(DATAAVAIL), 
		.CHADR(CHADR), 
		.RADR(RADR), 
		.WADR(WADR), 
		.LPUSH_B(LPUSH_B), 
		.ENDWORD(ENDWORD), 
		.SCAWRITE(SCAWRITE), 
		.ADC150NS(ADC150NS), 
		.CMPRST(CMPRST), 
		.OUT(OUT), 
		.OVERLAP(OVERLAP), 
		.CMPMUX(CMPMUX), 
		.DACCLK(DACCLK), 
		.DACDAT(DACDAT), 
		.DAC_ENB_B(DAC_ENB_B), 
		.CMODE(CMODE), 
		.CTIME(CTIME), 
		.AMPIN(AMPIN), 
		.AMPCLK(AMPCLK), 
		.LEDS(LEDS)
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
	reg [7:0] ch;

	assign CMPFDBK = CMPMUX;

	initial begin
		// Initialize Inputs
      CMSCLK = 1'b0;
      forever
         #(PERIOD/2) CMSCLK = ~CMSCLK;
	end
	
	initial begin
		// Initialize Inputs
      CMPCLK = 1'b0;
		#13;
      forever
         #(PERIOD/2) CMPCLK = ~CMPCLK;
	end


	initial begin
		// Initialize Inputs
		TDI = 0;
		TMS = 0;
		TCK = 0;
		LCT = 0;
		GTRG = 0;
		GLOBAL_RST = 1;
		
		bky1sh = 0;
		bky2sh = 0;
		bky3sh = 0;
		bky4sh = 0;
		bky5sh = 0;
		bky6sh = 0;

      jrst = 8'b00111111;
      sir_hdr = 4'b0011;
      sdr_hdr = 4'b0010;
		trl = 3'b001;
		usr1 = 5'd2; // usr1 instruction
		usr2 = 5'd3; // usr2 instruction
		ch = 0;

		// Wait 100 ns for global reset to finish
		#100;
		#(25*PERIOD);
		GLOBAL_RST = 0;
		#(50*PERIOD);
		GLOBAL_RST = 1;
		#(20*PERIOD);
		GLOBAL_RST = 0;
		#(50*PERIOD);

		// Add stimulus here
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
		Shift_Data(2,2'b01);       // xl1a data
		
		#(4*PERIOD);
		
		Set_Func(8'h08);           // Pre block end
		Set_User(usr2);            // User 2 for User Reg access
		Shift_Data(4,4'b0011);       // preblock data
		
		#(4*PERIOD);
		
//      LCT = 1;
//		#(1*PERIOD);
//      LCT = 0;
//		#(500*PERIOD);
//      GTRG = 1;
//		#(1*PERIOD);
//      GTRG = 0;
//		#(50*PERIOD);
		#(3*PERIOD);
      LCT = 1;
      #(1*PERIOD);
      LCT = 0;
      #(499*PERIOD);
      GTRG = 1;
      #(1*PERIOD);
      GTRG = 0;
      #(236*PERIOD);
//      LCT = 1;
//      #(1*PERIOD);
//      LCT = 0;
//      #(416*PERIOD);
//      LCT = 1;
//      #(1*PERIOD);
//      LCT = 0;
//      #(82*PERIOD);
//      GTRG = 1;
//      #(1*PERIOD);
//      GTRG = 0;
//      #(385*PERIOD);
//      LCT = 1;
//      #(1*PERIOD);
//      LCT = 0;
//      #(30*PERIOD);
//      GTRG = 1;
//      #(1*PERIOD);
//      GTRG = 0;
//      #(468*PERIOD);
//      GTRG = 1;
//      #(1*PERIOD);
//      GTRG = 0;
//      #(155*PERIOD);
//      LCT = 1;
//      #(1*PERIOD);
//      LCT = 0;
//		
//      #(9*PERIOD);
//      LCT = 1;
//      #(1*PERIOD);
//      LCT = 0;
//		
//      #(114*PERIOD);
//      #(1*PERIOD);
//      #(61*PERIOD);
//      LCT = 1;
//      #(1*PERIOD);
//      LCT = 0;
//		
//      #(312*PERIOD);
//      GTRG = 1;
//      #(1*PERIOD);
//      GTRG = 0;
//      #(9*PERIOD);
//      GTRG = 1;
//      #(1*PERIOD);
//      GTRG = 0;
//		
//      #(6*PERIOD);
//      LCT = 1;
//      #(1*PERIOD);
//      LCT = 0;
//      #(169*PERIOD);
//      GTRG = 1;
//      #(1*PERIOD);
//      GTRG = 0;
//      #(329*PERIOD);
//      GTRG = 1;
//      #(1*PERIOD);
//      GTRG = 0;
		

	end
	
	always @(posedge ADC150NS) begin
		ADC1B <= {5'd1,ch};
		ADC2B <= {5'd2,ch};
		ADC3B <= {5'd3,ch};
		ADC4B <= {5'd4,ch};
		ADC5B <= {5'd5,ch};
		ADC6B <= {5'd6,ch};
		ch    <= ch+1;
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
