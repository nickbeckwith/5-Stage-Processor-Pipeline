module fwd_unit (exmem_op, exmem_rd, memwb_op, memwb_rd, idex_rs, idex_rt, fwdA, fwdB);
	input [3:0]
		exmem_op,	// Used to get EX/MEM.RegWrite
		exmem_rd,	// EX/MEM.RegisterRd

		memwb_op,	// Used to get MEM/WB.RegWrite
		memwb_rd,	// MEM/WB.RegisterRd

		idex_rs,	// ID/EX.RegisterRs
		idex_rt;	// ID/EX.RegisterRt

	output [1:0]
		fwdA,		// ForwardA - Drives mux for ALU Input A
		fwdB;		// ForwardB - Drives mux for ALU Input B

	wire exmem_rw, memwb_rw;

	assign exmem_rw = 1;
	assign memwb_rw = 1;

	wire em_rs, em_rt, mw_rs, mw_rt;
	assign em_rs = exmem_rd == idex_rs;
	assign em_rt = exmem_rd == idex_rt;
	assign mw_rs = memwb_rd == idex_rs;
	assign mw_rt = memwb_rd == idex_rt;

	wire exmem_a, exmem_b, memwb_a, memwb_b;

	assign exmem_a = (exmem_rw & em_rs);
	assign exmem_b = (exmem_rw & em_rt);
  assign memwb_a = (memwb_rw & mw_rs);
  assign memwb_b = (memwb_rw & mw_rt);

	assign fwdA[1] = exmem_a;
	assign fwdB[1] = exmem_b;

	assign fwdA[0] = memwb_a;
	assign fwdB[0] = memwb_b;
endmodule
