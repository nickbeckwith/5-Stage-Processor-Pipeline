module alu_adder(mode, A, B, S, N, V, Z);
	input mode;
	input [15:0] A, B;
	output [15:0] S;
	output N, V, Z;

	wire [15:0] mode_ext, bin;
	assign mode_ext = {16{mode}};
	assign bin = B ^ mode_ext;

	wire cout;
	add_16b ADD (A, bin, mode, S, cout);

	assign N = S[15];
	assign Z = S == 16'b0 ? 1'b1 : 1'b0;
	assign V = A[15] & B[15] & ~(mode) & ~(S[15]) | ~(A[15]) & ~(B[15]) & ~(mode) & S[15] | A[15] & ~(B[15]) & mode & ~(S[15]) | ~(A[15]) & B[15] & mode & S[15];
endmodule
