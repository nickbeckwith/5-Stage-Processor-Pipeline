`include "alu_compute.vh"

module alu_compute(input_A, input_B, offset, shift_imm, opcode, output_A,
			output_B, flag);
	input [15:0] input_A, input_B, offset;
	input [3:0] opcode, shift_imm;
	output [15:0] output_A, output_B;
	output [2:0] flag;

	wire [15:0] addsub_o;
	wire [2:0] addsub_f;
	alu_adder ADDSUB(
		.mode(opcode[0]),
		.A(input_A),
		.B(input_B),
		.S(addsub_o),
		.N(addsub_f[2]),
		.V(addsub_f[1]),
		.Z(addsub_f[0]));

	wire [15:0] red_o;
	RED RED_mod (input_A, input_B, red_o);

	wire [15:0] xor_o;
	assign xor_o = input_A ^ input_B;

	wire [15:0] shift_o;
	wire shift_f;
	shifter SHIFT(
		.Shift_Out(shift_o),
		.Zero(shift_f),
		.Shift_In(input_A),
		.Shift_Val(shift_imm),
		.Mode(opcode[1:0]));

	wire [15:0] paddsb_o;
	paddsb PADDSB(input_A, input_B, paddsb_o);

	wire [15:0] rs_even, imm_shift;
	assign rs_even = input_A & 16'b1111111111111110;
	assign imm_shift = offset << 1;
	add_16b MEMADD(.a(rs_even), .b(imm_shift), .cin(1'b0), .s(output_A), .cout());

	wire [15:0] LLB, LHB;
	assign LLB = {input_A[15:8], offset[7:0]};
	assign LHB = {offset[7:0], input_A[7:0]};

	// DETERMINES WHICH OPERATION PASSES AS AN OUTPUT
	//////////////////////////////////////////////////////////////
	reg [15:0] output_B_im;
	always @* begin
		casez (opcode)
			`SW 			: output_B_im = input_B;
			`LHB 			: output_B_im = LHB;
			`LLB 			: output_B_im = LLB;
			`ADD 			: output_B_im = addsub_o;
			`SUB 			: output_B_im = addsub_o;
			`RED 			: output_B_im = red_o;
			`XOR 			: output_B_im = xor_o;
			`SLL 			: output_B_im = shift_o;
			`SRA 			: output_B_im = shift_o;
			`ROR 			: output_B_im = shift_o;
			`PADDSB 	: output_B_im = paddsb_o;
			default: output_B_im = 16'h0000;
		endcase
	end
	assign output_B = output_B_im;
	/////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////
	wire [2:0] flag_imm;
	// flags. Flag register is write restricted depending on opcode
	//0 = Z
	assign flag_imm[0] = output_B == 16'h0000;
	//1 = V
	assign flag_imm[1] = addsub_f[1];
	//2 = N
	assign flag_imm[2] = addsub_f[2];

	// need to determine when to write each bit to reg
	wire [2:0] wrt_en;
	// if it's non arithmetic op, RED or paddsb don't write to zero reg
	assign wrt_en[0] = ~(opcode[3] | (opcode == `RED) | (opcode == `PADDSB));
	assign wrt_en[2:1] = (opcode == `ADD) | (opcode == `SUB);

	flag_reg flag(.clk(clk), .rst(rst), .d(flag_imm), .wrt_en(wrt_en), .q(flag));

endmodule
