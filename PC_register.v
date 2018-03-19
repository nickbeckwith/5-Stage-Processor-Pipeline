module PC_register( input clk,  input rst, input [15:0] D, input WriteReg, input ReadEnable1, input ReadEnable2, output [15:0] Bitline1, output [15:0] Bitline2);
	
	BitCell cell_0(.clk(clk),.rst(rst),.D(D[0]), .WriteEnable(WriteReg),.ReadEnable1(ReadEnable1),.ReadEnable2(ReadEnable2),.Bitline1(Bitline1[0]),.Bitline2(Bitline2[0])); 
	BitCell cell_1(.clk(clk),.rst(rst),.D(D[1]), .WriteEnable(WriteReg),.ReadEnable1(ReadEnable1),.ReadEnable2(ReadEnable2),.Bitline1(Bitline1[1]),.Bitline2(Bitline2[1])); 
	BitCell cell_2(.clk(clk),.rst(rst),.D(D[2]), .WriteEnable(WriteReg),.ReadEnable1(ReadEnable1),.ReadEnable2(ReadEnable2),.Bitline1(Bitline1[2]),.Bitline2(Bitline2[2])); 
	BitCell cell_3(.clk(clk),.rst(rst),.D(D[3]), .WriteEnable(WriteReg),.ReadEnable1(ReadEnable1),.ReadEnable2(ReadEnable2),.Bitline1(Bitline1[3]),.Bitline2(Bitline2[3]));
	BitCell cell_4(.clk(clk),.rst(rst),.D(D[4]), .WriteEnable(WriteReg),.ReadEnable1(ReadEnable1),.ReadEnable2(ReadEnable2),.Bitline1(Bitline1[4]),.Bitline2(Bitline2[4])); 
	BitCell cell_5(.clk(clk),.rst(rst),.D(D[5]), .WriteEnable(WriteReg),.ReadEnable1(ReadEnable1),.ReadEnable2(ReadEnable2),.Bitline1(Bitline1[5]),.Bitline2(Bitline2[5])); 
	BitCell cell_6(.clk(clk),.rst(rst),.D(D[6]), .WriteEnable(WriteReg),.ReadEnable1(ReadEnable1),.ReadEnable2(ReadEnable2),.Bitline1(Bitline1[6]),.Bitline2(Bitline2[6]));
	BitCell cell_7(.clk(clk),.rst(rst),.D(D[7]), .WriteEnable(WriteReg),.ReadEnable1(ReadEnable1),.ReadEnable2(ReadEnable2),.Bitline1(Bitline1[7]),.Bitline2(Bitline2[7]));	
	BitCell cell_8(.clk(clk),.rst(rst),.D(D[8]), .WriteEnable(WriteReg),.ReadEnable1(ReadEnable1),.ReadEnable2(ReadEnable2),.Bitline1(Bitline1[8]),.Bitline2(Bitline2[8])); 
	BitCell cell_9(.clk(clk),.rst(rst),.D(D[9]), .WriteEnable(WriteReg),.ReadEnable1(ReadEnable1),.ReadEnable2(ReadEnable2),.Bitline1(Bitline1[9]),.Bitline2(Bitline2[9])); 
	BitCell cell_10(.clk(clk),.rst(rst),.D(D[10]), .WriteEnable(WriteReg),.ReadEnable1(ReadEnable1),.ReadEnable2(ReadEnable2),.Bitline1(Bitline1[10]),.Bitline2(Bitline2[10])); 
	BitCell cell_11(.clk(clk),.rst(rst),.D(D[11]), .WriteEnable(WriteReg),.ReadEnable1(ReadEnable1),.ReadEnable2(ReadEnable2),.Bitline1(Bitline1[11]),.Bitline2(Bitline2[11])); 
	BitCell cell_12(.clk(clk),.rst(rst),.D(D[12]), .WriteEnable(WriteReg),.ReadEnable1(ReadEnable1),.ReadEnable2(ReadEnable2),.Bitline1(Bitline1[12]),.Bitline2(Bitline2[12])); 
	BitCell cell_13(.clk(clk),.rst(rst),.D(D[13]), .WriteEnable(WriteReg),.ReadEnable1(ReadEnable1),.ReadEnable2(ReadEnable2),.Bitline1(Bitline1[13]),.Bitline2(Bitline2[13])); 
	BitCell cell_14(.clk(clk),.rst(rst),.D(D[14]), .WriteEnable(WriteReg),.ReadEnable1(ReadEnable1),.ReadEnable2(ReadEnable2),.Bitline1(Bitline1[14]),.Bitline2(Bitline2[14]));
	BitCell cell_15(.clk(clk),.rst(rst),.D(D[15]), .WriteEnable(WriteReg),.ReadEnable1(ReadEnable1),.ReadEnable2(ReadEnable2),.Bitline1(Bitline1[15]),.Bitline2(Bitline2[15]));

	
endmodule
