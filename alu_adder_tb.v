module alu_adder_tb;
	reg [32:0] stim;
	wire [15:0] s;
	wire n, v, z;

	alu_adder TEST (stim[32], stim[31:16], stim[15:0], s, n, v, z);

	initial begin
		stim = 33'b0;
		repeat(100) begin
			#20 stim = $random;
		end
		#10;
	end

	initial $monitor("A:%b B:%b Out:%b Mod:%b N:%b V:%b Z:%b", stim[31:16], stim[15:0], s, stim[32], n, v, z);
endmodule
