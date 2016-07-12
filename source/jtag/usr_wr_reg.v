`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: The Ohio State University
// Engineer: Ben Bylsma
// 
// Create Date:    2/2/2015 
// Design Name:    JTAG
// Module Name:    usr_wr_reg 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
//   Serial in parallel out (sipo) shift register with parameterized width and default value.
//   Can be used in two modes: 1) as an individual shift register using FSEL, TDI, and TDO or
//                             2) daisy chained with other instances to form a long shift register
//                                with a common update (useing DSY_CHAIN, DSY_IN, and DSY_OUT)
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module user_wr_reg #(
  parameter width = 8,
  parameter def_value = 8'h00,
  parameter TMR = 0
  )(
  input CLK25,
  input DRCK,        // Data Reg Clock
  input FSEL,        // Function select
  input SEL,         // User mode active
  input TDI,         // Serial Test Data In
  input DSY_IN,      // Serial Daisy chained data in
  input SHIFT,       // Shift state
  input UPDATE,      // Update state
  input RST,         // Reset default state
  input DSY_CHAIN,   // Daisy chain mode
  output [width-1:0]  PO,         // Parallel output
  output TDO,        // Serial Test Data Out
  output DSY_OUT);   // Daisy chained serial data out
  

  reg[width-1:0] d;
  wire din,ce;
  wire sel_update;
  reg dly_update;
  
  initial d = def_value;
  
  assign TDO     = FSEL & d[0];
  assign DSY_OUT = DSY_CHAIN & d[0];
  assign din     = DSY_CHAIN ? DSY_IN : TDI;
  assign ce      = SHIFT & SEL & (FSEL | DSY_CHAIN);
  assign sel_update      = UPDATE & !dly_update & SEL & (FSEL | DSY_CHAIN);
  
	always @(posedge CLK25) begin
		dly_update <= UPDATE;
	end
  always @(posedge DRCK or posedge RST) begin // intermediate shift register
    if(RST)
	   d <= def_value;           // default
    else
	   if(ce)
	     d <= {din,d[width-1:1]}; // Shift right
		else
		  d <= d;                  // Hold
  end
  
generate
if(TMR==1) 
begin : usr_wr_reg_TMR
  (* syn_preserve = "true" *) reg [width-1:0] par_out_1;
  (* syn_preserve = "true" *) reg [width-1:0] par_out_2;
  (* syn_preserve = "true" *) reg [width-1:0] par_out_3;
  
  (* syn_keep = "true" *) wire [width-1:0] voted_par_out_1;
  
initial
begin
	par_out_1 = def_value;
	par_out_2 = def_value;
	par_out_3 = def_value;
end

  vote #(.Width(width)) vote_parout_1 (.A(par_out_1), .B(par_out_2), .C(par_out_3), .V(voted_par_out_1));
  
  always @(posedge CLK25 or posedge RST) begin  // Parallel output register
    if(RST) begin
	   par_out_1 <= def_value;
	   par_out_2 <= def_value;
	   par_out_3 <= def_value;
	 end
	 else
	   if(sel_update) begin
        par_out_1 <= d;
        par_out_2 <= d;
        par_out_3 <= d;
		end
		else begin
		  par_out_1 <= voted_par_out_1;
		  par_out_2 <= voted_par_out_1;
		  par_out_3 <= voted_par_out_1;
		end
  end

  assign PO = voted_par_out_1;
end
else 
begin : usr_wr_reg_notmr
  reg [width-1:0] par_out;

initial par_out = def_value;
  
  always @(posedge CLK25 or posedge RST) begin  // Parallel output register
    if(RST)
	   par_out <= def_value;
	 else
	   if(sel_update)
        par_out <= d;
		else
		  par_out <= par_out;
  end

  assign PO = par_out;
end
endgenerate

endmodule
