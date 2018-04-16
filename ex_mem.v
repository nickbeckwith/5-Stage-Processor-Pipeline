module ex_mem (input [15:0] mem_addr_i, alu_data_i, pc_curr_i, pc_next_i, imm_i,
								input [3:0] rs_i, rt_i, rd_i, op_i,
								input hzrd, clk, rst, branch,
								output [15:0] mem_addr_o, alu_data_o, pc_curr_o, pc_next_o, imm_o,
								output [3:0] rs_o, rt_o, rd_o, op_o,
								output br_o);
	wire clear;
	assign clear = rst | br_o;
	Register mem_addr (.clk(clk), .rst(clear), .D(mem_addr_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(mem_addr_o), .Bitline2());
	Register alu_data (.clk(clk), .rst(clear), .D(alu_data_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(alu_data_o), .Bitline2());
	Register pc_curr (.clk(clk), .rst(clear), .D(pc_curr_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(pc_curr_o), .Bitline2());
	Register pc_next (.clk(clk), .rst(clear), .D(pc_next_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(pc_next_o), .Bitline2());
	Register imm (.clk(clk), .rst(clear), .D(imm_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(imm_o), .Bitline2());


	Register_4b rs (.clk(clk), .rst(clear), .D(rs_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(rs_o), .Bitline2());
	Register_4b rt (.clk(clk), .rst(clear), .D(rt_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(rt_o), .Bitline2());
	Register_4b rd (.clk(clk), .rst(clear), .D(rd_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(rd_o), .Bitline2());
	Register_4b op (.clk(clk), .rst(clear), .D(op_i), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(op_o), .Bitline2());
	Register_1b br (.clk(clk), .rst(clear), .D(branch), .WriteReg(hzrd), .ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(br_o), .Bitline2());
endmodule
