`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:20:49 02/10/2015 
// Design Name: 
// Module Name:    fifo3 
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
module fifo3 #(
	parameter TMR = 0
)(
	input CLK,
	input RST,
	input PUSH,
	input POP,
	input CEW,
	input CER,
	input LCT_PH_IN,
	input DLSCAFULL,
	input SCND_BLK_IN,
	input SCND_SH_IN,
	input [3:0] BLKIN,
	input [7:0] L1PIN,
	output reg EMPTY,
	output reg FULL,
	output LCT_PH_OUT,
	output DGSCAFULL,
	output SCND_BLK_OUT,
	output SCND_SH_OUT,
	output [3:0] BLKOUT,
	output [7:0] L1POUT,
	output [7:0] NL1ABLK
);


wire ce_wr;
wire ce_rd;
wire [7:0] wa;
wire [7:0] ra;
reg last;
wire [15:0] datain;

initial
begin
	EMPTY = 0;
	FULL = 0;
	last = 0;
end

assign ce_wr = CEW & PUSH & !FULL;
assign ce_rd = CER & POP  & !EMPTY;
assign datain = {BLKIN,L1PIN,DLSCAFULL,SCND_SH_IN,SCND_BLK_IN,LCT_PH_IN};

cbnce #(.Width(8),.TMR(TMR)) l1ab_write_addr_i (.CLK(CLK),.RST(RST),.CE(ce_wr),.Q(wa));
cbnce #(.Width(8),.TMR(TMR))  l1ab_read_addr_i (.CLK(CLK),.RST(RST),.CE(ce_rd),.Q(ra));

udl_cnt #(.Width(8),.TMR(TMR)) l1ablk_counter_i(.CLK(CLK),.RST(RST),.CE(ce_wr ^ ce_rd),.L(1'b0),.UP(ce_wr),.D(8'h00),.Q(NL1ABLK));

always @(posedge CLK or posedge RST) begin
	if(RST) begin
		EMPTY <= 1'b1;
		FULL  <= 1'b0;
		last  <= 1'b0;
	end
	else begin
		EMPTY <= !ce_wr & (EMPTY | (ce_rd & (NL1ABLK == 8'h01)));
		FULL  <= !ce_rd & (FULL  | (ce_wr & last));
		last  <= (last & !ce_rd & ! ce_wr) | (ce_wr & (NL1ABLK == 8'hFE)) | (last & ce_rd & !(NL1ABLK == 8'hFE));
	end
end

  
generate
if(TMR==1) 
begin : fifo3_TMR

	(* syn_keep = "true" *) wire [15:0] data_a;
	(* syn_keep = "true" *) wire [15:0] data_b;
	(* syn_keep = "true" *) wire [15:0] data_c;
	wire [15:0] doa_dmy1;
	wire [15:0] doa_dmy2;
	wire [15:0] doa_dmy3;

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
   ) fifo3_i1 (
      .DOA(doa_dmy1),     // Port A 16-bit data output
      .DOB(data_a),     // Port B 16-bit data output
      .ADDRA(wa), // Port A 8-bit address input
      .ADDRB(ra), // Port B 8-bit address input
      .CLKA(CLK),   // Port A clock input
      .CLKB(CLK),   // Port B clock input
      .DIA(datain),     // Port A 16-bit data input
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
   ) fifo3_i2 (
      .DOA(doa_dmy2),     // Port A 16-bit data output
      .DOB(data_b),     // Port B 16-bit data output
      .ADDRA(wa), // Port A 8-bit address input
      .ADDRB(ra), // Port B 8-bit address input
      .CLKA(CLK),   // Port A clock input
      .CLKB(CLK),   // Port B clock input
      .DIA(datain),     // Port A 16-bit data input
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
   ) fifo3_i3 (
      .DOA(doa_dmy3),     // Port A 16-bit data output
      .DOB(data_c),     // Port B 16-bit data output
      .ADDRA(wa), // Port A 8-bit address input
      .ADDRB(ra), // Port B 8-bit address input
      .CLKA(CLK),   // Port A clock input
      .CLKB(CLK),   // Port B clock input
      .DIA(datain),     // Port A 16-bit data input
      .DIB(16'h0000),     // Port B 16-bit data input
      .ENA(1'b1),     // Port A RAM enable input
      .ENB(1'b1),     // Port B RAM enable input
      .RSTA(1'b0),   // Port A Synchronous reset input
      .RSTB(1'b0),   // Port B Synchronous reset input
      .WEA(ce_wr),     // Port A RAM write enable input
      .WEB(1'b0)      // Port B RAM write enable input
   );


	vote #(.Width(4)) vote_f3_blk (.A(data_a[15:12]), .B(data_b[15:12]), .C(data_c[15:12]), .V(BLKOUT));
	vote #(.Width(8)) vote_f3_l1p (.A(data_a[11:4]),  .B(data_b[11:4]),  .C(data_c[11:4]),  .V(L1POUT));
	vote #(.Width(1)) vote_f3_ful (.A(data_a[3]),     .B(data_b[3]),     .C(data_c[3]),     .V(DGSCAFULL));
	vote #(.Width(1)) vote_f3_shr (.A(data_a[2]),     .B(data_b[2]),     .C(data_c[2]),     .V(SCND_SH_OUT));
	vote #(.Width(1)) vote_f3_snd (.A(data_a[1]),     .B(data_b[1]),     .C(data_c[1]),     .V(SCND_BLK_OUT));
	vote #(.Width(1)) vote_f3_lct (.A(data_a[0]),     .B(data_b[0]),     .C(data_c[0]),     .V(LCT_PH_OUT));

end
else 
begin : fifo3_noTMR

	wire [15:0] data;
	wire [15:0] doa_dmy1;

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
   ) fifo3_i1 (
      .DOA(doa_dmy1),     // Port A 16-bit data output
      .DOB(data),     // Port B 16-bit data output
      .ADDRA(wa), // Port A 8-bit address input
      .ADDRB(ra), // Port B 8-bit address input
      .CLKA(CLK),   // Port A clock input
      .CLKB(CLK),   // Port B clock input
      .DIA(datain),     // Port A 16-bit data input
      .DIB(16'h0000),     // Port B 16-bit data input
      .ENA(1'b1),     // Port A RAM enable input
      .ENB(1'b1),     // Port B RAM enable input
      .RSTA(1'b0),   // Port A Synchronous reset input
      .RSTB(1'b0),   // Port B Synchronous reset input
      .WEA(ce_wr),     // Port A RAM write enable input
      .WEB(1'b0)      // Port B RAM write enable input
   );

	assign BLKOUT       = data[15:12];
	assign L1POUT       = data[11:4];
	assign DGSCAFULL    = data[3];
	assign SCND_SH_OUT  = data[2];
	assign SCND_BLK_OUT = data[1];
	assign LCT_PH_OUT   = data[0];

end
endgenerate

endmodule
