module mux2_1_16b(d0, d1, b, s);
	input s;
	input [15:0] d0, d1;
	output [15:0] b;

	reg [15:0] out;
	always @*case(s)
		1'b1 : out = d1;
		1'b0 : out = d0;
	endcase
	
	assign b = out;
endmodule
