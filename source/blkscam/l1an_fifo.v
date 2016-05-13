`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:14:50 02/10/2015 
// Design Name: 
// Module Name:    l1an_fifo 
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
module l1an_fifo #(
	parameter TMR = 0
)(
	input CLK,
	input RST,
	input PUSH,
	input POP,
	input L1A_PHASE,
	input [5:0] DL1AN,
	output L1A_PHASE_OUT,
	output reg EMPTY,
	output reg FULL,
	output [5:0] L1ANUM
);

wire ce_wr;
wire ce_rd;
wire [7:0] wa;
wire [7:0] ra;
reg last;
wire [7:0] nl1a;
wire [31:0] datal1a;
wire [31:0] datal1an;
wire [15:0] doa_dmy1;
wire [15:0] doa_dmy2;

assign ce_wr = PUSH & !FULL;
assign ce_rd = POP  & !EMPTY;
assign datal1a = {11'h000,L1A_PHASE,DL1AN,L1A_PHASE,DL1AN,L1A_PHASE,DL1AN};

cbnce #(.Width(8),.TMR(TMR)) l1an_write_addr_i (.CLK(CLK),.RST(RST),.CE(ce_wr),.Q(wa));
cbnce #(.Width(8),.TMR(TMR))  l1an_read_addr_i (.CLK(CLK),.RST(RST),.CE(ce_rd),.Q(ra));

udl_cnt #(.Width(8),.TMR(TMR)) l1an_counter_i(.CLK(CLK),.RST(RST),.CE(ce_wr ^ ce_rd),.L(1'b0),.UP(ce_wr),.D(8'h00),.Q(nl1a));

always @(posedge CLK or posedge RST) begin
	if(RST) begin
		EMPTY <= 1'b1;
		FULL  <= 1'b0;
		last  <= 1'b0;
	end
	else begin
		EMPTY <= !ce_wr & (EMPTY | (ce_rd & (nl1a == 8'h01)));
		FULL  <= !ce_rd & (FULL  | (ce_wr & last));
		last  <= (last & !ce_rd & ! ce_wr) | (ce_wr & (nl1a == 8'hFE)) | (last & ce_rd & !(nl1a == 8'hFE));
	end
end

  
generate
if(TMR==1) 
begin : l1an_fifo_TMR


   RAMB4_S16_S16 #(
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
   ) l1a_num_fifo_i1 (
      .DOA(doa_dmy1),     // Port A 16-bit data output
      .DOB(datal1an[15:0]),     // Port B 16-bit data output
      .ADDRA(wa), // Port A 8-bit address input
      .ADDRB(ra), // Port B 8-bit address input
      .CLKA(CLK),   // Port A clock input
      .CLKB(CLK),   // Port B clock input
      .DIA(datal1a[15:0]),     // Port A 16-bit data input
      .DIB(16'h0000),     // Port B 16-bit data input
      .ENA(1'b1),     // Port A RAM enable input
      .ENB(1'b1),     // Port B RAM enable input
      .RSTA(1'b0),   // Port A Synchronous reset input
      .RSTB(1'b0),   // Port B Synchronous reset input
      .WEA(ce_wr),     // Port A RAM write enable input
      .WEB(1'b0)      // Port B RAM write enable input
   );


   RAMB4_S16_S16 #(
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
   ) l1a_num_fifo_i2 (
      .DOA(doa_dmy2),     // Port A 16-bit data output
      .DOB(datal1an[31:16]),     // Port B 16-bit data output
      .ADDRA(wa), // Port A 8-bit address input
      .ADDRB(ra), // Port B 8-bit address input
      .CLKA(CLK),   // Port A clock input
      .CLKB(CLK),   // Port B clock input
      .DIA(datal1a[31:16]),     // Port A 16-bit data input
      .DIB(16'h0000),     // Port B 16-bit data input
      .ENA(1'b1),     // Port A RAM enable input
      .ENB(1'b1),     // Port B RAM enable input
      .RSTA(1'b0),   // Port A Synchronous reset input
      .RSTB(1'b0),   // Port B Synchronous reset input
      .WEA(ce_wr),     // Port A RAM write enable input
      .WEB(1'b0)      // Port B RAM write enable input
   );

	vote #(.Width(6)) vote_l1anum  (.A(datal1an[5:0]), .B(datal1an[12:7]), .C(datal1an[19:14]), .V(L1ANUM));
	vote #(.Width(1)) vote_l1phase (.A(datal1an[6]), .B(datal1an[13]), .C(datal1an[20]), .V(L1A_PHASE_OUT));

end
else 
begin : l1an_fifo_noTMR

   RAMB4_S16_S16 #(
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
   ) l1a_num_fifo_i1 (
      .DOA(doa_dmy1),     // Port A 16-bit data output
      .DOB(datal1an[15:0]),     // Port B 16-bit data output
      .ADDRA(wa), // Port A 8-bit address input
      .ADDRB(ra), // Port B 8-bit address input
      .CLKA(CLK),   // Port A clock input
      .CLKB(CLK),   // Port B clock input
      .DIA(datal1a[15:0]),     // Port A 16-bit data input
      .DIB(16'h0000),     // Port B 16-bit data input
      .ENA(1'b1),     // Port A RAM enable input
      .ENB(1'b1),     // Port B RAM enable input
      .RSTA(1'b0),   // Port A Synchronous reset input
      .RSTB(1'b0),   // Port B Synchronous reset input
      .WEA(ce_wr),     // Port A RAM write enable input
      .WEB(1'b0)      // Port B RAM write enable input
   );

	assign L1A_PHASE_OUT = datal1an[6];
	assign L1ANUM        = datal1an[5:0];

end
endgenerate

endmodule
