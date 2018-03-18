module mux8_1_16b(d0, d1, d2, d3, d4, d5, d6, d7, b, s);
	input [2:0] s;
	input [15:0] d0, d1, d2, d3, d4, d5, d6, d7;
	output [15:0] b;

	reg [15:0] out;
	always @*case(s)
		3'b111 : out = d7;
		3'b110 : out = d6;
		3'b101 : out = d5;
		3'b100 : out = d4;
		3'b011 : out = d3;
		3'b010 : out = d2;
		3'b001 : out = d1;
		3'b000 : out = d0;
	endcase
	
	assign b = out;
endmodule
