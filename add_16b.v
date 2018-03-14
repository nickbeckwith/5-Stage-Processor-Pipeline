module add_16b(a, b, cin, s, cout);
	input [15:0] a, b;
	input cin;
	output [15:0] s;
	output cout, N, V, Z;
	wire [3:0] p, g, c;
	wire pp, gg;

	add_4b A0(a[3:0], b[3:0], cin, s[3:0], p[0], g[0]);
	add_4b A1(a[7:4], b[7:4], c[0], s[7:4], p[1], g[1]);
	add_4b A2(a[11:8], b[11:8], c[1], s[11:8], p[2], g[2]);
	add_4b A3(a[15:12], b[15:12], c[2], s[15:12], p[3], g[3]);

	cla_unit CLA (p, g, cin, pp, gg, c);

	assign cout = c[3];
endmodule
