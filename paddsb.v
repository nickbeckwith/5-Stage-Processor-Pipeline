module paddsb(A, B, S);
	input [15:0] A, B;
	output [15:0] S;
	wire [3:0] Cout;

`define MAX_POS 4'b0111
`define MAX_NEG 4'b1000

	wire [3:0] a_out, b_out, c_out, d_out;
	assign a_out = A[3:0] + B[3:0];
	assign b_out = A[7:4] + B[7:4];
	assign c_out = A[11:8] + B[11:8];
	assign d_out = A[15:12] + B[15:12];

	// saturation logic
	assign S[3:0] = a_out[3] & ~A[3] & ~B[3] ? `MAX_POS :
										~a_out[3] & A[3] & B[3] ? `MAX_NEG : a_out;
	assign S[7:4] = b_out[3] & ~A[7] & ~B[7] ? `MAX_POS :
										~b_out[3] & A[7] & B[7] ? `MAX_NEG : b_out;
	assign S[11:8] = c_out[3] & ~A[11] & ~B[11] ? `MAX_POS :
										~c_out[3] & A[11] & B[11] ? `MAX_NEG : c_out;
	assign S[15:12] = d_out[3] & ~A[15] & ~B[15] ? `MAX_POS :
									 		~d_out[3] & A[15] & B[15] ? `MAX_NEG : d_out;
endmodule
