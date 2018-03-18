module alu_compute_tb;
	reg [31:0] stim;
	reg [3:0] op;
	wire [15:0] addr, data;
	wire [2:0] flag;

	alu_compute TEST (stim[15:0], stim[31:16], op, addr, data, flag);

	initial begin
		stim = 32'b0;
		op = 4'b0;
		repeat(100) begin
			#10 stim = $random;
			#0 op = $random;
		end
		#10;
	end

	initial $monitor("A:%b B:%b Op:%b Addr:%b Data:%b Flag:%b", stim[15:0], stim[31:16], op, addr, data, flag);
endmodule
