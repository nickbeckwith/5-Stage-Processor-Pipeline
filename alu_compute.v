module alu_compute(InputA, InputB, OutputA, OutputB);
	input [15:0] InputA, InputB;
	input [3:0] Opcode;
	output [15:0] OutputA, OutputB;
	
	wire [15:0] addsub_o;
	wire [2:0] addsub_f
	alu_adder ADDSUB (Opcode[0], InputA, InputB, addsub_o, addsub_f[2], addsub_f[1], addsub_f[0]);
	
	wire [15:0] red_o;
	red RED (InputA, InputB, red_o);

	wire [15:0] xor_o;
	xor_16b XOR (InputA, InputB, xor_o);
	
	wire [15:0] shift_o;
	wire shift_f;
	shifter SHIFT (shift_o, shift_f, InputA, InputB[3:0], Opcode[1:0]);

	//PADDSB

	wire [15:0] mem_addr;
	add_16b MEMADD (.a(InputA), .b(InputB), .cin(1'b0), .s(lw_addr));


endmodule
