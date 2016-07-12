`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   12:41:09 05/20/2016
// Design Name:   cfeb_hdl
// Module Name:   C:/Users/bylsma/Projects/CFEB/Firmware/ISE_14.7/cfeb_hdl/cfeb_hdl_sim_tf.v
// Project Name:  cfeb_hdl
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: cfeb_hdl
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module cfeb_hdl_sim_tf_tmr;

	// Inputs
	reg [2:0] ENC_TRG;
	reg CMSCLK;
	reg CMPCLK;
	reg [12:0] ADC1B;
	reg [12:0] ADC2B;
	reg [12:0] ADC3B;
	reg [12:0] ADC4B;
	reg [12:0] ADC5B;
	reg [12:0] ADC6B;
	wire [6:1] AMPOUT;
	wire CMPFDBK;

	// Outputs
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
	cfeb_hdl #(
		.TMR(1),
		.SIM(1)
	) uut (
		.ENC_TRG(ENC_TRG), 
		.CMSCLK(CMSCLK), 
		.CMPCLK(CMPCLK), 
		.ADC1B(ADC1B), 
		.ADC2B(ADC2B), 
		.ADC3B(ADC3B), 
		.ADC4B(ADC4B), 
		.ADC5B(ADC5B), 
		.ADC6B(ADC6B), 
		.AMPOUT(AMPOUT), 
		.CMPFDBK(CMPFDBK), 
		.DMYSHIFT(DMYSHIFT), 
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

   parameter PERIOD = 24;  // CMS clock period (40MHz)
	parameter JPERIOD = 100;
	parameter ir_width = 10;
	parameter max_width = 300;
	
//JTAG
	reg TMS,TDI,TCK;
	reg [7:0] jrst;
	reg [3:0] sir_hdr;
	reg [3:0] sdr_hdr;
	reg [2:0] trl;
	reg [ir_width-1:0] usr1;
	reg [ir_width-1:0] usr2;

//Trigger
	reg resync;
	reg l1a;
	reg l1a_match;
	reg lct;
	reg encode;
	reg bx3;
	reg lat125;
	
   reg [47:0] bky1sh,bky2sh,bky3sh,bky4sh,bky5sh,bky6sh;

   integer i;
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
		resync    = 0;
		l1a       = 0;
		l1a_match = 0;
		lct       = 0;
		encode    = 0;
		bx3       = 0;
		lat125    = 0;

		TMS = 1'b1;
		TDI = 1'b0;
		TCK = 1'b0;
      jrst = 8'b00111111;
      sir_hdr = 4'b0011;
      sdr_hdr = 4'b0010;
		trl = 3'b001;
		usr1 = 10'h3c2; // usr1 instruction
		usr2 = 10'h3c3; // usr2 instruction
		
		bky1sh = 0;
		bky2sh = 0;
		bky3sh = 0;
		bky4sh = 0;
		bky5sh = 0;
		bky6sh = 0;

		ch = 0;

		// Wait 100 ns for global reset to finish
		#100;
		#(25*PERIOD);
		resync = 0;
		#(50*PERIOD);
		resync = 1;
		#(20*PERIOD);
		resync = 0;
		#(50*PERIOD);

		encode    = 1;
		bx3       = 0;
		lat125    = 0;

		// Add stimulus here
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
		
		Set_Func(8'h06);           // CFEB Config end
		Set_User(usr2);            // User 2 for User Reg access
		Shift_Data(4,{1'b0,encode,bx3,lat125});       // config data
		
		#(4*PERIOD);
		
//      lct = 1;
//		#(1*PERIOD);
//      lct = 0;
//		#(500*PERIOD);
//      l1a = 1;
//		#(1*PERIOD);
//      l1a = 0;
//		#(50*PERIOD);
		#(3*PERIOD);
      lct = 1;
      #(1*PERIOD);
      lct = 0;
//      #(499*PERIOD); // for 12.5us latency
      #(132*PERIOD); // for 3.2us latency
      l1a = 1;
		l1a_match = 1;
      #(1*PERIOD);
      l1a = 0;
		l1a_match = 0;
      #(236*PERIOD);
      #(1250*PERIOD);
		
      lct = 1;
      l1a = 0;
		l1a_match = 0;
		resync = 0;
      #(1*PERIOD);
      lct = 0;
      l1a = 0;
		l1a_match = 0;
		resync = 0;
      #(5*PERIOD);
		
      lct = 0;
      l1a = 1;
		l1a_match = 0;
		resync = 0;
      #(1*PERIOD);
      lct = 0;
      l1a = 0;
		l1a_match = 0;
		resync = 0;
      #(5*PERIOD);
		
      lct = 0;
      l1a = 1;
		l1a_match = 1;
		resync = 0;
      #(1*PERIOD);
      lct = 0;
      l1a = 0;
		l1a_match = 0;
		resync = 0;
      #(5*PERIOD);
		
      lct = 1;
      l1a = 1;
		l1a_match = 0;
		resync = 0;
      #(1*PERIOD);
      lct = 0;
      l1a = 0;
		l1a_match = 0;
		resync = 0;
      #(5*PERIOD);
		
      lct = 1;
      l1a = 1;
		l1a_match = 1;
		resync = 0;
      #(1*PERIOD);
      lct = 0;
      l1a = 0;
		l1a_match = 0;
		resync = 0;
      #(5*PERIOD);
		
      lct = 0;
      l1a = 0;
		l1a_match = 0;
		resync = 1;
      #(25*PERIOD);
      lct = 0;
      l1a = 0;
		l1a_match = 0;
		resync = 0;
      #(5*PERIOD);
		
      lct = 1;
      l1a = 1;
		l1a_match = 1;
		resync = 1;
      #(25*PERIOD);
      lct = 0;
      l1a = 0;
		l1a_match = 0;
		resync = 0;
      #(5*PERIOD);
		
//      lct = 1;
//      #(1*PERIOD);
//      lct = 0;
//      #(416*PERIOD);
//      lct = 1;
//      #(1*PERIOD);
//      lct = 0;
//      #(82*PERIOD);
//      l1a = 1;
//      #(1*PERIOD);
//      l1a = 0;
//      #(385*PERIOD);
//      lct = 1;
//      #(1*PERIOD);
//      lct = 0;
//      #(30*PERIOD);
//      l1a = 1;
//      #(1*PERIOD);
//      l1a = 0;
//      #(468*PERIOD);
//      l1a = 1;
//      #(1*PERIOD);
//      l1a = 0;
//      #(155*PERIOD);
//      lct = 1;
//      #(1*PERIOD);
//      lct = 0;
//		
//      #(9*PERIOD);
//      lct = 1;
//      #(1*PERIOD);
//      lct = 0;
//		
//      #(114*PERIOD);
//      #(1*PERIOD);
//      #(61*PERIOD);
//      lct = 1;
//      #(1*PERIOD);
//      lct = 0;
//		
//      #(312*PERIOD);
//      l1a = 1;
//      #(1*PERIOD);
//      l1a = 0;
//      #(9*PERIOD);
//      l1a = 1;
//      #(1*PERIOD);
//      l1a = 0;
//		
//      #(6*PERIOD);
//      lct = 1;
//      #(1*PERIOD);
//      lct = 0;
//      #(169*PERIOD);
//      l1a = 1;
//      #(1*PERIOD);
//      l1a = 0;
//      #(329*PERIOD);
//      l1a = 1;
//      #(1*PERIOD);
//      l1a = 0;


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

	always @* begin
		if(encode)
			casex({resync,l1a_match,l1a,lct})
				4'b0000 : ENC_TRG = 3'd0; 
				4'b0001 : ENC_TRG = 3'd1; 
				4'b0011 : ENC_TRG = 3'd2; 
				4'b0111 : ENC_TRG = 3'd3; 
				4'b0010 : ENC_TRG = 3'd4; 
				4'b0110 : ENC_TRG = 3'd5; 
				4'b1xxx : ENC_TRG = 3'd7; 
				default : ENC_TRG = 3'd0;
			endcase
		else	begin
			ENC_TRG[0] = lct;
			ENC_TRG[1] = l1a;
			ENC_TRG[2] = resync;
		end
	end
	
	

   // JTAG_SIM_VIRTEX6: JTAG Interface Simulation Model
   //                   Virtex-6
   // Xilinx HDL Language Template, version 12.4
   
   JTAG_SIM_VIRTEX6 #(
      .PART_NAME("LX130T") // Specify target V6 device.  Possible values are:
                          // "CX130T","CX195T","CX240T","CX75T","HX250T","HX255T","HX380T","HX45T","HX565T",
                          // "LX115T","LX130T","LX130TL","LX195T","LX195TL","LX240T","LX240TL","LX365T","LX365TL",
                          // "LX40T","LX550T","LX550TL","LX75T","LX760","SX315T","SX475T" 
   ) JTAG_SIM_VIRTEX6_inst (
      .TDO(TDO), // 1-bit JTAG data output
      .TCK(TCK), // 1-bit Clock input
      .TDI(TDI), // 1-bit JTAG data input
      .TMS(TMS)  // 1-bit JTAG command input
   );
	
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

