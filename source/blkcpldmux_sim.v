`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   13:15:01 01/27/2015
// Design Name:   blkcpld
// Module Name:   C:/Users/bylsma/Projects/CFEB/Firmware/cfeb12_5us_lat_hdl/source/blkcpld/blkcpldmux_sim.v
// Project Name:  cfeb12_5us_lat_hdl
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: blkcpldmux
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module blkcpldmux_sim;

	// regs
	reg clkin;
	reg cmpclkin;
	wire cmpfdbkin;
	reg grst;
	reg push;
	reg lastword;
	reg dataload;
	wire crccheck;
	reg ovlpint;
	reg [15:0] data;
	reg [12:0] adc1b;
	reg [12:0] adc2b;
	reg [12:0] adc3b;
	reg [12:0] adc4b;
	reg [12:0] adc5b;
	reg [12:0] adc6b;
	reg [5:0] l1anout;
	reg [23:0] status;

	// Outputs
	wire lockrst;
	wire clk25ns;
	wire cmpmuxout;
	wire en50;
	wire dis50;
	wire scam150;
	wire [6:1] adcen_b;
	wire lpush_b;
	wire endword;
	wire scawrite;
	wire adc150ns;
	wire overlap;
	wire [15:0] out;
	
	reg sync_rst;
	wire pre_chk;
	wire tr_push;
	wire dly6_push;
	reg [5:0] sr_push;
	reg [2:0] sr_chk;
	wire oecrcmux;
	reg [7:0] ch;

	// Instantiate the Unit Under Test (UUT)
	blkcpld #(.SIM(1))
	uut1 (
		.CLKIN(clkin), 
		.CMPCLKIN(cmpclkin), 
		.CMPFDBKIN(cmpfdbkin), 
		.RST(sync_rst), 
		.PUSH(push), 
		.LASTWORD(lastword), 
		.XLOAD(dataload), 
		.SENDCHECK(crccheck), 
		.LOCKRST(lockrst), 
		.CLK(clk25ns), 
		.CMPMUXOUT(cmpmuxout), 
		.EN50(en50), 
		.DIS50(dis50), 
		.SCAM150(scam150), 
		.OEN_B(adcen_b), 
		.LPUSH_B(lpush_b), 
		.END(endword), 
		.SCAWRITE(scawrite), 
		.ADCCLK(adc150ns)
	);
	
	blkmux #(.SIM(1))
	uut2 (
	.CLK25(clk25ns),
	.CLK150(scam150),
	.RST(sync_rst),
	.START(push),
	.OECRC(oecrcmux),
	.DLOAD(dataload),
	.OVLPINT(ovlpint),
	.DATA(data),
	.OE_B(adcen_b),
	.K1ADC(adc1b),
	.K2ADC(adc2b),
	.K3ADC(adc3b),
	.K4ADC(adc4b),
	.K5ADC(adc5b),
	.K6ADC(adc6b),
	.L1ANOUT(l1anout),
	.STATUS(status),
	
	.OVERLAP(overlap),
	.OUT(out)
	);

   parameter PERIOD = 24;  // CMS clock period (40MHz)

	initial begin  // CMS clock 40 MHz
		clkin = 1;  // start high
      forever begin
         #(PERIOD/2) begin
				clkin = ~clkin;  //Toggle
			end
		end
	end
	initial begin  // CMS clock 40 MHz
		cmpclkin = 1;  // start high
		# 7; //offset
      forever begin
         #(PERIOD/2) begin
				cmpclkin = ~cmpclkin;  //Toggle
			end
		end
	end
	

	always @(posedge adc150ns) begin
		adc1b <= {5'd1,ch};
		adc2b <= {5'd2,ch};
		adc3b <= {5'd3,ch};
		adc4b <= {5'd4,ch};
		adc5b <= {5'd5,ch};
		adc6b <= {5'd6,ch};
		ch    <= ch+1;
	end
	
	assign pre_chk = push & ! dataload;
	assign dly6_push = sr_push[5];
	assign tr_push = !push & dly6_push;
	assign crccheck = sr_chk[2];
	assign oecrcmux = tr_push;
	
	always @(posedge clk25ns) begin
		sync_rst <= grst;
	end
	always @(posedge clkin) begin
		sr_push <= {sr_push[4:0],pre_chk};
		sr_chk <= {sr_chk[1:0],tr_push};
	end

	assign cmpfdbkin = cmpmuxout;
	initial begin
		// Initialize regs
		grst = 1;
		push = 0;
		lastword = 0;
		dataload = 0;
		ovlpint = 0;
		ch = 13'h0000;
		l1anout = 6'h15;
		data = 16'h7fff;
		status = 24'hdead56;

		// Wait 100 ns for global reset to finish
		#100;
		#(25*PERIOD);
		grst = 0;
		#(50*PERIOD);
		grst = 1;
		#(6*PERIOD);
		grst = 0;
		#(50*PERIOD);
		// Add stimulus here
		#(3*PERIOD);//get in phase with 150ns clock
		push = 1;
		#(96*PERIOD);
		push = 0;
		#(6*PERIOD);
		push = 1;
		#(96*PERIOD);
		push = 0;
		#(6*PERIOD);
		push = 1;
		#(96*PERIOD);
		push = 0;
		#(6*PERIOD);
		push = 1;
		#(96*PERIOD);
		push = 0;
		lastword = 1;
		#(6*PERIOD);
		lastword = 0;
		#(6*PERIOD);
		#(6*PERIOD);
		push = 1;
		dataload = 1;
		#(18*PERIOD);
		push = 0;
		dataload = 0;
		#(6*PERIOD);
		#(6*PERIOD);
		push = 1;
		dataload = 1;
		#(48*PERIOD);
		push = 0;
		dataload = 0;
		#(6*PERIOD);
	end
      
endmodule

