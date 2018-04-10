module flag_tb(); 
	reg clk,rst, WriteReg, ReadEnable1,ReadEnable2; 
	reg[2:0] D; 
	wire [2:0] Bitline1, Bitline2;
	FlagRegister FDUT(.clk(clk),.rst(rst),.D(D),.WriteReg(WriteReg),.ReadEnable1(ReadEnable1),.ReadEnable2(ReadEnable2),.Bitline1(Bitline1),.Bitline2(Bitline2));
	initial begin
		clk = 0; 
		rst = 1;
	end 

	always begin 
		@(negedge clk); 
		rst = 0; 
		@(negedge clk); 
		D = 3'b111; 
		WriteReg = 1; 
		@(negedge clk); 
		ReadEnable1 = 1; 
		@(negedge clk); 
		ReadEnable2 = 1; 
		@(negedge clk); 
		D = 3'b110; 
		WriteReg = 1; 
		@(negedge clk); 
		ReadEnable1 = 1; 
		@(negedge clk); 
		ReadEnable2 = 1; 

		@(negedge clk); 
		
		@(negedge clk); 
		$stop;
		 
	end

	always begin 
		#5 clk = ~clk; 
	end

endmodule
