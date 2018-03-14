module add_1b(a, b, cin, s, p, g);
	input a, b, cin;
	output s, p, g;

	assign s = a ^ b ^ cin;
	assign p = a ^ b;
	assign g = a & b;
endmodule
