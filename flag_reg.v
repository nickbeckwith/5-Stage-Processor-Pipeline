module FlagRegister( input clk,  input rst, input [2:0] D, input[2:0] WriteReg, input ReadEnable1, input ReadEnable2, output [2:0] Bitline1, output [2:0] Bitline2);

	BitCell cell_0(.clk(clk),.rst(rst),.D(D[0]), .WriteEnable(WriteReg[0]),.ReadEnable1(ReadEnable1),.ReadEnable2(ReadEnable2),.Bitline1(Bitline1[0]),.Bitline2(Bitline2[0]));
	BitCell cell_1(.clk(clk),.rst(rst),.D(D[1]), .WriteEnable(WriteReg[1]),.ReadEnable1(ReadEnable1),.ReadEnable2(ReadEnable2),.Bitline1(Bitline1[1]),.Bitline2(Bitline2[1]));
	BitCell cell_2(.clk(clk),.rst(rst),.D(D[2]), .WriteEnable(WriteReg[2]),.ReadEnable1(ReadEnable1),.ReadEnable2(ReadEnable2),.Bitline1(Bitline1[2]),.Bitline2(Bitline2[2]));



endmodule
