module CLA_5bit(input [4:0] A,B, output [4:0] S, output Cout);
	wire g0,p0,g1,p1,g2,p2,g3,p3,g4,p4,c0,c1,c2,c3,c4,int_1,int_2,int_3,int_4,int_5;
	assign c0 = 0;
	and a0(int_1,c0,p0);
	or  o0(c1,int_1,g0);
	and a1(int_2,c1,p1);
	or  o1(c2,int_2,g1);
	and a2(int_3,c2,p2);
	or  o2(c3,int_3,g2);
	and a3(int_4,c3,p3);
	or  o3(c4,int_4,g3);
	and a4(int_5,c4,p4);
	or  o4(Cout,int_5,g4);

	CLA_Cell Cell0(.A(A[0]),.B(B[0]),.Cin(c0),.S(S[0]),.p(p0),.g(g0));
	CLA_Cell Cell1(.A(A[1]),.B(B[1]),.Cin(c1),.S(S[1]),.p(p1),.g(g1));
	CLA_Cell Cell2(.A(A[2]),.B(B[2]),.Cin(c2),.S(S[2]),.p(p2),.g(g2));
	CLA_Cell Cell3(.A(A[3]),.B(B[3]),.Cin(c3),.S(S[3]),.p(p3),.g(g3));
	CLA_Cell Cell4(.A(A[4]),.B(B[4]),.Cin(c4),.S(S[4]),.p(p4),.g(g4));


endmodule
