module red_tb;
	reg [31:0] stim;
	wire [15:0] out;

	red TEST (stim[31:16], stim[15:0], out);

	initial begin
		stim = {4{8'b00000111}};
		repeat(10) begin
			#20 stim = $random;
		end
		#10;
	end
	
	initial $monitor("A:%b B:%b C:%b D:%b E:%b F:%b G:%b H:%b Out:%b", stim[31:28], stim[27:24], stim[23:20], stim[19:16], stim[15:12], stim[11:8], stim[7:4], stim[3:0], out);
		
endmodule
