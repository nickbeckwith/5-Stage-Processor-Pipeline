module cla_unit(Pi, Gi, Ci, Po, Go, Co);
	input [3:0] Pi, Gi;
	input Ci;
	output [4:1] Co;
	output Po, Go;

	assign Co[1] = Gi[0] | Pi[0] & Ci;
	assign Co[2] = Gi[1] | Pi[1] & Gi[0] | Pi[1] & Pi[0] & Ci;
	assign Co[3] = Gi[2] | Pi[2] & Gi[1] | Pi[2] & Pi[1] & Gi[0] | Pi[2] & Pi[1] & Pi[0] & Ci;
	assign Co[4] = Gi[3] | Pi[3] * Gi[2] | Pi[3] & Pi[2] & Gi[1] | Pi[3] & Pi[2] & Pi[1] & Gi[0] | Pi[3] & Pi[2] & Pi[1] & Pi[0] & Ci;

	assign Po = Pi[0] * Pi[1] * Pi[2] * Pi[3];
	assign Go = Gi[3] | Pi[3] * Gi[2] | Pi[3] * Pi[2] * Gi[1] | Pi[3] * Pi[2] * Pi[1] * Gi[0];
endmodule
