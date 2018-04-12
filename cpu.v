module cpu(input clk, input rst_n, output hlt, output [15:0] pc_out);
	wire rst;
	assign rst = ~(rst_n);
 	wire[15:0] instr_out;
	wire[15:0] pc_curr;
	wire[15:0] pc_next;
	wire rs_mux_s, exmem_br;
	wire [2:0] ccode;
	wire [3:0] opcode, rd, rs, rs_mux_o, rt, imm;
	wire [7:0] llb_lhb_offset;
	wire [8:0] br_offset;
	wire [15:0] reg_read_val_1, reg_read_val_2, dest_data;
	wire [2:0] FLAG_o;
	wire [15:0] imm_sign_ext, lb_hb_off_ext;
	wire [15:0] pc_add_o;

	wire [3:0] memwb_op, idex_op;

	wire prempt_hlt;		// hlt when it arrives directly from imemory


	/*Hazard Unit Wires*/
	wire if_ex_memread, stall_n, write_pc, write_if_id_reg;

	add_16b PC_ADD (.a(pc_curr), .b(16'b0000000000000010), .cin(1'b0), .s(pc_add_o), .cout());

	wire [15:0] pc_mux_o, exmem_pc_next;
	// preemptive halt needs to stop the instruction memory queue at read
	assign prempt_hlt = &instr_out[15:12];
	// if we get a branch from exmem, give pc_next the branched value
	// elseif hlt is asserted, stick the PC at its original value
	// else, increment
	assign pc_mux_o = exmem_br ? exmem_pc_next :
													prempt_hlt ? pc_curr : pc_add_o;
	PC_register PC (.clk(clk), .rst(rst), .D(pc_mux_o), .WriteReg(write_pc),
										.ReadEnable1(1'b1), .ReadEnable2(1'b0), .Bitline1(pc_curr),
										.Bitline2());

	assign pc_out = pc_curr;
	imemory Instr_Mem(.data_out(instr_out), .data_in(16'b0), .addr(pc_curr),
											.enable(1'b1), .wr(1'b0), .clk(clk), .rst(rst));

	wire [15:0] ifid_pc, ifid_instr;

	if_id IFID (.clk(clk), .rst(rst), .hzrd(stall_n), .branch(exmem_br),
									.pc_i(pc_add_o), .instr_i(instr_out), .pc_o(ifid_pc),
									.instr_o(ifid_instr));

	assign if_ex_memread = idex_op[3] & ~(idex_op[2] | idex_op[1] | idex_op[0]);
	wire [3:0] idex_rt;
	Hazard_Detection HZRD (.IF_EX_MemRead(if_ex_memread),
													.ID_EX_RegisterRt(idex_rt), .IF_ID_RegisterRs(rs),
													.IF_ID_RegisterRt(rt), .stall_n(stall_n),
													.write_pc(write_pc),
													.write_IF_ID_reg(write_if_id_reg));

	assign opcode = ifid_instr[15:12];
	assign hlt = &memwb_op;

	assign rs_mux_s = opcode[3] & ~(opcode[2]) & opcode[1];
	mux2_1_4b rs_mux (.d0(ifid_instr[7:4]), .d1(ifid_instr[11:8]), .b(rs_mux_o), .s(rs_mux_s));

	wire rt_mux_s;
	/*If 1, rt should equal 0*/
	assign rt_mux_s = opcode[3] & ~(opcode[2]) & opcode[1];


	assign rd = ifid_instr[11:8];
	assign rs = rs_mux_o;
	assign rt = opcode[3] ? ifid_instr[11:8] : ifid_instr[3:0];
	assign imm = ifid_instr[3:0];
	assign imm_sign_ext = {{12{ifid_instr[3]}}, imm};
	assign llb_lhb_offset = ifid_instr[7:0];
	assign lb_hb_off_ext = {{8{llb_lhb_offset[7]}}, llb_lhb_offset};
	assign ccode = ifid_instr[11:9];
	assign br_offset = ifid_instr[8:0];

	wire [3:0] rt_o;
	assign rt_o = rt_mux_s ? 4'b0000 : rt;

	wire regWrite;
	assign regWrite = ~(memwb_op[3]) | ~(memwb_op[2]) | (memwb_op[1] & ~(memwb_op[0]));
	wire [3:0] memwb_rd;
	registerfile rf(.clk(clk), .rst(rst), .SrcReg1(rs), .SrcReg2(rt_o), .DstReg(memwb_rd),
											.WriteReg(regWrite), .DstData(dest_data), .SrcData1(reg_read_val_1),
											.SrcData2(reg_read_val_2));

	wire [15:0] LLB, LHB, LXX_o;
	assign LLB = (reg_read_val_1 & 16'b1111111100000000) | llb_lhb_offset;
	assign LHB = (reg_read_val_1 & 16'b0000000011111111) | (llb_lhb_offset << 8);
	assign LXX_o = opcode[0] ? LLB : LHB;

	wire imm_mux_s;
	assign imm_mux_s = rs_mux_s;
	wire [15:0] imm_mux_o;
	mux2_1_16b imm_mux (.d0(imm_sign_ext), .d1(LXX_o), .b(imm_mux_o), .s(imm_mux_s));

	wire [15:0] idex_rr1, idex_rr2, idex_pc, idex_imm;
	wire [8:0] idex_br_off;
	wire [3:0] idex_rs, idex_rd;
	wire [2:0] idex_ccode;

	id_ex IDEX(.reg_rd_1_i(reg_read_val_1), .reg_rd_2_i(reg_read_val_2),
								.pc_i(ifid_pc), .imm_i(imm_mux_o), .br_off_i(br_offset),
								.rs_i(rs), .rt_i(rt), .rd_i(rd), .op_i(opcode), .ccode_i(ccode),
								.hzrd(stall_n), .clk(clk), .rst(rst), .branch(exmem_br),
								.reg_rd_1_o(idex_rr1), .reg_rd_2_o(idex_rr2), .pc_o(idex_pc),
								.imm_o(idex_imm), .br_off_o(idex_br_off), .rs_o(idex_rs),
								.rt_o(idex_rt), .rd_o(idex_rd), .op_o(idex_op),
								.ccode_o(idex_ccode));

	wire [1:0] alu_mux_a, alu_mux_b;
	wire [3:0] exmem_op, exmem_rd;
	fwd_unit FWD (.exmem_op(exmem_op), .exmem_rd(exmem_rd), .memwb_op(memwb_op),
									.memwb_rd(memwb_rd), .idex_rs(idex_rs), .idex_rt(idex_rt),
									.fwdA(alu_mux_a), .fwdB(alu_mux_b));

	wire branch;
	PC_control PCC (.PC_in(idex_pc), .data(idex_rr1), .offset(idex_br_off),
											.op(idex_op), .C(idex_ccode), .F(FLAG_o), .PC_out(pc_next),
											.Branch(branch));

	// ALU inputs
	wire [15:0] alu_in_a, alu_in_b, memwb_ad, exmem_ad;
	assign alu_in_a = alu_mux_a == 2'b00 ? idex_rr1 :
												alu_mux_a == 2'b01 ? memwb_ad :
												alu_mux_a == 2'b10 ? exmem_ad : 16'hxxxx;
																				// xxxx should never happen. Only for debugging purposes.
	assign alu_in_b = alu_mux_b == 2'b00 ? idex_rr2 :
												alu_mux_b == 2'b01 ? memwb_ad :
												alu_mux_b == 2'b10 ? exmem_ad : 16'hxxxx;
																				// xxxx should never happen. Only for debugging purposes.

	wire [15:0] mem_addr, alu_data;
	wire [2:0] alu_flag;
	alu_compute ALU(.InputA(alu_in_a), .InputB(alu_in_b), .Offset(idex_imm),
											.Opcode(idex_op), .OutputA(mem_addr), .OutputB(alu_data),
											.Flag(alu_flag));


	FlagRegister FLAG (.clk(clk), .rst(rst), .D(alu_flag), .WriteReg(1'b1),
												.ReadEnable1(1'b1), .ReadEnable2(1'b0),
												.Bitline1(FLAG_o), .Bitline2());

	wire [15:0] exmem_ma, exmem_pc_curr, exmem_imm;
	wire [3:0] exmem_rs, exmem_rt;

	ex_mem EXMEM (.mem_addr_i(mem_addr), .alu_data_i(alu_data),
										.pc_curr_i(idex_pc), .pc_next_i(pc_next), .imm_i(idex_imm),
										.rs_i(idex_rs), .rt_i(idex_rt), .rd_i(idex_rd),
										.op_i(idex_op), .hzrd(stall_n), .clk(clk), .rst(rst),
										.branch(branch), .mem_addr_o(exmem_ma),
										.alu_data_o(exmem_ad), .pc_curr_o(exmem_pc_curr),
										.pc_next_o(exmem_pc_next), .imm_o(exmem_imm),
										.rs_o(exmem_rs), .rt_o(exmem_rt), .rd_o(exmem_rd),
										.op_o(exmem_op), .br_o(exmem_br));

	wire [15:0] mem_out;
	wire mem_en, mem_wr;
	assign mem_en = exmem_op[3] & ~(exmem_op[2] | exmem_op[1]);
	assign mem_wr = exmem_op[3] & ~(exmem_op[2] | exmem_op[1]) & exmem_op[0];
	dmemory Data_Mem (.data_out(mem_out), .data_in(exmem_ad), .addr(exmem_ma),
											.enable(mem_en), .wr(mem_wr), .clk(clk), .rst(rst));

	wire [15:0] memwb_md, memwb_pc, memwb_imm;
	wire [3:0] memwb_rs, memwb_rt;

	mem_wb MEMWB (.mem_data_i(mem_out), .alu_data_i(exmem_ad),
									.pc_i(exmem_pc_curr), .imm_i(exmem_imm), .rs_i(exmem_rs),
									.rt_i(exmem_rt), .rd_i(exmem_rd), .op_i(exmem_op),
									.hzrd(stall_n), .clk(clk), .rst(rst), .mem_data_o(memwb_md),
									.alu_data_o(memwb_ad), .pc_o(memwb_pc), .imm_o(memwb_imm),
									.rs_o(memwb_rs), .rt_o(memwb_rt), .rd_o(memwb_rd),
									.op_o(memwb_op));

	wire [15:0] rw_muxA_o;
	wire rw_muxA_s;
	assign rw_muxA_s = memwb_op[3] & ~(memwb_op[2] | memwb_op[1] | memwb_op[0]);
	mux2_1_16b regWrite_muxA (.d0(memwb_ad), .d1(memwb_md), .b(rw_muxA_o), .s(rw_muxA_s));

	wire [15:0] rw_muxB_o;
	wire rw_muxB_s;
	assign rw_muxB_s = memwb_op[3] & memwb_op[2] & memwb_op[1] & ~(memwb_op[0]);
	mux2_1_16b regWrite_muxB (.d0(rw_muxA_o), .d1(memwb_pc), .b(rw_muxB_o), .s(rw_muxB_s));

	wire [15:0] rw_muxC_o;
	wire rw_muxC_s;
	assign rw_muxC_s = memwb_op[3] & ~(memwb_op[2]) & memwb_op[1];
	mux2_1_16b regWrite_muxC (.d0(rw_muxB_o), .d1(memwb_imm), .b(rw_muxC_o), .s(rw_muxC_s));

	assign dest_data = rw_muxC_o;
endmodule
