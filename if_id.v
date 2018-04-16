module if_id (input clk, rst, hzrd, branch, input [15:0] pc_i, instr_i, output [15:0] pc_o, instr_o);
	wire clear;
	assign clear = rst | branch;
	Register PC (.clk(clk), .rst(clear), .D(pc_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(pc_o), .Bitline2());
	Register INSTR (.clk(clk), .rst(clear), .D(instr_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(instr_o), .Bitline2());
endmodule


