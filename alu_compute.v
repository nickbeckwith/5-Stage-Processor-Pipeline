module alu_compute(InputA, InputB, Offset, Opcode, OutputA, OutputB, Flag);
	input [15:0] InputA, InputB, Offset;
	input [3:0] Opcode;
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
	shifter SHIFT (shift_o, shift_f, InputA, InputB[3:0], Opcode[1:0]);

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
			4'b1001 : OutputB_im = InputB;					// SW
			4'b1010 : OutputB_im = LHB;							// LHB
			4'b1011 : OutputB_im = LLB;							// LLB
			4'b0000 : OutputB_im = addsub_o;				// addition
			4'b0001 : OutputB_im = addsub_o;				// subtraction
			4'b0010 : OutputB_im = red_o;
			4'b0011 : OutputB_im = xor_o;
			4'b0100 : OutputB_im = shift_o;
			4'b0101 : OutputB_im = shift_o;
			4'b0110 : OutputB_im = shift_o;
			4'b0111 : OutputB_im = paddsb_o;
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
