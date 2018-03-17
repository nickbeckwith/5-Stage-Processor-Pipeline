module paddsb_tb;
	typedef logic [3:0] word_t;
	// inputs
	logic [31:0]
		test_vector;
	word_t [3:0]			// creates an array of 4 words
		A, B;
	// output
	word_t [3:0]
		result;


	// iDUT INSTANTIATION
	paddsb iDUT (A, B, result);

	assign {A, B} = test_vector;
	initial begin
		test_vector = 32'b0;
		repeat(100) begin
			#5 test_vector = $random;
		end
		$display("Test complete.");
		$stop;
	end
endmodule
