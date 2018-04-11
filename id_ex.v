module id_ex (input [15:0] reg_rd_1_i, reg_rd_2_i, pc_i, imm_i, input [8:0] br_off_i, input [3:0] rs_i, rt_i, rd_i, op_i, input [2:0] ccode_i, input hzrd, clk, rst, branch, output [15:0] reg_rd_1_o, reg_rd_2_o, pc_o, imm_o, output [8:0] br_off_o, output [3:0] rs_o, rt_o, rd_o, op_o, output [2:0] ccode_o);
	wire clear = rst | branch;
	Register reg_rd_1 (.clk(clk), .rst(clear), .D(reg_rd_1_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(reg_rd_1_o), .Bitline2());
	Register reg_rd_2 (.clk(clk), .rst(clear), .D(reg_rd_2_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(reg_rd_2_o), .Bitline2());
	Register pc (.clk(clk), .rst(clear), .D(pc_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(pc_o), .Bitline2());
	Register imm (.clk(clk), .rst(clear), .D(imm_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(imm_o), .Bitline2());

	Register_9b br_off (.clk(clk), .rst(clear), .D(br_off_i), .WriteReg(hzrd), .ReadEnable1(1'b1) , .ReadEnable2(1'b0), .Bitline1(br_off_o), .Bitline2());

	Register_4b rs (.clk(clk), .rst(clear), .D(rs_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(rs_o), .Bitline2());
	Register_4b rt (.clk(clk), .rst(clear), .D(rt_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(rt_o), .Bitline2());
	Register_4b rd (.clk(clk), .rst(clear), .D(rd_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(rd_o), .Bitline2());
	Register_4b op (.clk(clk), .rst(clear), .D(op_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(op_o), .Bitline2());

	Register_3b ccode (.clk(clk), .rst(clear), .D(ccode_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(ccode_o), .Bitline2());
endmodule