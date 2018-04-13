`define ADD     4'b0000
`define SUB     4'b0001
`define RED     4'b0010
`define XOR     4'b0011
`define SLL     4'b0100
`define SRA     4'b0101
`define ROR     4'b0110
`define PADDSB  4'b0111
`define LW      4'b1000
`define SW      4'b1001
`define LHB     4'b1010
`define LLB     4'b1011
`define B       4'b1100
`define BR      4'b1101
`define PCS     4'b1110
`define HLT     4'b1111

module cpu(input clk, input rst_n, output hlt, output [15:0] pc_out);
	wire rst;
	assign rst = ~(rst_n);
 	wire[15:0] instr_out;
	wire[15:0] pc_curr;
	wire[15:0] pc_next;
	wire exmem_br;
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

	assign if_ex_memread = idex_op == `LW;
	wire [3:0] idex_rt;
	Hazard_Detection HZRD (.IF_EX_MemRead(if_ex_memread),
													.ID_EX_RegisterRt(idex_rt), .IF_ID_RegisterRs(rs),
													.IF_ID_RegisterRt(rt), .stall_n(stall_n),
													.write_pc(write_pc),
													.write_IF_ID_reg(write_if_id_reg));

	assign opcode = ifid_instr[15:12];
	assign hlt = memwb_op == `HLT;

	assign rs_mux_o = (opcode == `LHB) | (opcode == `LLB) ? ifid_instr[11:8] : ifid_instr[7:4];

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
	assign rt_o = (opcode == `LHB) | (opcode == `LLB) ? 4'b0000 : rt;

	wire regWrite;
	// probably should make this more readable in the future //
	// assign regWrite = ~(memwb_op[3]) | ~(memwb_op[2]) | (memwb_op[1] & ~(memwb_op[0]));
	assign regWrite = ~((memwb_op == `SW) | (memwb_op == `B) | (memwb_op == `BR) | (memwb_op == `HLT));
	wire [3:0] memwb_rd;
	registerfile rf(.clk(clk), .rst(rst), .SrcReg1(rs), .SrcReg2(rt_o), .DstReg(memwb_rd),
											.WriteReg(regWrite), .DstData(dest_data), .SrcData1(reg_read_val_1),
											.SrcData2(reg_read_val_2));

	wire [15:0] idex_rr1, idex_rr2, idex_pc, idex_imm, final_imm;
	wire [8:0] idex_br_off;
	wire [3:0] idex_rs, idex_rd;
	wire [2:0] idex_ccode;

	assign final_imm = opcode[1] ? lb_hb_off_ext : imm_sign_ext;

	id_ex IDEX(.reg_rd_1_i(reg_read_val_1), .reg_rd_2_i(reg_read_val_2),
								.pc_i(ifid_pc), .imm_i(final_imm), .br_off_i(br_offset),
								.rs_i(rs), .rt_i(rt), .rd_i(rd), .op_i(opcode), .ccode_i(ccode),
								.hzrd(1'b1), .clk(clk), .rst(rst), .branch(exmem_br),
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
	wire [15:0] alu_in_a, alu_in_b, memwb_ad, exmem_ad, memwb_fwd_data;
	assign alu_in_a = alu_mux_a == 2'b00 ? idex_rr1 :
												alu_mux_a == 2'b01 ? memwb_fwd_data :
												alu_mux_a == 2'b10 ? exmem_ad : exmem_ad;

	assign alu_in_b = alu_mux_b == 2'b00 ? idex_rr2 :
												alu_mux_b == 2'b01 ? memwb_fwd_data :
												alu_mux_b == 2'b10 ? exmem_ad : exmem_ad;


	wire [15:0] mem_addr, alu_data;
	wire [2:0] alu_flag;
	alu_compute ALU(.InputA(alu_in_a), .InputB(alu_in_b), .Offset(idex_imm),
											.Shift_Imm(idex_rt), .Opcode(idex_op), .OutputA(mem_addr), 
											.OutputB(alu_data), .Flag(alu_flag));

	wire [2:0] alu_flag_wrt_en;
	// if it's a mem write, RED or PADDSB, don't write to zero reg
	assign alu_flag_wrt_en[0] = idex_op[3] | (idex_op[2:0] == 3'b111) |
	 															(idex_op[2:0] == 3'b010) ? 1'b0 : 1'b1;

  assign alu_flag_wrt_en[2:1] = (idex_op == `ADD) | (idex_op == `SUB) ? 2'b11 : 2'b00;

	FlagRegister FLAG (.clk(clk), .rst(rst), .D(alu_flag), .WriteReg(alu_flag_wrt_en),
												.ReadEnable1(1'b1), .ReadEnable2(1'b0),
												.Bitline1(FLAG_o), .Bitline2());

	wire [15:0] exmem_ma, exmem_pc_curr, exmem_imm;
	wire [3:0] exmem_rs, exmem_rt;

	ex_mem EXMEM (.mem_addr_i(mem_addr), .alu_data_i(alu_data),
										.pc_curr_i(idex_pc), .pc_next_i(pc_next), .imm_i(idex_imm),
										.rs_i(idex_rs), .rt_i(idex_rt), .rd_i(idex_rd),
										.op_i(idex_op), .hzrd(1'b1), .clk(clk), .rst(rst),
										.branch(branch), .mem_addr_o(exmem_ma),
										.alu_data_o(exmem_ad), .pc_curr_o(exmem_pc_curr),
										.pc_next_o(exmem_pc_next), .imm_o(exmem_imm),
										.rs_o(exmem_rs), .rt_o(exmem_rt), .rd_o(exmem_rd),
										.op_o(exmem_op), .br_o(exmem_br));

	wire [15:0] mem_out;
	wire mem_en, mem_wr;
	assign mem_en = (exmem_op == `LW) | (exmem_op == `SW);
	assign mem_wr = exmem_op == `SW;
	dmemory Data_Mem (.data_out(mem_out), .data_in(exmem_ad), .addr(exmem_ma),
											.enable(mem_en), .wr(mem_wr), .clk(clk), .rst(rst));

	wire [15:0] memwb_md, memwb_pc, memwb_imm;
	wire [3:0] memwb_rs, memwb_rt;

	assign memwb_fwd_data = memwb_op == `LW ? memwb_md : memwb_ad;
	mem_wb MEMWB (.mem_data_i(mem_out), .alu_data_i(exmem_ad),
									.pc_i(exmem_pc_curr), .imm_i(exmem_imm), .rs_i(exmem_rs),
									.rt_i(exmem_rt), .rd_i(exmem_rd), .op_i(exmem_op),
									.hzrd(1'b1), .clk(clk), .rst(rst), .mem_data_o(memwb_md),
									.alu_data_o(memwb_ad), .pc_o(memwb_pc), .imm_o(memwb_imm),
									.rs_o(memwb_rs), .rt_o(memwb_rt), .rd_o(memwb_rd),
									.op_o(memwb_op));

	wire [15:0] rw_muxA_o;
	assign rw_muxA_o = memwb_op == `LW ? memwb_md : memwb_ad;

	wire [15:0] rw_muxB_o;
	assign rw_muxB_o = memwb_op == `PCS ? memwb_pc : rw_muxA_o;

	assign dest_data = rw_muxB_o;
endmodule
