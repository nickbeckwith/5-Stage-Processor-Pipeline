module Register_1b (input clk, input rst, input D, input WriteReg, input ReadEnable1, input ReadEnable2, inout Bitline1, inout Bitline2);
	BitCell B0 (.clk(clk), .rst(rst), .D(D), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1), .Bitline2(Bitline2));
endmodule
