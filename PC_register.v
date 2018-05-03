module PC_register(clk, rst, wen, d, q);
	input
		clk,			// clk
		rst,			// active high synch reset
		wen;				// write enable signal
	input [15:0]
		d;
	output [15:0]
		q;

	// they call me Mr. Clean
	dff ff[15:0](.clk(clk), .rst(rst), .wen(wen), .d(d), .q(q));
endmodule
