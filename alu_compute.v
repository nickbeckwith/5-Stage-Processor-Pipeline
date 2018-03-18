module alu_compute(InputA, InputB, Opcode, OutputA, OutputB, Flag);
	input [15:0] InputA, InputB;
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
	assign imm_shift = InputB << 1;
	add_16b MEMADD (.a(rs_even), .b(imm_shift), .cin(1'b0), .s(mem_addr));
	assign OutputA = mem_addr;

	wire[15:0] MA_out;
	mux8_1_16b MA (.d0(addsub_o), .d1(addsub_o), .d2(red_o), .d3(xor_o), .d4(shift_o), .d5(shift_o), .d6(shift_o), .d7(paddsb_o), .b(MA_out), .s(Opcode[2:0]));
	
	wire [15:0] LLB, LHB, LXX_o;
	assign LLB = (InputA & 16'b1111111100000000) | InputB;
	assign LHB = (InputA & 16'b0000000011111111) | (InputB << 8);
	assign LXX_o = Opcode[0] ? LLB : LHB;

	wire [15:0] MB_out;
	mux2_1_16b MB (.d0(MA_out), .d1(LXX_o), .b(MB_out), .s(Opcode[3]));
	
	assign OutputB = MB_out;

	//0 = Z
	assign Flag[0] = MA_out == 16'b0000000000000000 ? 1'b1 : 1'b0;
	//1 = V
	assign Flag[1] = addsub_f[1];
	//2 = N 
	assign Flag[2] = addsub_f[2];
endmodule
