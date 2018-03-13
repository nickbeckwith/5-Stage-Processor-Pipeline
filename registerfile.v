module mux_2_1(input [15:0] d0, input [15:0] d1, input s, output [15:0] b);
	reg [15:0] out;
	always @*case(s)
		1'b0 : out = d0;
		1'b1 : out = d1;
	endcase

	assign b = out;
endmodule

module dff (q, d, wen, clk, rst);

    output         q; //DFF output
    input          d; //DFF input
    input 	   wen; //Write Enable
    input          clk; //Clock
    input          rst; //Reset (used synchronously)

    reg            state;

    assign q = state;

    always @(posedge clk) begin
      state = rst ? 0 : (wen ? d : state);
    end

endmodule

module ReadDecoder_4_16(input [3:0] RegId, output [15:0] Wordline);
	assign Wordline[0] = ~(RegId[0]) & ~(RegId[1]) & ~(RegId[2]) & ~(RegId[3]); 
	assign Wordline[1] = RegId[0] & ~(RegId[1]) & ~(RegId[2]) & ~(RegId[3]); 
	assign Wordline[2] = ~(RegId[0]) & RegId[1] & ~(RegId[2]) & ~(RegId[3]); 
	assign Wordline[3] = RegId[0] & RegId[1] & ~(RegId[2]) & ~(RegId[3]); 
	assign Wordline[4] = ~(RegId[0]) & ~(RegId[1]) & RegId[2] & ~(RegId[3]); 
	assign Wordline[5] = RegId[0] & ~(RegId[1]) & RegId[2] & ~(RegId[3]); 
	assign Wordline[6] = ~(RegId[0]) & RegId[1] & RegId[2] & ~(RegId[3]); 
	assign Wordline[7] = RegId[0] & RegId[1] & RegId[2] & ~(RegId[3]); 
	assign Wordline[8] = ~(RegId[0]) & ~(RegId[1]) & ~(RegId[2]) & RegId[3]; 
	assign Wordline[9] = RegId[0] & ~(RegId[1]) & ~(RegId[2]) & RegId[3]; 
	assign Wordline[10] = ~(RegId[0]) & RegId[1] & ~(RegId[2]) & RegId[3]; 
	assign Wordline[11] = RegId[0] & RegId[1] & ~(RegId[2]) & RegId[3]; 
	assign Wordline[12] = ~(RegId[0]) & ~(RegId[1]) & RegId[2] & RegId[3]; 
	assign Wordline[13] = RegId[0] & ~(RegId[1]) & RegId[2] & RegId[3]; 
	assign Wordline[14] = ~(RegId[0]) & RegId[1] & RegId[2] & RegId[3]; 
	assign Wordline[15] = RegId[0] & RegId[1] & RegId[2] & RegId[3]; 
endmodule

module WriteDecoder_4_16(input [3:0] RegId, input WriteReg, output [15:0] Wordline);
	assign Wordline[0] = ~(RegId[0]) & ~(RegId[1]) & ~(RegId[2]) & ~(RegId[3]) & WriteReg; 
	assign Wordline[1] = RegId[0] & ~(RegId[1]) & ~(RegId[2]) & ~(RegId[3]) & WriteReg; 
	assign Wordline[2] = ~(RegId[0]) & RegId[1] & ~(RegId[2]) & ~(RegId[3]) & WriteReg;
	assign Wordline[3] = RegId[0] & RegId[1] & ~(RegId[2]) & ~(RegId[3]) & WriteReg;
	assign Wordline[4] = ~(RegId[0]) & ~(RegId[1]) & RegId[2] & ~(RegId[3]) & WriteReg; 
	assign Wordline[5] = RegId[0] & ~(RegId[1]) & RegId[2] & ~(RegId[3]) & WriteReg; 
	assign Wordline[6] = ~(RegId[0]) & RegId[1] & RegId[2] & ~(RegId[3]) & WriteReg; 
	assign Wordline[7] = RegId[0] & RegId[1] & RegId[2] & ~(RegId[3]) & WriteReg; 
	assign Wordline[8] = ~(RegId[0]) & ~(RegId[1]) & ~(RegId[2]) & RegId[3] & WriteReg; 
	assign Wordline[9] = RegId[0] & ~(RegId[1]) & ~(RegId[2]) & RegId[3] & WriteReg; 
	assign Wordline[10] = ~(RegId[0]) & RegId[1] & ~(RegId[2]) & RegId[3] & WriteReg; 
	assign Wordline[11] = RegId[0] & RegId[1] & ~(RegId[2]) & RegId[3] & WriteReg; 
	assign Wordline[12] = ~(RegId[0]) & ~(RegId[1]) & RegId[2] & RegId[3] & WriteReg; 
	assign Wordline[13] = RegId[0] & ~(RegId[1]) & RegId[2] & RegId[3] & WriteReg; 
	assign Wordline[14] = ~(RegId[0]) & RegId[1] & RegId[2] & RegId[3] & WriteReg; 
	assign Wordline[15] = RegId[0] & RegId[1] & RegId[2] & RegId[3] & WriteReg; 
endmodule

module Decoder_tb;
	reg [3:0] stim;
	reg option;
	wire [15:0] out1;
	wire [15:0] out2;

	ReadDecoder_4_16 TEST_R (.RegId(stim), .Wordline(out1));
	WriteDecoder_4_16 TEST_W (.RegId(stim), .WriteReg(option), .Wordline(out2));
	initial begin
		stim = 4'b0;
		option = 1'b0;
		repeat(100) begin
			#20 stim = $random;
			#0 option = $random;
		end
		#10;
	end

	initial $monitor("Input:%b Op:%b Output_R:%b Output_W:%b", stim, option, out1, out2); 
