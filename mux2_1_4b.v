module mux2_1_4b(d0, d1, b, s);
	input s;
	input [3:0] d0, d1;
	output [3:0] b;

	reg [3:0] out;
	always @*case(s)
		1'b1 : out = d1;
		1'b0 : out = d0;
	endcase
	
	assign b = out;
endmodule
