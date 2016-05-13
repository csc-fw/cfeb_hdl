`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:15:01 01/27/2015
// Design Name:   blkcpld
// Module Name:   C:/Users/bylsma/Projects/CFEB/Firmware/cfeb12_5us_lat_hdl/source/blkcpld/blkcpld_sim.v
// Project Name:  cfeb12_5us_lat_hdl
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: blkcpld
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module blkcpld_sim;

	// Inputs
	reg CLKIN;
	reg CMPCLKIN;
	wire CMPFDBKIN;
	reg RST;
	reg sync_rst;
	reg PUSH;
	reg LASTWORD;
	reg XLOAD;
	wire SENDCHECK;

	// Outputs
	wire LOCKRST;
	wire CLK;
	wire CMPMUXOUT;
	wire EN50;
	wire DIS50;
	wire SCAM150;
	wire [6:1] OEN_B;
	wire LPUSH_B;
	wire END;
	wire SCAWRITE;
	wire ADCCLK;
	
	wire pre_chk;
	wire tr_push;
	wire dly6_push;
	reg [5:0] sr_push;
	reg [2:0] sr_chk;

	// Instantiate the Unit Under Test (UUT)
	blkcpld #(.SIM(1))
	uut (
		.CLKIN(CLKIN), 
		.CMPCLKIN(CMPCLKIN), 
		.CMPFDBKIN(CMPFDBKIN), 
		.RST(sync_rst), 
		.PUSH(PUSH), 
		.LASTWORD(LASTWORD), 
		.XLOAD(XLOAD), 
		.SENDCHECK(SENDCHECK), 
		.LOCKRST(LOCKRST), 
		.CLK(CLK), 
		.CMPMUXOUT(CMPMUXOUT), 
		.EN50(EN50), 
		.DIS50(DIS50), 
		.SCAM150(SCAM150), 
		.OEN_B(OEN_B), 
		.LPUSH_B(LPUSH_B), 
		.END(END), 
		.SCAWRITE(SCAWRITE), 
		.ADCCLK(ADCCLK)
	);

   parameter PERIOD = 24;  // CMS clock period (40MHz)

	initial begin  // CMS clock 40 MHz
		CLKIN = 1;  // start high
      forever begin
         #(PERIOD/2) begin
				CLKIN = ~CLKIN;  //Toggle
			end
		end
	end
	initial begin  // CMS clock 40 MHz
		CMPCLKIN = 1;  // start high
		# 7; //offset
      forever begin
         #(PERIOD/2) begin
				CMPCLKIN = ~CMPCLKIN;  //Toggle
			end
		end
	end
	
	assign pre_chk = PUSH & ! XLOAD;
	assign dly6_push = sr_push[5];
	assign tr_push = !PUSH & dly6_push;
	assign SENDCHECK = sr_chk[2];
	
	always @(posedge CLKIN) begin
		sr_push <= {sr_push[4:0],pre_chk};
		sr_chk <= {sr_chk[1:0],tr_push};
	end
	always @(posedge CLK) begin
		sync_rst <= RST;
	end

	assign CMPFDBKIN = CMPMUXOUT;
	initial begin
		// Initialize Inputs
		RST = 1;
		PUSH = 0;
		LASTWORD = 0;
		XLOAD = 0;

		// Wait 100 ns for global reset to finish
		#100;
		#(25*PERIOD);
		RST = 0;
		#(50*PERIOD);
		RST = 1;
		#(6*PERIOD);
		RST = 0;
		#(50*PERIOD);
		// Add stimulus here
		PUSH = 1;
		#(96*PERIOD);
		PUSH = 0;
		#(6*PERIOD);
		PUSH = 1;
		#(96*PERIOD);
		PUSH = 0;
		#(6*PERIOD);
		PUSH = 1;
		#(96*PERIOD);
		PUSH = 0;
		#(6*PERIOD);
		PUSH = 1;
		#(96*PERIOD);
		PUSH = 0;
		LASTWORD = 1;
		#(6*PERIOD);
		LASTWORD = 0;
		#(6*PERIOD);
		#(6*PERIOD);
		PUSH = 1;
		XLOAD = 1;
		#(18*PERIOD);
		PUSH = 0;
		XLOAD = 0;
		#(6*PERIOD);
		#(6*PERIOD);
		PUSH = 1;
		XLOAD = 1;
		#(48*PERIOD);
		PUSH = 0;
		XLOAD = 0;
		#(6*PERIOD);
	end
      
endmodule

