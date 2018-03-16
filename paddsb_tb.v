module paddsb_tb;
	reg [31:0] value;
	wire [3:0] test_V;
	wire [15:0] result;
	
	paddsb TEST (value[31:16], value[15:0], result, test_V);

	initial begin
		value = 32'b0;
		repeat(100) begin
			#100 value = $random;
		end
		#10;
	end

	initial $monitor("A:%b B:%b C:%b D:%b E:%b F:%b G:%b H:%b Out:%b V:%b", value[31:28], value[27:24], value[23:20], value[19:16], value[15:12], value[11:8], value[7:4], value[3:0], result, test_V);
endmodule
