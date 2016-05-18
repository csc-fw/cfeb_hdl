`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    11:32:37 02/05/2015 
// Design Name: 
// Module Name:    nbadr 
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
module nbadr #(
	parameter TMR = 0
)(
	input CLK,
	input RST,
	input WRENA,
	input NBSEL,
	input PATHASEL,
	input PATHBSEL,
	input PATHCSEL,
	input PATHDSEL,
	input ENAREG,
	input ENBL50,
	input DISBL50,
	input [3:0] YGTRG,
	input [3:0] NGTRG,
	input [3:0] FB_ADR,

	output VDSCAFULL,
	output VSCAFULL,
	output [6:0] WADR,
	output reg [2:0] DSCAFULL,
	output [3:0] NFREE_BLKS,
	output [11:0] LCTADR,
	output reg [6:0] W,
	output [7:0] LEDS
);

reg [2:0] sel;

wire [3:0] intd;
wire cerst;
wire [2:0] gcnt_out;
reg  [2:0] gwout;
wire [15:0] bmem;

assign WADR[2:0] = gwout;
assign cerst = RST | ENAREG;
//assign LEDS = {!(RST | VSCAFULL),~WADR};
assign LEDS = bmem[7:0];


(* syn_useioff = "True" *)
always @(posedge CLK)
begin
	W[2:0] <= gcnt_out;
	if(ENAREG)
		W[6:3] <= intd;
end

always @(posedge CLK) begin
	gwout <= gcnt_out;
end

always @* begin
	casex ({3'b000,PATHDSEL,PATHCSEL,PATHBSEL,PATHASEL})
		7'b0000000: sel = 3'd0;
		7'b0000001: sel = 3'd1;
		7'b000001x: sel = 3'd2;
		7'b00001xx: sel = 3'd3;
		7'b0001xxx: sel = 3'd4;
		7'b001xxxx: sel = 3'd5;
		7'b01xxxxx: sel = 3'd6;
		7'b1xxxxxx: sel = 3'd7;
	endcase
end

  
generate
if(TMR==1) 
begin : nbadr_TMR

	(* syn_keep = "true" *) reg [3:0] wradr_a;
	(* syn_keep = "true" *) reg [3:0] wradr_b;
	(* syn_keep = "true" *) reg [3:0] wradr_c;
	(* syn_keep = "true" *) wire [3:0] nadr_a;
	(* syn_keep = "true" *) wire [3:0] nadr_b;
	(* syn_keep = "true" *) wire [3:0] nadr_c;
	(* syn_keep = "true" *) wire [3:0] intd_a;
	(* syn_keep = "true" *) wire [3:0] intd_b;
	(* syn_keep = "true" *) wire [3:0] intd_c;
	(* syn_keep = "true" *) wire [2:0] scafull;
	(* syn_preserve = "true" *) reg [2:0] scafull_1;
	(* syn_preserve = "true" *) reg [2:0] scafull_2;
	(* syn_preserve = "true" *) reg lrst_a;
	(* syn_preserve = "true" *) reg lrst_b;
	(* syn_preserve = "true" *) reg lrst_c;
	(* syn_preserve = "true" *) reg [3:0] do_a;
	(* syn_preserve = "true" *) reg [3:0] do_b;
	(* syn_preserve = "true" *) reg [3:0] do_c;
	(* syn_preserve = "true" *) reg [3:0] ddo_a;
	(* syn_preserve = "true" *) reg [3:0] ddo_b;
	(* syn_preserve = "true" *) reg [3:0] ddo_c;
	(* syn_preserve = "true" *) reg [3:0] dddo_a;
	(* syn_preserve = "true" *) reg [3:0] dddo_b;
	(* syn_preserve = "true" *) reg [3:0] dddo_c;
	(* syn_preserve = "true" *) reg [2:0] gcnt_a;
	(* syn_preserve = "true" *) reg [2:0] gcnt_b;
	(* syn_preserve = "true" *) reg [2:0] gcnt_c;
	(* syn_keep = "true" *) wire [2:0] qad_a;
	(* syn_keep = "true" *) wire [2:0] qad_b;
	(* syn_keep = "true" *) wire [2:0] qad_c;
	(* syn_keep = "true" *) wire up_a;
	(* syn_keep = "true" *) wire up_b;
	(* syn_keep = "true" *) wire up_c;

	wire lrst;
	wire [15:0] dmy_bmem1;
	wire [15:0] dmy_bmem2;
	wire [3:0] dmy_fb1;
	wire [3:0] dmy_fb2;

	assign LCTADR = {dddo_a,dddo_b,dddo_c};

	assign up_a = (nadr_a[0] ^ nadr_a[1]) ~^ (nadr_a[2] ^ nadr_a[3]);
	assign up_b = (nadr_b[0] ^ nadr_b[1]) ~^ (nadr_b[2] ^ nadr_b[3]);
	assign up_c = (nadr_c[0] ^ nadr_c[1]) ~^ (nadr_c[2] ^ nadr_c[3]);

	assign intd_a = (!lrst & !scafull[0]) ? nadr_a : {!lrst,lrst,lrst,!lrst};
	assign intd_b = (!lrst & !scafull[1]) ? nadr_b : {!lrst,lrst,lrst,!lrst};
	assign intd_c = (!lrst & !scafull[2]) ? nadr_c : {!lrst,lrst,lrst,!lrst};


	vote #(.Width(4)) vote_intd (.A(intd_a), .B(intd_b), .C(intd_c), .V(intd));

	vote #(.Width(1)) vote_vsca  (.A(scafull[0]), .B(scafull[1]), .C(scafull[2]), .V(VSCAFULL));
	vote #(.Width(1)) vote_vdsca (.A(DSCAFULL[0]), .B(DSCAFULL[1]), .C(DSCAFULL[2]), .V(VDSCAFULL));


	always @* begin
		case (sel)
			3'd0: wradr_a = LCTADR[3:0];
			3'd1: wradr_a = WADR[6:3];
			3'd2: wradr_a = NGTRG;
			3'd3: wradr_a = YGTRG;
			3'd4: wradr_a = FB_ADR;
			3'd5: wradr_a = 4'd0;
			3'd6: wradr_a = 4'd0;
			3'd7: wradr_a = 4'd0;
		endcase
		case (sel)
			3'd0: wradr_b = LCTADR[7:4];
			3'd1: wradr_b = WADR[6:3];
			3'd2: wradr_b = NGTRG;
			3'd3: wradr_b = YGTRG;
			3'd4: wradr_b = FB_ADR;
			3'd5: wradr_b = 4'd0;
			3'd6: wradr_b = 4'd0;
			3'd7: wradr_b = 4'd0;
		endcase
		case (sel)
			3'd0: wradr_c = LCTADR[11:8];
			3'd1: wradr_c = WADR[6:3];
			3'd2: wradr_c = NGTRG;
			3'd3: wradr_c = YGTRG;
			3'd4: wradr_c = FB_ADR;
			3'd5: wradr_c = 4'd0;
			3'd6: wradr_c = 4'd0;
			3'd7: wradr_c = 4'd0;
		endcase
	end

	always @(posedge CLK) begin
		lrst_a <= RST;
		lrst_b <= RST;
		lrst_c <= RST;
	end

	vote #(.Width(1)) vote_lrst (.A(lrst_a), .B(lrst_b), .C(lrst_c), .V(lrst));


	always @(posedge CLK or posedge lrst)
	begin
		if(lrst)
			begin
				scafull_1 <= 3'b000;
				scafull_2 <= 3'b000;
				DSCAFULL  <= 3'b000;
			end
		else
			if(ENAREG)
				begin
					scafull_1 <= scafull;
					scafull_2 <= scafull_1;
					DSCAFULL  <= scafull_2;
				end
	end

	always @(posedge CLK or posedge lrst)
	begin
		if(lrst)
			begin
				do_a   <= 4'h0;
				do_b   <= 4'h0;
				do_c   <= 4'h0;
				ddo_a  <= 4'h0;
				ddo_b  <= 4'h0;
				ddo_c  <= 4'h0;
				dddo_a <= 4'h0;
				dddo_b <= 4'h0;
				dddo_c <= 4'h0;
			end
		else
			if(ENAREG)
				begin
					do_a   <= intd_a;
					do_b   <= intd_b;
					do_c   <= intd_c;
					ddo_a  <= do_a;
					ddo_b  <= do_b;
					ddo_c  <= do_c;
					dddo_a <= ddo_a;
					dddo_b <= ddo_b;
					dddo_c <= ddo_c;
				end
	end

	vote #(.Width(4)) vote_wadr (.A(do_a), .B(do_b), .C(do_c), .V(WADR[6:3]));

	cbnce3q #(.Width(3),.TMR(1)) wcap_gcnt (.CLK(CLK),.RST(cerst),.CE(DISBL50),.Q1(qad_a),.Q2(qad_b),.Q3(qad_c));

	always @* begin
		case ({up_a,qad_a})
			4'b0000: gcnt_a <= 3'b100;
			4'b0001: gcnt_a <= 3'b101;
			4'b0010: gcnt_a <= 3'b111;
			4'b0011: gcnt_a <= 3'b110;
			4'b0100: gcnt_a <= 3'b010;
			4'b0101: gcnt_a <= 3'b011;
			4'b0110: gcnt_a <= 3'b001;
			4'b0111: gcnt_a <= 3'b000;
			4'b1000: gcnt_a <= 3'b000;
			4'b1001: gcnt_a <= 3'b001;
			4'b1010: gcnt_a <= 3'b011;
			4'b1011: gcnt_a <= 3'b010;
			4'b1100: gcnt_a <= 3'b110;
			4'b1101: gcnt_a <= 3'b111;
			4'b1110: gcnt_a <= 3'b101;
			4'b1111: gcnt_a <= 3'b100;
			default: gcnt_a <= 3'b000;
		endcase	 
		case ({up_b,qad_b})
			4'b0000: gcnt_b <= 3'b100;
			4'b0001: gcnt_b <= 3'b101;
			4'b0010: gcnt_b <= 3'b111;
			4'b0011: gcnt_b <= 3'b110;
			4'b0100: gcnt_b <= 3'b010;
			4'b0101: gcnt_b <= 3'b011;
			4'b0110: gcnt_b <= 3'b001;
			4'b0111: gcnt_b <= 3'b000;
			4'b1000: gcnt_b <= 3'b000;
			4'b1001: gcnt_b <= 3'b001;
			4'b1010: gcnt_b <= 3'b011;
			4'b1011: gcnt_b <= 3'b010;
			4'b1100: gcnt_b <= 3'b110;
			4'b1101: gcnt_b <= 3'b111;
			4'b1110: gcnt_b <= 3'b101;
			4'b1111: gcnt_b <= 3'b100;
			default: gcnt_b <= 3'b000;
		endcase	 
		case ({up_c,qad_c})
			4'b0000: gcnt_c <= 3'b100;
			4'b0001: gcnt_c <= 3'b101;
			4'b0010: gcnt_c <= 3'b111;
			4'b0011: gcnt_c <= 3'b110;
			4'b0100: gcnt_c <= 3'b010;
			4'b0101: gcnt_c <= 3'b011;
			4'b0110: gcnt_c <= 3'b001;
			4'b0111: gcnt_c <= 3'b000;
			4'b1000: gcnt_c <= 3'b000;
			4'b1001: gcnt_c <= 3'b001;
			4'b1010: gcnt_c <= 3'b011;
			4'b1011: gcnt_c <= 3'b010;
			4'b1100: gcnt_c <= 3'b110;
			4'b1101: gcnt_c <= 3'b111;
			4'b1110: gcnt_c <= 3'b101;
			4'b1111: gcnt_c <= 3'b100;
			default: gcnt_c <= 3'b000;
		endcase	 
	end

	vote #(.Width(3)) vote_wcap_gcnt (.A(gcnt_a),.B(gcnt_b),.C(gcnt_c),.V(gcnt_out));

	nbaselvs #(.TMR(1))
	next_block_mem_a(
		.CLK(CLK),
		.RST(RST),
		.WRENA(WRENA),
		.SELA(PATHASEL),
		.NBSEL(NBSEL),
		.BADR(wradr_a),
		.RDADR(WADR[6:3]),
		.NADR(nadr_a),
		.BMEM(bmem),
		.NFREE_BLKS(NFREE_BLKS),
		.SCAFULL(scafull[0])
	);

	nbaselvs #(.TMR(1))
	next_block_mem_b(
		.CLK(CLK),
		.RST(RST),
		.WRENA(WRENA),
		.SELA(PATHASEL),
		.NBSEL(NBSEL),
		.BADR(wradr_b),
		.RDADR(WADR[6:3]),
		.NADR(nadr_b),
		.BMEM(dmy_bmem1),
		.NFREE_BLKS(dmy_fb1),
		.SCAFULL(scafull[1])
	);

	nbaselvs #(.TMR(1))
	next_block_mem_c(
		.CLK(CLK),
		.RST(RST),
		.WRENA(WRENA),
		.SELA(PATHASEL),
		.NBSEL(NBSEL),
		.BADR(wradr_c),
		.RDADR(WADR[6:3]),
		.NADR(nadr_c),
		.BMEM(dmy_bmem2),
		.NFREE_BLKS(dmy_fb2),
		.SCAFULL(scafull[2])
	);

end
else
begin : nbadr_noTMR

	reg [3:0] wradr;
	wire [3:0] nadr;
	wire scafull;
	reg scafull_1;
	reg scafull_2;
	reg [3:0] doo;
	reg [3:0] ddo;
	reg [3:0] dddo;
	reg [2:0] gcnt;
	wire [2:0] qad;
	wire up;

	assign LCTADR = {dddo,dddo,dddo};

	assign up = (nadr[0] ^ nadr[1]) ~^ (nadr[2] ^ nadr[3]);

	assign intd = (!RST & !scafull) ? nadr : {!RST,RST,RST,!RST};

	assign VSCAFULL  = scafull;
	assign VDSCAFULL = DSCAFULL[0];


	always @* begin
		case (sel)
			3'd0: wradr = LCTADR[3:0];
			3'd1: wradr = WADR[6:3];
			3'd2: wradr = NGTRG;
			3'd3: wradr = YGTRG;
			3'd4: wradr = FB_ADR;
			3'd5: wradr = 4'd0;
			3'd6: wradr = 4'd0;
			3'd7: wradr = 4'd0;
		endcase
	end


	always @(posedge CLK or posedge RST)
	begin
		if(RST)
			begin
				scafull_1 <= 1'b0;
				scafull_2 <= 1'b0;
				DSCAFULL  <= 3'b000;
			end
		else
			if(ENAREG)
				begin
					scafull_1 <= scafull;
					scafull_2 <= scafull_1;
					DSCAFULL  <= {scafull_2,scafull_2,scafull_2};
				end
	end

	always @(posedge CLK or posedge RST)
	begin
		if(RST)
			begin
				doo  <= 4'h0;
				ddo  <= 4'h0;
				dddo <= 4'h0;
			end
		else
			if(ENAREG)
				begin
					doo  <= intd;
					ddo  <= doo;
					dddo <= ddo;
				end
	end

	assign WADR[6:3] = doo;

	cbnce #(.Width(3),.TMR(0)) wcap_gcnt (.CLK(CLK),.RST(cerst),.CE(DISBL50),.Q(qad));

	always @* begin
		case ({up,qad})
			4'b0000: gcnt <= 3'b100;
			4'b0001: gcnt <= 3'b101;
			4'b0010: gcnt <= 3'b111;
			4'b0011: gcnt <= 3'b110;
			4'b0100: gcnt <= 3'b010;
			4'b0101: gcnt <= 3'b011;
			4'b0110: gcnt <= 3'b001;
			4'b0111: gcnt <= 3'b000;
			4'b1000: gcnt <= 3'b000;
			4'b1001: gcnt <= 3'b001;
			4'b1010: gcnt <= 3'b011;
			4'b1011: gcnt <= 3'b010;
			4'b1100: gcnt <= 3'b110;
			4'b1101: gcnt <= 3'b111;
			4'b1110: gcnt <= 3'b101;
			4'b1111: gcnt <= 3'b100;
			default: gcnt <= 3'b000;
		endcase	 
	end

	assign gcnt_out = gcnt;

	nbaselvs #(.TMR(0))
	next_block_mem(
		.CLK(CLK),
		.RST(RST),
		.WRENA(WRENA),
		.SELA(PATHASEL),
		.NBSEL(NBSEL),
		.BADR(wradr),
		.RDADR(WADR[6:3]),
		.NADR(nadr),
		.BMEM(bmem),
		.NFREE_BLKS(NFREE_BLKS),
		.SCAFULL(scafull)
	);

	
end
endgenerate

endmodule
