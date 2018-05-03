`include "BitCell.v"

module flag_reg( input clk,  input rst, input [2:0] D, input[2:0] WriteReg, input ReadEnable1, input ReadEnable2, output [2:0] Bitline1, output [2:0] Bitline2);
	wire[2:0] bit_out;

	BitCell cell_0(.clk(clk),.rst(rst),.D(D[0]), .WriteEnable(WriteReg[0]),.ReadEnable1(ReadEnable1),.ReadEnable2(ReadEnable2),.Bitline1(bit_out[0]),.Bitline2());
	BitCell cell_1(.clk(clk),.rst(rst),.D(D[1]), .WriteEnable(WriteReg[1]),.ReadEnable1(ReadEnable1),.ReadEnable2(ReadEnable2),.Bitline1(bit_out[1]),.Bitline2());
	BitCell cell_2(.clk(clk),.rst(rst),.D(D[2]), .WriteEnable(WriteReg[2]),.ReadEnable1(ReadEnable1),.ReadEnable2(ReadEnable2),.Bitline1(bit_out[2]),.Bitline2());
	
	assign Bitline1[0] = WriteReg[0] ? D[0] : bit_out[0]; 
	assign Bitline1[1] = WriteReg[1] ? D[1] : bit_out[1]; 
	assign Bitline1[2] = WriteReg[2] ? D[2] : bit_out[2]; 
endmodule
