module paddsb(A, B, S, v);
	input [15:0] A, B;
	output [15:0] S;
	output [3:0] v;
	wire [3:0] Cout;

	wire [3:0] a_out, b_out, c_out, d_out;
	add_4b A1 (.a(A[7:4]), .b(B[7:4]), .cin(1'b0), .s(b_out), .cout(Cout[1]),
									.pp(), .gg());
	add_4b A0 (.a(A[3:0]), .b(B[3:0]), .cin(1'b0), .s(a_out), .cout(Cout[0]),
									.pp(), .gg());
	add_4b A2 (.a(A[11:8]), .b(B[11:8]), .cin(1'b0), .s(c_out), .cout(Cout[2]),
									.pp(), .gg());
	add_4b A3 (.a(A[15:12]), .b(B[15:12]), .cin(1'b0), .s(d_out), .cout(Cout[3]),
									.pp(), .gg());

	wire [3:0] V;
	assign v = V;
	assign V[0] = A[3] & B[3] & ~(S[3]) | ~(A[3]) & ~(B[3]) & S[3];
	assign V[1] = A[7] & B[7] & ~(S[7]) | ~(A[7]) & ~(B[7]) & S[7];
	assign V[2] = A[11] & B[11] & ~(S[11]) | ~(A[11]) & ~(B[11]) & S[11];
	assign V[3] = A[15] & B[15] & ~(S[15]) | ~(A[15]) & ~(B[15]) & S[15];

	wire [3:0] sata, satb, satc, satd;
	wire [3:0] neg, pos;
	assign neg = 4'b1000;
	assign pos = 4'b0111;
	assign sata = Cout[0] ? neg : pos;
	assign satb = Cout[1] ? neg : pos;
	assign satc = Cout[2] ? neg : pos;
	assign satd = Cout[3] ? neg : pos;

	wire [15:0] m_out;
	mux2_1_4b M0 (.d0(a_out), .d1(sata), .b(S[3:0]), .s(V[0]));
	mux2_1_4b M1 (.d0(b_out), .d1(satb), .b(S[7:4]), .s(V[1]));
	mux2_1_4b M2 (.d0(c_out), .d1(satc), .b(S[11:8]), .s(V[2]));
	mux2_1_4b M3 (.d0(d_out), .d1(satc), .b(S[15:12]), .s(V[3]));
endmodule
