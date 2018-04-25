`include "Register.v"
`include "Register_4b.v"

module mem_wb (input [15:0] mem_data_i, alu_data_i, pc_i, imm_i, input [3:0] rs_i, rt_i, rd_i, op_i, input hzrd, clk, rst, output [15:0] mem_data_o, alu_data_o, pc_o, imm_o, output [3:0] rs_o, rt_o, rd_o, op_o);
	Register mem_data (.clk(clk), .rst(rst), .D(mem_data_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(mem_data_o), .Bitline2());
	Register alu_data (.clk(clk), .rst(rst), .D(alu_data_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(alu_data_o), .Bitline2());
	Register pc_curr (.clk(clk), .rst(rst), .D(pc_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(pc_o), .Bitline2());
	Register imm (.clk(clk), .rst(rst), .D(imm_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(imm_o), .Bitline2());


	Register_4b rs (.clk(clk), .rst(rst), .D(rs_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(rs_o), .Bitline2());
	Register_4b rt (.clk(clk), .rst(rst), .D(rt_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(rt_o), .Bitline2());
	Register_4b rd (.clk(clk), .rst(rst), .D(rd_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(rd_o), .Bitline2());
	Register_4b op (.clk(clk), .rst(rst), .D(op_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(op_o), .Bitline2());
endmodule
