module shifter(Shift_Out, Shift_In, Shift_Val, Mode);
	input [15:0] Shift_In;
	input [3:0] Shift_Val;
	input [1:0] Mode;
	output [15:0] Shift_Out;
	wire [15:0] sll_out;
	wire [15:0] sra_out;
	wire [15:0] ror_out;

	ror ROTATE (ror_out, Shift_In, Shift_Val);
	sll LEFT (sll_out, Shift_In, Shift_Val);
	sra RIGHT (sra_out, Shift_In, Shift_Val);
	
	//Mode = 00 => SLL, Mode = 01 => SRA, Mode = 10 => ROR
	mux3_1_16b selector(.d2(ror_out), .d1(sra_out), .d0(sll_out), .b(Shift_Out), .s(Mode));
endmodule
