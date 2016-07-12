`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:10:02 01/05/2015 
// Design Name: 
// Module Name:    blkcpld 
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
 
module blkcpld #(
	parameter TMR = 0
)(
	input CLKIN,
	input CMPCLKIN,
	input CMPFDBKIN,
	input RST,
	input PUSH,
	input LASTWORD,
	input XLOAD,
	input SENDCHECK,
	output LOCKRST,
	output CLK,
	output CMPMUXOUT,
	output reg EN50,
	output reg DIS50,
	output SCAM150,
	output [6:1] OEN_B,
	output reg LPUSH_B,
	output reg END,
	output SCAWRITE,
	output reg ADCCLK
);

wire clkout;
wire clklock;
wire dclklock;
reg lrst;
reg lw;

reg pre50;
reg sync_rst2;
reg sync_rst3;
reg rstclk;
reg rst_1;
wire ld_edg_rst;
wire ld_edg_sync2;

reg load;
reg dlyload;
wire xl_clr;

reg dl_en50;

reg pre150clk;
wire dllrst;

(* MAXDELAY = "2ns" *) wire dl_en50_i;
(* MAXDELAY = "1ns" *) wire scawe;

initial begin
	EN50      = 0;
	DIS50     = 0;
	LPUSH_B   = 1'b1;
	END       = 0;
	ADCCLK    = 0;
	lrst      = 0;
	lw        = 0;
	pre50     = 0;
	sync_rst2 = 0;
	sync_rst3 = 0;
	rstclk    = 0;
	rst_1     = 0;
	load      = 0;
	dlyload   = 0;
	dl_en50   = 0;
	pre150clk = 0;
end

assign dllrst = 0;

//
// generate SCAWRITE
//
always @(negedge CLK) dl_en50 <= EN50;

assign dl_en50_i = dl_en50;

assign scawe = EN50 & dl_en50;
assign SCAWRITE = scawe;

//////////// end section ////////////

BUFG scam150_buf (.O(SCAM150), .I(pre150clk));

CLKDLL #(
	.CLKDV_DIVIDE(2.0),     // Divide by: 1.5,2.0,2.5,3.0,4.0,5.0,8.0 or 16.0
	.DUTY_CYCLE_CORRECTION("TRUE"),  // Duty cycle correction, TRUE or FALSE
	.FACTORY_JF(16'hC080),  // FACTORY JF Values
	.STARTUP_WAIT("FALSE")  // Delay config DONE until DLL LOCK, TRUE/FALSE
) CMS_clk_i (
	.CLK0(clkout),      // 0 degree DLL CLK output
	.CLK180(),          // 180 degree DLL CLK output
	.CLK270(),          // 270 degree DLL CLK output
	.CLK2X(),           // 2X DLL CLK output
	.CLK90(),           // 90 degree DLL CLK output
	.CLKDV(),           // Divided DLL CLK out (CLKDV_DIVIDE)
	.LOCKED(clklock),   // DLL LOCK status output
	.CLKFB(CLK),        // DLL clock feedback
	.CLKIN(CLKIN),      // Clock input (from IBUFG, BUFG or DLL)
	.RST(dllrst)              // DLL asynchronous reset input
);

BUFG clk_buf (
	.O(CLK),     // Clock buffer output
	.I(clkout)      // Clock buffer input
);

CLKDLL #(
	.CLKDV_DIVIDE(2.0),     // Divide by: 1.5,2.0,2.5,3.0,4.0,5.0,8.0 or 16.0
	.DUTY_CYCLE_CORRECTION("TRUE"),  // Duty cycle correction, TRUE or FALSE
	.FACTORY_JF(16'hC080),  // FACTORY JF Values
	.STARTUP_WAIT("FALSE")  // Delay config DONE until DLL LOCK, TRUE/FALSE
) Comp_clk_i (
	.CLK0(),            // 0 degree DLL CLK output
	.CLK180(),          // 180 degree DLL CLK output
	.CLK270(),          // 270 degree DLL CLK output
	.CLK2X(CMPMUXOUT),  // 2X DLL CLK output
	.CLK90(),           // 90 degree DLL CLK output
	.CLKDV(),           // Divided DLL CLK out (CLKDV_DIVIDE)
	.LOCKED(),          // DLL LOCK status output
	.CLKFB(CMPFDBKIN),  // DLL clock feedback
	.CLKIN(CMPCLKIN),   // Clock input (from IBUFG, BUFG or DLL)
	.RST(dllrst)              // DLL asynchronous reset input
);

//
// delay lock signal then make 25 ns pulse signaling the lock condition
//

srl_nx1 #(.Depth(16)) lock_delay_i (.CLK(CLK),.CE(1'b1),.I(clklock),.O(dclklock));
	
always @(posedge CLK) begin
	lrst <= dclklock;
end
assign LOCKRST = dclklock & !lrst;
	
//////////// end section ////////////

//
// generate 50ns clock enable signals of each phase to be used with 25ns clock
//
always @(posedge CLK) begin
		rst_1 <= RST;
end
assign ld_edg_rst = RST & !rst_1;

always @(posedge CLK or posedge ld_edg_rst) begin
	if(ld_edg_rst)
		pre50 <= 0;
	else
		pre50 <= !pre50;
end
always @(posedge CLK) begin
	if(EN50) begin
		sync_rst2 <= RST;
		sync_rst3 <= sync_rst2;
	end
	EN50  <=  pre50;
	DIS50 <= !pre50;
end
//////////// end section ////////////

//
// Reset the clock to synchronize the CMSCLK and SCA50ns with CLK150 clock
// (50 ns pulse as leading edge of sync_rst2)
// also used to preset the phase of the ADC output enable signals.
//
assign ld_edg_sync2 = sync_rst2 & !sync_rst3;
always @(posedge CLK) begin
	if(DIS50) rstclk <= ld_edg_sync2;
end
//////////// end section ////////////

//
// generate load signal
//
assign xl_clr = RST | (dlyload & !OEN_B[1]);

always @(posedge CLK or posedge xl_clr) begin
	if(xl_clr)
		load <= 0;
	else
		load <= XLOAD;
end
always @(posedge CLK or posedge RST) begin
	if(RST)
		dlyload <= 0;
	else
		if(!OEN_B[6])dlyload <= load;
end
//////////// end section ////////////

  
generate
if(TMR==1) 
begin : cpld_TMR

	(* syn_preserve = "True" *) reg [6:1] aen_b;
	(* syn_preserve = "True" *) reg [6:1] ben_b;
	(* syn_preserve = "True" *) reg [6:1] cen_b;
	wire vt_fb;

	//
	// Generate output enable signals for ADC's
	//
	always @(posedge CLK or posedge rstclk) begin
		if(rstclk) 
			begin
				aen_b <= 6'b111101;
				ben_b <= 6'b111101;
				cen_b <= 6'b111101;
			end
		else
			begin
				aen_b <= {aen_b[5:1],vt_fb};
				ben_b <= {ben_b[5:1],vt_fb};
				cen_b <= {cen_b[5:1],vt_fb};
			end
	end

	vote #(.Width(1)) vote_oe (.A(aen_b[6]), .B(ben_b[6]), .C(cen_b[6]), .V(vt_fb));

	assign OEN_B = ben_b;

	//////////// end section ////////////


	//
	// generate TMR'd LPUSH_B signal
	//

	(* syn_preserve = "True" *) reg  push_ba;
	(* syn_preserve = "True" *) reg  push_bb;
	(* syn_preserve = "True" *) reg  push_bc;
	(* syn_preserve = "True" *) reg  push_b1a;
	(* syn_preserve = "True" *) reg  push_b1b;
	(* syn_preserve = "True" *) reg  push_b1c;
	(* syn_preserve = "True" *) reg  push_b6a;
	(* syn_preserve = "True" *) reg  push_b6b;
	(* syn_preserve = "True" *) reg  push_b6c;
	(* syn_keep = "True" *) wire ppa;
	(* syn_keep = "True" *) wire ppb;
	(* syn_keep = "True" *) wire ppc;
	wire vt_push_b;

	assign ppa = RST | (dlyload & !aen_b[6]);
	assign ppb = RST | (dlyload & !ben_b[6]);
	assign ppc = RST | (dlyload & !cen_b[6]);

	always @(posedge CLK or posedge RST) begin
		if(RST) 
			push_b6a <= 1;
		else
			if(!aen_b[6]) push_b6a <= !PUSH;
		if(RST) 
			push_b6b <= 1;
		else
			if(!ben_b[6]) push_b6b <= !PUSH;
		if(RST) 
			push_b6c <= 1;
		else
			if(!cen_b[6]) push_b6c <= !PUSH;
	end
	always @(posedge CLK or posedge ppa) begin
		if(ppa) 
			push_b1a <= 1;
		else
			if(!aen_b[1]) push_b1a <= push_b6a;
	end
	always @(posedge CLK or posedge ppb) begin
		if(ppb) 
			push_b1b <= 1;
		else
			if(!ben_b[1]) push_b1b <= push_b6b;
	end
	always @(posedge CLK or posedge ppc) begin
		if(ppc) 
			push_b1c  <= 1;
		else
			if(!cen_b[1]) push_b1c <= push_b6c;
	end
	always @(posedge CLK) begin
		push_ba = push_b1a & (!aen_b[1] | !aen_b[6] | !SENDCHECK);
		push_bb = push_b1b & (!ben_b[1] | !ben_b[6] | !SENDCHECK);
		push_bc = push_b1c & (!cen_b[1] | !cen_b[6] | !SENDCHECK);
	end

	vote #(.Width(1)) vote_push (.A(push_ba), .B(push_bb), .C(push_bc), .V(vt_push_b));

	(* syn_useioff = "True" *)
	always @(posedge CLK or posedge RST) begin
		if(RST)
			LPUSH_B <= 1;
		else
			LPUSH_B <= vt_push_b;
	end
	//////////// end section ////////////

	//
	// generate TMR'd END signal delayed 4 clocks to allow for trailer words
	//

	(* syn_keep = "True" *) wire lwa;
	(* syn_keep = "True" *) wire lwb;
	(* syn_keep = "True" *) wire lwc;
	wire vt_lw;

	always @(posedge CLK or posedge RST) begin
		if(RST)
			lw <= 0;
		else
			if(LASTWORD & !(ben_b[1] & ben_b[6]))
				lw <= !lw;
	end

	(* syn_preserve = "True" *) SRL16 #(.INIT(16'h0000)) srl_lwa (.Q(lwa),.A0(1'b0),.A1(1'b0),.A2(1'b1),.A3(1'b0),.CLK(CLK),.D(lw));
	(* syn_preserve = "True" *) SRL16 #(.INIT(16'h0000)) srl_lwb (.Q(lwb),.A0(1'b0),.A1(1'b0),.A2(1'b1),.A3(1'b0),.CLK(CLK),.D(lw));
	(* syn_preserve = "True" *) SRL16 #(.INIT(16'h0000)) srl_lwc (.Q(lwc),.A0(1'b0),.A1(1'b0),.A2(1'b1),.A3(1'b0),.CLK(CLK),.D(lw));

//	(* syn_preserve = "True" *) 	srl_nx1 #(.Depth(5))	srl_lwa (.CLK(CLK),.CE(1'b1),.I(lw),.O(lwa));
//	(* syn_preserve = "True" *) 	srl_nx1 #(.Depth(5))	srl_lwb (.CLK(CLK),.CE(1'b1),.I(lw),.O(lwb));
//	(* syn_preserve = "True" *) 	srl_nx1 #(.Depth(5))	srl_lwc (.CLK(CLK),.CE(1'b1),.I(lw),.O(lwc));

	vote #(.Width(1)) vote_lw (.A(lwa), .B(lwb), .C(lwc), .V(vt_lw));

	(* syn_useioff = "True" *)
	always @(posedge CLK or posedge RST) begin
		if(RST)
			END <= 0;
		else
			END <= vt_lw;
	end
	//////////// end section ////////////

	//
	// generate and TMR the ADCCLK
	//

	(* syn_preserve = "True" *) reg  c_1a;
	(* syn_preserve = "True" *) reg  c_1b;
	(* syn_preserve = "True" *) reg  c_1c;
	(* syn_preserve = "True" *) reg  c_2a;
	(* syn_preserve = "True" *) reg  c_2b;
	(* syn_preserve = "True" *) reg  c_2c;
	(* syn_preserve = "True" *) reg  c150a;
	(* syn_preserve = "True" *) reg  c150b;
	(* syn_preserve = "True" *) reg  c150c;
	wire vt_c150;

	always @(posedge CLK or posedge rstclk)begin
		if(rstclk)
			begin
				c_2a <= 0;
				c_2b <= 0;
				c_2c <= 0;
				c_1a <= 0;
				c_1b <= 0;
				c_1c <= 0;
				c150a <= 0;
				c150b <= 0;
				c150c <= 0;
				pre150clk <= 0;
			end
		else
			begin
				c_2a <= !vt_c150;
				c_2b <= !vt_c150;
				c_2c <= !vt_c150;
				c_1a <= c_2a;
				c_1b <= c_2b;
				c_1c <= c_2c;
				c150a <= c_1a;
				c150b <= c_1b;
				c150c <= c_1c;
				pre150clk <= c_1c;
			end
	end

	vote #(.Width(1)) vote_clk (.A(c150a), .B(c150b), .C(c150c), .V(vt_c150));

	(* syn_useioff = "True" *)
	always @(negedge CLK) ADCCLK <= c_1c;

	//////////// end section ////////////

end
else 
begin : cpld_noTMR

	reg [6:1] en_b;

	//
	// Generate output enable signals for ADC's
	//
	always @(posedge CLK or posedge rstclk) begin
		if(rstclk) 
			en_b <= 6'b111101;
		else
			en_b <= {en_b[5:1],en_b[6]};
	end

	assign OEN_B = en_b;

	//////////// end section ////////////


	//
	// generate LPUSH_B signal
	//

	reg  push_b;
	reg  push_b1;
	reg  push_b6;
	wire pp;

	assign pp = RST | (dlyload & !en_b[6]);

	always @(posedge CLK or posedge RST) begin
		if(RST) 
			push_b6 <= 1;
		else
			if(!en_b[6]) push_b6 <= !PUSH;
	end
	always @(posedge CLK or posedge pp) begin
		if(pp) 
			push_b1 <= 1;
		else
			if(!en_b[1]) push_b1 <= push_b6;
	end
	always @(posedge CLK) begin
		push_b <= push_b1 & (!en_b[1] | !en_b[6] | !SENDCHECK);
	end

	(* syn_useioff = "True" *)
	always @(posedge CLK or posedge RST) begin
		if(RST)
			LPUSH_B <= 1;
		else
			LPUSH_B <= push_b;
	end
	//////////// end section ////////////

	//
	// generate END signal delayed 4 clocks to allow for trailer words
	//

	wire dlw;

	always @(posedge CLK or posedge RST) begin
		if(RST)
			lw <= 0;
		else
			if(LASTWORD & !(en_b[1] & en_b[6]))
				lw <= !lw;
	end

	srl_nx1 #(.Depth(5))	srl_lw (.CLK(CLK),.CE(1'b1),.I(lw),.O(dlw));

	(* syn_useioff = "True" *)
	always @(posedge CLK or posedge RST) begin
		if(RST)
			END <= 0;
		else
			END <= dlw;
	end
	//////////// end section ////////////

	//
	// generate the ADCCLK
	//

	reg  c_1;
	reg  c_2;
	reg  c150;

	always @(posedge CLK or posedge rstclk)begin
		if(rstclk)
			begin
				c_2 <= 0;
				c_1 <= 0;
				c150 <= 0;
				pre150clk <= 0;
			end
		else
			begin
				c_2 <= !c150;
				c_1 <= c_2;
				c150 <= c_1;
				pre150clk <= c_1;
			end
	end

	(* syn_useioff = "True" *)
	always @(negedge CLK) ADCCLK <= c_1;

	//////////// end section ////////////

end
endgenerate

endmodule
