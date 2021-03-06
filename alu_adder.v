module alu_adder(mode, A, B, S, N, V, Z);
	input mode;
	input [15:0] A, B;
	output [15:0] S;
	output N, V, Z;

	wire [15:0] mode_ext, bin;
	assign mode_ext = {16{mode}};
	assign bin = B ^ mode_ext;

	wire [15:0] sw;
	wire cout;
	add_16b ADD (A, bin, mode, sw, cout);

	assign N = S[15];
	assign Z = S == 16'b0 ? 1'b1 : 1'b0;
	assign V = A[15] & B[15] & ~(mode) & ~(sw[15]) | ~(A[15]) & ~(B[15]) & ~(mode) & sw[15] | A[15] & ~(B[15]) & mode & ~(sw[15]) | ~(A[15]) & B[15] & mode & sw[15];

	wire [15:0] saturate;
	assign saturate = cout ? {1'b1, {15{1'b0}}} : {1'b0, {15{1'b1}}};
	assign S = V ? saturate : sw;
endmodule
