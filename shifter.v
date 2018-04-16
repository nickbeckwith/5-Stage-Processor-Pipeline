`include "ror.v"
`include "sll.v"
`include "sra.v"

module shifter(Shift_Out, Zero, Shift_In, Shift_Val, Mode);
	input [15:0] Shift_In;
	input [3:0] Shift_Val;
	input [1:0] Mode;
	output [15:0] Shift_Out;
	output Zero;
	wire [15:0] sll_out;
	wire [15:0] sra_out;
	wire [15:0] ror_out;

	ror ROTATE (ror_out, Shift_In, Shift_Val);
	sll LEFT (sll_out, Shift_In, Shift_Val);
	sra RIGHT (sra_out, Shift_In, Shift_Val);

	//Mode = 00 => SLL, Mode = 01 => SRA, Mode = 10 => ROR
	assign Shift_out = Mode == 2'b10 ? ror_out :
										 Mode == 2'b01 ? sra_out :
										 Mode == 2'b00 ? sll_out : 16'h0;

	assign Zero = Shift_Out == 16'b0;
endmodule
