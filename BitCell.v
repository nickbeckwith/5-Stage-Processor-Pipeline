`include "dff.v"

module BitCell(input clk, input rst, input D, input WriteEnable, input ReadEnable1, input ReadEnable2, inout Bitline1, inout Bitline2);

	wire ff_out;
	dff FF (.q(ff_out), .d(D), .wen(WriteEnable), .clk(clk), .rst(rst));

	assign Bitline1 = ReadEnable1 ? ff_out : 1'bz;
	assign Bitline2 = ReadEnable2 ? ff_out : 1'bz;
endmodule
