`define ADD     4'b0000
`define SUB     4'b0001
`define RED     4'b0010
`define XOR     4'b0011
`define SLL     4'b0100
`define SRA     4'b0101
`define ROR     4'b0110
`define PADDSB  4'b0111
`define LW      4'b1000
`define SW      4'b1001
`define LHB     4'b1010
`define LLB     4'b1011
`define B       4'b1100
`define BR      4'b1101
`define PCS     4'b1110
`define HLT     4'b1111

module alu_compute(InputA, InputB, Offset, Shift_Imm, Opcode, OutputA, OutputB, Flag);
	input [15:0] InputA, InputB, Offset;
	input [3:0] Opcode, Shift_Imm;
	output [15:0] OutputA, OutputB;
	output [2:0] Flag;

	wire [15:0] addsub_o;
	wire [2:0] addsub_f;
	alu_adder ADDSUB (Opcode[0], InputA, InputB, addsub_o, addsub_f[2], addsub_f[1], addsub_f[0]);

	wire [15:0] red_o;
	RED RED_mod (InputA, InputB, red_o);

	wire [15:0] xor_o;
	xor_16b XOR (InputA, InputB, xor_o);

	wire [15:0] shift_o;
	wire shift_f;
	shifter SHIFT (.Shift_Out(shift_o), .Zero(shift_f), .Shift_In(InputA), .Shift_Val(Shift_Imm), .Mode(Opcode[1:0]));

	wire [15:0] paddsb_o;
	paddsb PADDSB (InputA, InputB, paddsb_o);

	wire [15:0] mem_addr, rs_even, imm_shift;
	assign rs_even = InputA & 16'b1111111111111110;
	assign imm_shift = Offset << 1;
	add_16b MEMADD (.a(rs_even), .b(imm_shift), .cin(1'b0), .s(OutputA), .cout());

	wire [15:0] LLB, LHB, LXX_o;
	assign LLB = {InputA[15:8], Offset[7:0]};
	assign LHB = {Offset[7:0], InputA[7:0]};

	// DETERMINES WHICH OPERATION PASSES AS AN OUTPUT
	//////////////////////////////////////////////////////////////
	reg [15:0] OutputB_im;
	always @(Opcode, addsub_o, red_o, xor_o, shift_o, paddsb_o) begin
		casez (Opcode)
			`SW 			: OutputB_im = InputB;
			`LHB 			: OutputB_im = LHB;
			`LLB 			: OutputB_im = LLB;
			`ADD 			: OutputB_im = addsub_o;
			`SUB 			: OutputB_im = addsub_o;
			`RED 			: OutputB_im = red_o;
			`XOR 			: OutputB_im = xor_o;
			`SLL 			: OutputB_im = shift_o;
			`SRA 			: OutputB_im = shift_o;
			`ROR 			: OutputB_im = shift_o;
			`PADDSB 	: OutputB_im = paddsb_o;
			default: OutputB_im = 16'h0000;
		endcase
	end
	assign OutputB = OutputB_im;
	/////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////

	// flags. Flag register is write restricted depending on opcode
	//0 = Z
	assign Flag[0] = OutputB == 16'h0000;
	//1 = V
	assign Flag[1] = addsub_f[1];
	//2 = N
	assign Flag[2] = addsub_f[2];
endmodule
