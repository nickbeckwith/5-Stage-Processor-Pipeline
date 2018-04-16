`include "add_1b.v"
`include "cla_unit.v"

module add_4b(a, b, cin, s, pp, gg, cout);
	input [3:0] a, b;
	input cin;
	output [3:0] s;
	output pp, gg, cout;
	wire[3:0] p, g, c;

	add_1b A0(a[0], b[0], cin, s[0], p[0], g[0]);
	add_1b A1(a[1], b[1], c[0], s[1], p[1], g[1]);
	add_1b A2(a[2], b[2], c[1], s[2], p[2], g[2]);
	add_1b A3(a[3], b[3], c[2], s[3], p[3], g[3]);

	cla_unit CLA (p, g, cin, pp, gg, c);
	assign cout = c[3];
endmodule