endmodule

module BitCell(input clk, input rst, input D, input WriteEnable, input ReadEnable1, input ReadEnable2, inout Bitline1, inout Bitline2);

	wire ff_out;
	dff FF (.q(ff_out), .d(D), .wen(WriteEnable), .clk(clk), .rst(rst));

	assign Bitline1 = ReadEnable1 ? ff_out : 1'bz;
	assign Bitline2 = ReadEnable2 ? ff_out : 1'bz;
endmodule

module BitCell_tb;
	reg write_val;
	reg write_en;
	reg read1_en;
	reg read2_en;
	reg clk;
	reg rst;

	wire out1;
	wire out2;

	BitCell TEST (.clk(clk), .rst(rst), .D(write_val), .WriteEnable(write_en), .ReadEnable1(read1_en), .ReadEnable2(read2_en), .Bitline1(out1), .Bitline2(out2));

	initial begin
		clk = 1'b0;
		repeat(100) begin
			#5 clk = ~clk;
		end
	end

	initial begin
		rst = 1'b1;
		write_val = 1'b0;
		read1_en = 1'b0;
		read2_en = 1'b0;
		write_en = 1'b0;
		repeat(100) begin
			#20 rst = 0;
			#0 write_val = $random;
			#0 read1_en = $random;
			#0 read2_en = $random;
			#0 write_en = $random;
		end
	end

	initial $monitor ("Clk:%b Rst:%b W_val:%b R1:%b R2:%b W:%b Out1:%b Out2:%b", clk, rst, write_val, read1_en, read2_en, write_en, out1, out2);
endmodule

module Register (input clk, input rst, input [15:0] D, input WriteReg, input ReadEnable1, input ReadEnable2, inout [15:0] Bitline1, inout [15:0] Bitline2);
	BitCell B0 (.clk(clk), .rst(rst), .D(D[0]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[0]), .Bitline2(Bitline2[0]));
	BitCell B1 (.clk(clk), .rst(rst), .D(D[1]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[1]), .Bitline2(Bitline2[1]));
	BitCell B2 (.clk(clk), .rst(rst), .D(D[2]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[2]), .Bitline2(Bitline2[2]));
	BitCell B3 (.clk(clk), .rst(rst), .D(D[3]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[3]), .Bitline2(Bitline2[3]));
	BitCell B4 (.clk(clk), .rst(rst), .D(D[4]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[4]), .Bitline2(Bitline2[4]));
	BitCell B5 (.clk(clk), .rst(rst), .D(D[5]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[5]), .Bitline2(Bitline2[5]));
	BitCell B6 (.clk(clk), .rst(rst), .D(D[6]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[6]), .Bitline2(Bitline2[6]));
	BitCell B7 (.clk(clk), .rst(rst), .D(D[7]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[7]), .Bitline2(Bitline2[7]));
	BitCell B8 (.clk(clk), .rst(rst), .D(D[8]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[8]), .Bitline2(Bitline2[8]));
	BitCell B9 (.clk(clk), .rst(rst), .D(D[9]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[9]), .Bitline2(Bitline2[9]));
	BitCell BA (.clk(clk), .rst(rst), .D(D[10]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[10]), .Bitline2(Bitline2[10]));
	BitCell BB (.clk(clk), .rst(rst), .D(D[11]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[11]), .Bitline2(Bitline2[11]));
	BitCell BC (.clk(clk), .rst(rst), .D(D[12]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[12]), .Bitline2(Bitline2[12]));
	BitCell BD (.clk(clk), .rst(rst), .D(D[13]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[13]), .Bitline2(Bitline2[13]));
	BitCell BE (.clk(clk), .rst(rst), .D(D[14]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[14]), .Bitline2(Bitline2[14]));
	BitCell BF (.clk(clk), .rst(rst), .D(D[15]), .WriteEnable(WriteReg), .ReadEnable1(ReadEnable1), .ReadEnable2(ReadEnable2), .Bitline1(Bitline1[15]), .Bitline2(Bitline2[15]));
endmodule

module RegisterFile (input clk, input rst, input [3:0] SrcReg1, input [3:0] SrcReg2, input [3:0] DstReg, input WriteReg, input [15:0] DstData, inout [15:0] SrcData1, inout [15:0] SrcData2);
	wire [15:0] DEC1, DEC2, WDEC, OUT1, OUT2;

	ReadDecoder_4_16 SRC1 (.RegId(SrcReg1), .Wordline(DEC1));
	ReadDecoder_4_16 SRC2 (.RegId(SrcReg2), .Wordline(DEC2));

	WriteDecoder_4_16 WR (.RegId(DstReg), .WriteReg(WriteReg), .Wordline(WDEC));

	Register R0 (.clk(clk), .rst(rst), .D(DstData), .WriteReg(WDEC[0]), .ReadEnable1(DEC1[0]), .ReadEnable2(DEC2[0]), .Bitline1(OUT1), .Bitline2(OUT2));
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
	wire select1, select2;

	//0 if equal, 1 else
	assign select1 = (SrcReg1[0] ^ DstReg[0]) | (SrcReg1[1] ^ DstReg[1]) | (SrcReg1[2] ^ DstReg[2]) | (SrcReg1[3] ^ DstReg[3]);
	assign select2 = (SrcReg2[0] ^ DstReg[0]) | (SrcReg2[1] ^ DstReg[1]) | (SrcReg2[2] ^ DstReg[2]) | (SrcReg2[3] ^ DstReg[3]);

	mux_2_1 DATA1 (.d0(DstData), .d1(OUT1), .s(select1), .b(SrcData1));
	mux_2_1 DATA2 (.d0(DstData), .d1(OUT2), .s(select2), .b(SrcData2));
endmodule
