`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:38:04 02/05/2015 
// Design Name: 
// Module Name:    fifo1 
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
module fifo1 #(
	parameter TMR = 0
)(
	input CLK,
	input RST,
	input LCT,
	input POP,
	input PUSH,
	input ENBL50,
	input DISBL50,
	input PREBLKEND,
	input [3:0] LOADPBLK,
	input [11:0] DIN,
	input [2:0] DSCAFULL,

	output [3:0] DOUT,
	output [7:0] NLCT,
	output LCT_PHASE,
	output FULL_1,
	output EMPT_B,
	output reg FULL,
	output DLSCAFULL
);

wire [8:0] wa;
wire [8:0] ra;

wire ce_wr;
wire ce_rd;
reg empty;
reg last;
reg  lclkstat;
reg  lclkstat_1;
wire phlct;
wire lctphdly;
reg  lct_phase_in;

assign wa[8] = 1'b0;
assign ra[8] = 1'b0;
assign ce_wr = PUSH & !FULL;
assign ce_rd = POP & !empty;
assign lctphdly = LOADPBLK[3] ? phlct : lclkstat_1;
assign EMPT_B = !empty;
assign FULL_1 = !ce_rd & (FULL | (ce_wr & last));

cbnce #(.Width(8),.TMR(TMR)) write_addr_i (.CLK(CLK),.RST(RST),.CE(ce_wr),.Q(wa[7:0]));

cbnce #(.Width(8),.TMR(TMR))  read_addr_i (.CLK(CLK),.RST(RST),.CE(ce_rd),.Q(ra[7:0]));

always @(posedge CLK) begin
	if(LCT)
		lclkstat_1 <= ENBL50;
end

srl_16dx1 lct_phase_pblk_delay_i (.CLK(CLK),.CE(1'b1),.A({1'b0,LOADPBLK[2:0]}),.I(lclkstat_1),.O(phlct));

always @(posedge CLK) begin
	lclkstat <= lctphdly;
end
always @(posedge CLK) begin
	if(PREBLKEND)
		lct_phase_in <= lclkstat;
end

udl_cnt #(.Width(8),.TMR(TMR)) fifo1_counter_i(.CLK(CLK),.RST(RST),.CE(ce_wr ^ ce_rd),.L(1'b0),.UP(ce_wr),.D(8'h00),.Q(NLCT));

always @(posedge CLK or posedge RST) begin
	if(RST) begin
		empty <= 1'b1;
		FULL  <= 1'b0;
		last  <= 1'b0;
	end
	else begin
		empty <= !ce_wr & (empty | (ce_rd & (NLCT == 8'h01)));
		FULL  <= FULL_1;
		last  <= (last & !ce_rd & ! ce_wr) | (ce_wr & (NLCT == 8'hFE)) | (last & ce_rd & !(NLCT == 8'hFE));
	end
end
  
generate
if(TMR==1) 
begin : fifo1_TMR

	wire dmy0;
	wire dmy1;
	(* syn_keep = "true" *) wire [7:0] dmydata_a;
	(* syn_keep = "true" *) wire [7:0] dmydata_b;
	(* syn_keep = "true" *) wire [7:0] dmydata_c;

	(* syn_keep = "true" *) wire [7:0] datain_a;
	(* syn_keep = "true" *) wire [7:0] datain_b;
	(* syn_keep = "true" *) wire [7:0] datain_c;

	(* syn_keep = "true" *) wire [7:0] dataout_a;
	(* syn_keep = "true" *) wire [7:0] dataout_b;
	(* syn_keep = "true" *) wire [7:0] dataout_c;


	assign datain_a = {1'b0,1'b0,lct_phase_in,DSCAFULL[0],DIN[3:0]};
	assign datain_b = {1'b0,1'b0,lct_phase_in,DSCAFULL[1],DIN[7:4]};
	assign datain_c = {1'b0,1'b0,lct_phase_in,DSCAFULL[2],DIN[11:8]};

   RAMB4_S8_S8 #(
      .SIM_COLLISION_CHECK("ALL"), // "NONE", "WARNING_ONLY", "GENERATE_X_ONLY", "ALL" 
      // The following INIT_xx declarations specify the initial contents of the RAM
      .INIT_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_08(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_09(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0F(256'h0000000000000000000000000000000000000000000000000000000000000000)
   ) FIFO1_inst_A (
      .DOA(dmydata_a),     // Port A 8-bit data output
      .DOB(dataout_a),     // Port B 8-bit data output
      .ADDRA(wa), // Port A 9-bit address input
      .ADDRB(ra), // Port B 9-bit address input
      .CLKA(CLK),   // Port A clock input
      .CLKB(CLK),   // Port B clock input
      .DIA(datain_a),     // Port A 8-bit data input
      .DIB(datain_a),     // Port B 8-bit data input
      .ENA(1'b1),     // Port A RAM enable input
      .ENB(1'b1),     // Port B RAM enable input
      .RSTA(1'b0),   // Port A Synchronous reset input
      .RSTB(1'b0),   // Port B Synchronous reset input
      .WEA(ce_wr),     // Port A RAM write enable input
      .WEB(1'b0)      // Port B RAM write enable input
   );


   RAMB4_S8_S8 #(
      .SIM_COLLISION_CHECK("ALL"), // "NONE", "WARNING_ONLY", "GENERATE_X_ONLY", "ALL" 
      // The following INIT_xx declarations specify the initial contents of the RAM
      .INIT_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_08(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_09(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0F(256'h0000000000000000000000000000000000000000000000000000000000000000)
   ) FIFO1_inst_B (
      .DOA(dmydata_b),     // Port A 8-bit data output
      .DOB(dataout_b),     // Port B 8-bit data output
      .ADDRA(wa), // Port A 9-bit address input
      .ADDRB(ra), // Port B 9-bit address input
      .CLKA(CLK),   // Port A clock input
      .CLKB(CLK),   // Port B clock input
      .DIA(datain_b),     // Port A 8-bit data input
      .DIB(datain_b),     // Port B 8-bit data input
      .ENA(1'b1),     // Port A RAM enable input
      .ENB(1'b1),     // Port B RAM enable input
      .RSTA(1'b0),   // Port A Synchronous reset input
      .RSTB(1'b0),   // Port B Synchronous reset input
      .WEA(ce_wr),     // Port A RAM write enable input
      .WEB(1'b0)      // Port B RAM write enable input
   );


   RAMB4_S8_S8 #(
      .SIM_COLLISION_CHECK("ALL"), // "NONE", "WARNING_ONLY", "GENERATE_X_ONLY", "ALL" 
      // The following INIT_xx declarations specify the initial contents of the RAM
      .INIT_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_08(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_09(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0F(256'h0000000000000000000000000000000000000000000000000000000000000000)
   ) FIFO1_inst_C (
      .DOA(dmydata_c),     // Port A 8-bit data output
      .DOB(dataout_c),     // Port B 8-bit data output
      .ADDRA(wa), // Port A 9-bit address input
      .ADDRB(ra), // Port B 9-bit address input
      .CLKA(CLK),   // Port A clock input
      .CLKB(CLK),   // Port B clock input
      .DIA(datain_c),     // Port A 8-bit data input
      .DIB(datain_c),     // Port B 8-bit data input
      .ENA(1'b1),     // Port A RAM enable input
      .ENB(1'b1),     // Port B RAM enable input
      .RSTA(1'b0),   // Port A Synchronous reset input
      .RSTB(1'b0),   // Port B Synchronous reset input
      .WEA(ce_wr),     // Port A RAM write enable input
      .WEB(1'b0)      // Port B RAM write enable input
   );

	vote #(.Width(8)) vote_fifo1 (.A(dataout_a), .B(dataout_b), .C(dataout_c), .V({dmy1,dmy0,LCT_PHASE,DLSCAFULL,DOUT}));

end
else 
begin : fifo1_noTMR

	wire [7:0] dmydata;
	wire [7:0] datain;
	wire [7:0] dataout;


	assign datain = {1'b0,1'b0,lct_phase_in,DSCAFULL[0],DIN[3:0]};

   RAMB4_S8_S8 #(
      .SIM_COLLISION_CHECK("ALL"), // "NONE", "WARNING_ONLY", "GENERATE_X_ONLY", "ALL" 
      // The following INIT_xx declarations specify the initial contents of the RAM
      .INIT_00(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_01(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_02(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_03(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_04(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_05(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_06(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_07(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_08(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_09(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0A(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0B(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0C(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0D(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0E(256'h0000000000000000000000000000000000000000000000000000000000000000),
      .INIT_0F(256'h0000000000000000000000000000000000000000000000000000000000000000)
   ) FIFO1_inst (
      .DOA(dmydata),     // Port A 8-bit data output
      .DOB(dataout),     // Port B 8-bit data output
      .ADDRA(wa), // Port A 9-bit address input
      .ADDRB(ra), // Port B 9-bit address input
      .CLKA(CLK),   // Port A clock input
      .CLKB(CLK),   // Port B clock input
      .DIA(datain),     // Port A 8-bit data input
      .DIB(datain),     // Port B 8-bit data input
      .ENA(1'b1),     // Port A RAM enable input
      .ENB(1'b1),     // Port B RAM enable input
      .RSTA(1'b0),   // Port A Synchronous reset input
      .RSTB(1'b0),   // Port B Synchronous reset input
      .WEA(ce_wr),     // Port A RAM write enable input
      .WEB(1'b0)      // Port B RAM write enable input
   );

	assign LCT_PHASE = dataout[5];
	assign DLSCAFULL = dataout[4];
	assign DOUT      = dataout[3:0];

end
endgenerate

endmodule
