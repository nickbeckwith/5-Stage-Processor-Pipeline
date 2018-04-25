`include "ReadDecoder_4_16.v"
`include "WriteDecoder_4_16.v"
`include "Register.v"

module registerfile (input clk, input rst, input [3:0] SrcReg1, input [3:0] SrcReg2, input [3:0] DstReg, input WriteReg, input [15:0] DstData, inout [15:0] SrcData1, inout [15:0] SrcData2);
	wire [15:0] DEC1, DEC2, WDEC, OUT1, OUT2,zeros;
	assign zeros = 16'b0;
	ReadDecoder_4_16 SRC1 (.RegId(SrcReg1), .Wordline(DEC1));
	ReadDecoder_4_16 SRC2 (.RegId(SrcReg2), .Wordline(DEC2));

	WriteDecoder_4_16 WR (.RegId(DstReg), .WriteReg(WriteReg), .Wordline(WDEC));

	Register R0 (.clk(clk), .rst(rst), .D(zeros), .WriteReg(WDEC[0]), .ReadEnable1(DEC1[0]), .ReadEnable2(DEC2[0]), .Bitline1(OUT1), .Bitline2(OUT2));
	Register R1 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WDEC[1]), .ReadEnable1(DEC1[1]), .ReadEnable2(DEC2[1]), .Bitline1(OUT1), .Bitline2(OUT2));
	Register R2 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WDEC[2]), .ReadEnable1(DEC1[2]), .ReadEnable2(DEC2[2]), .Bitline1(OUT1), .Bitline2(OUT2));
	Register R3 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WDEC[3]), .ReadEnable1(DEC1[3]), .ReadEnable2(DEC2[3]), .Bitline1(OUT1), .Bitline2(OUT2));
	Register R4 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WDEC[4]), .ReadEnable1(DEC1[4]), .ReadEnable2(DEC2[4]), .Bitline1(OUT1), .Bitline2(OUT2));
	Register R5 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WDEC[5]), .ReadEnable1(DEC1[5]), .ReadEnable2(DEC2[5]), .Bitline1(OUT1), .Bitline2(OUT2));
	Register R6 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WDEC[6]), .ReadEnable1(DEC1[6]), .ReadEnable2(DEC2[6]), .Bitline1(OUT1), .Bitline2(OUT2));
	Register R7 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WDEC[7]), .ReadEnable1(DEC1[7]), .ReadEnable2(DEC2[7]), .Bitline1(OUT1), .Bitline2(OUT2));
	Register R8 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WDEC[8]), .ReadEnable1(DEC1[8]), .ReadEnable2(DEC2[8]), .Bitline1(OUT1), .Bitline2(OUT2));
	Register R9 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WDEC[9]), .ReadEnable1(DEC1[9]), .ReadEnable2(DEC2[9]), .Bitline1(OUT1), .Bitline2(OUT2));
	Register RA (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WDEC[10]), .ReadEnable1(DEC1[10]), .ReadEnable2(DEC2[10]), .Bitline1(OUT1), .Bitline2(OUT2));
	Register RB (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WDEC[11]), .ReadEnable1(DEC1[11]), .ReadEnable2(DEC2[11]), .Bitline1(OUT1), .Bitline2(OUT2));
	Register RC (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WDEC[12]), .ReadEnable1(DEC1[12]), .ReadEnable2(DEC2[12]), .Bitline1(OUT1), .Bitline2(OUT2));
	Register RD (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WDEC[13]), .ReadEnable1(DEC1[13]), .ReadEnable2(DEC2[13]), .Bitline1(OUT1), .Bitline2(OUT2));
	Register RE (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WDEC[14]), .ReadEnable1(DEC1[14]), .ReadEnable2(DEC2[14]), .Bitline1(OUT1), .Bitline2(OUT2));
	Register RF (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WDEC[15]), .ReadEnable1(DEC1[15]), .ReadEnable2(DEC2[15]), .Bitline1(OUT1), .Bitline2(OUT2));

//Implement Internal Bypassing Somehow
// forwarding time
// if SrcReg1 == DstReg then set SrcData1 to DstData
// if SrcReg2 == DstReg then set SrcData2 to DstData
// Should use combinational logic because buffers might result in a high impedence read
	assign SrcData1 = SrcReg1 == DstReg ? DstData : OUT1;
	assign SrcData2 = SrcReg2 == DstReg ? DstData : OUT2;
endmodule
