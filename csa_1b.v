module csa_1b(A, B, Ci, S, Co);
	input A, B, Ci;
	output S, Co;

	assign S = A ^ B ^ Ci;
	assign Co = (A & B) | (A & Ci) | (B & Ci);
endmodule
