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
