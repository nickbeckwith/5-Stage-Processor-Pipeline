module add_4b_tb;
	reg [8:0] stim;
	wire [3:0] s;
	wire pp, gg, cout;

	add_4b TEST (stim[3:0], stim[7:4], stim[8], s, pp, gg, cout);

	initial begin
		stim = 9'b0;
		repeat(100) begin
			#20 stim = $random;
		end
		#10;
	end

	initial $monitor("A:%b B:%b Cin:%b Out:%b P:%b G:%b", stim[3:0], stim[7:4], stim[8], s, pp, gg);
endmodule
