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

	assign exmem_rw = ~(exmem_op[3]) | ~(exmem_op[2]) | (exmem_op[1] & ~(exmem_op[0]));
	assign memwb_rw = ~(memwb_op[3]) | ~(memwb_op[2]) | (memwb_op[1] & ~(memwb_op[0]));
	
	wire em_rs, em_rt, mw_rs, mw_rt;
	assign em_rs = ~(exmem_rd[3] ^ idex_rs[3]) & ~(exmem_rd[2] ^ idex_rs[2]) &  ~(exmem_rd[1] ^ idex_rs[1]) & ~(exmem_rd[0] ^ idex_rs[0]);
	assign em_rt = ~(exmem_rd[3] ^ idex_rt[3]) & ~(exmem_rd[2] ^ idex_rt[2]) &  ~(exmem_rd[1] ^ idex_rt[1]) & ~(exmem_rd[0] ^ idex_rt[0]);
	assign mw_rs = ~(memwb_rd[3] ^ idex_rs[3]) & ~(memwb_rd[2] ^ idex_rs[2]) &  ~(memwb_rd[1] ^ idex_rs[1]) & ~(memwb_rd[0] ^ idex_rs[0]);
	assign mw_rt = ~(memwb_rd[3] ^ idex_rt[3]) & ~(memwb_rd[2] ^ idex_rt[2]) &  ~(memwb_rd[1] ^ idex_rt[1]) & ~(memwb_rd[0] ^ idex_rt[0]);
	
	wire exmem_a, exmem_b, memwb_a, memwb_b;

	assign exmem_a = (exmem_rw & (exmem_rd | 4'b0000) & em_rs);
	assign exmem_b = (exmem_rw & (exmem_rd | 4'b0000) & em_rt);
	assign memwb_a = (memwb_rw & (memwb_rd | 4'b0000) & mw_rs);
	assign memwb_b = (memwb_rw & (memwb_rd | 4'b0000) & mw_rt);

	assign fwdA[1] = exmem_a;
	assign fwdB[1] = exmem_b;

	assign fwdA[0] = memwb_a;
	assign fwdB[0] = memwb_b;
endmodule
