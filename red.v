module red(InputA, InputB, Output);
	input [15:0] InputA, InputB;
	output [15:0] Output;
	
	wire [6:0] c;
	wire [15:0] sa;
	wire [7:0] sb;
	wire[1:0] sc, sd, se, sf;

	add_4b A0 (.a(InputA[3:0]), .b(InputB[3:0]), .cin(1'b0), .s(sa[3:0]), .cout(c[0]));
	add_4b A1 (.a(InputA[7:4]), .b(InputB[7:4]), .cin(1'b0), .s(sa[7:4]), .cout(c[1]));
	add_4b A2 (.a(InputA[11:8]), .b(InputB[11:8]), .cin(1'b0), .s(sa[11:8]), .cout(c[2]));
	add_4b A3 (.a(InputA[15:12]), .b(InputB[15:12]), .cin(1'b0), .s(sa[15:12]), .cout(c[3]));

	add_4b B0 (.a(sa[3:0]), .b(sa[7:4]), .cin(1'b0), .s(sb[3:0]), .cout(c[4]));
	add_4b B1 (.a(sa[11:8]), .b(sa[15:12]), .cin(1'b0), .s(sb[7:4]), .cout(c[5]));

	add_4b C0 (.a(sb[3:0]), .b(sb[7:4]), .cin(1'b0), .s(Output[3:0]), .cout(c[6]));

	csa_1b D0 (c[0], c[1], c[2], sc[0], sc[1]);
	csa_1b D1 (c[3], c[4], c[5], sd[0], sd[1]);
	csa_1b D2 (c[6], sd[0], sc[0], Output[4], se[1]);
	csa_1b D3 (sd[1], sc[1], se[1], Output[5], Output[6]);

	assign Output[15:7] = {8{Output[6]}};
endmodule
