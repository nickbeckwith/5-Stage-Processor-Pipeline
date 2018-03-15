module add_16b_tb;
	reg [32:0] stim;
	wire [15:0] s;
	wire cout;

	add_16b TEST (stim[31:16], stim[15:0], stim[32], s, cout);

	initial begin
		stim = 16'b0;
		repeat(100) begin
			#20 stim = $random;
		end
		#10;
	end

	initial $monitor("A:%d B:%d Cin:%b Out:%d Cout:%b", stim[31:16], stim[15:0], stim[32], s, cout);
endmodule
