module sll_tb;
	reg [15:0] value;
	reg [3:0] shift;
	wire [15:0] result;

	sll TEST (result, value, shift);

	initial begin
		value = 16'b0;
		shift = 4'b0;
		repeat(100) begin
			#20 value = $random;
			#0 shift = $random;
		end
		#10;
	end
	
	initial $monitor("In:%b Shift:%b Out:%b", value, shift, result);

endmodule

