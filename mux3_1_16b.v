module mux3_1_16b(d0, d1, d2, b, s);
	input [1:0] s;
	input [15:0] d0, d1, d2;
	output [15:0] b;

	reg [15:0] out;
	always @*case(s)
		2'b11 : out = 16'b0;
		2'b10 : out = d2;
		2'b01 : out = d1;
		2'b00 : out = d0;
		default: out = 0;
	endcase

	assign b = out;
endmodule
