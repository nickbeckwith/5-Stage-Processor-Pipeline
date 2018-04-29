`include "dff.v"

module flag_reg(clk, rst, d, wrt_en, q);
	input
		clk,
		rst;
	input [2:0]
		wrt_en,
		d;
	output [2:0]
		q;
	wire[2:0] dff_out;

	dff ff[2:0](.q(dff_out), .d(d), .wen(wrt_en), .clk(clk), .rst(rst));

	// implement forwarding.
	assign q = (wrt_en & d) | (~wrt_en & dff_out);

endmodule
