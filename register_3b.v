`include "BitCell.v"

module Register_3b (input clk, input rst, input [2:0] D, input WriteReg, input ReadEnable1, input ReadEnable2, inout [2:0] Bitline1, inout [2:0] Bitline2);
	BitCell B0 (.clk(clk), .rst(rst), .D(D[0]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[0]), .Bitline2(Bitline2[0]));
	BitCell B1 (.clk(clk), .rst(rst), .D(D[1]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[1]), .Bitline2(Bitline2[1]));
	BitCell B2 (.clk(clk), .rst(rst), .D(D[2]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[2]), .Bitline2(Bitline2[2]));
endmodule
