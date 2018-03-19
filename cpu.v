module CPU(input clk, input rst_n, output hlt, output [15:0] pc); 
	wire[15:0] instr_out, instr_addr; 
	wire en, wr, nHalt; 

//	Register PC (.clk(clk), .rst(rst_n), .D(), .WriteReg(), .ReadEnable1(), .ReadEnable2(), .BitLine1(), .BitLine2());

	imemory Instr_Mem(.data_out(instr_out), .data_in(16'b0), .addr(instr_addr), .enable(nHalt), .wr(1'b0), .clk(clk), .rst(rst_n));
	assign hlt = ~(nHalt);

	wire rs_mux_s;
	wire [2:0] ccode;
	wire [3:0] opcode, rd, rs, rs_mux_o, rt, imm;
	wire [7:0] llb_lhb_offset;
	wire [8:0] br_offset;
	wire [15:0] imm_sign_ext, br_off_ext, lb_hb_off_ext;

	assign opcode = instr_out[15:12];

	assign rs_mux_s = opcode[3] & ~(opcode[2]) & opcode[1];
	mux2_1_4b rs_mux (.d0(instr_out[7:4]), .d1(instr_out[11:8]), .b(rs_mux_o), .s(rs_mux_s));

	assign rd = instr_out[11:8];
	assign rs = rs_mux_o;
	assign rt = instr_out[3:0];
	assign imm = instr_out[3:0];
	assign imm_sign_ext = {{12{instr_out[3]}}, imm};
	assign llb_lhb_offset = instr_out[7:0];
	assign lb_hb_off_ext = {{8{llb_lhb_offset[7]}}, llb_lhb_offset};
	assign ccode = instr_out[11:9];
	assign br_offset = instr_out[8:0];
	assign br_off_ext = {{7{br_offset[8]}}, br_offset};

	wire [15:0] reg_read_val_1, reg_read_val_2, dest_data;
	wire regWrite;
	assign regWrite = ~(opcode[3]) | ~(opcode[2]) | (opcode[1] & ~(opcode[0]));

	registerfile rf(.clk(clk), .rst(rst_n), .SrcReg1(rs), .SrcReg2(rt), .DstReg(rd), .WriteReg(regWrite), .DstData(dest_data), .SrcData1(reg_read_val_1), .SrcData2(reg_read_val_2));

	wire [15:0] LLB, LHB, LXX_o;
	assign LLB = (reg_read_val_1 & 16'b1111111100000000) | llb_lhb_offset;
	assign LHB = (reg_read_val_1 & 16'b0000000011111111) | (llb_lhb_offset << 8);
	assign LXX_o = opcode[0] ? LLB : LHB;

	wire alu_mux_s;
	wire [15:0] alu_mux_o, mem_addr, alu_data;
	wire [2:0] alu_flag;
	assign alu_mux_s = opcode[3] | (opcode[2] & ~(opcode[1])) | (opcode[2] & opcode[1] & ~(opcode[0]));
	mux2_1_16b alu_mux (.d0(reg_read_val_2), .d1(imm_sign_ext), .b(alu_mux_o), .s(alu_mux_s));

	alu_compute ALU(.InputA(reg_read_val_1), .InputB(alu_mux_o), .Opcode(opcode), .OutputA(mem_addr), .OutputB(alu_data), .Flag(alu_flag));
	
	wire [15:0] mem_out;
	wire mem_en, mem_wr;
	assign mem_en = opcode[3] & ~(opcode[2] | opcode[1]);
	assign mem_wr = opcode[3] & ~(opcode[2] | opcode[1]) & opcode[0];
	dmemory Data_Mem (.data_out(mem_out), .data_in(alu_data), .addr(mem_addr), .enable(mem_en), .wr(mem_wr), .clk(clk), .rst(rst_n));

	wire [15:0] rw_muxA_o;
	wire rw_muxA_s;
	assign rw_muxA_s = opcode[3] & ~(opcode[2] | opcode[1] | opcode[0]);
	mux2_1_16b regWrite_muxA (.d0(alu_data), .d1(mem_out), .b(rw_muxA_o), .s(rw_muxA_s));

	wire [15:0] rw_muxB_o;
	wire rw_muxB_s;
	assign rw_muxB_s = opcode[3] & opcode[2] & opcode[1] & ~(opcode[0]);
	mux2_1_16b regWrite_muxB (.d0(rw_muxA_o), .d1(/*PCS DATA*/), .b(rw_muxB_o), .s(rw_muxB_s));

	wire [15:0] rw_muxC_o;
	wire rw_muxC_s;
	assign rw_muxC_s = opcode[3] & ~(opcode[2]) & opcode[1];
	mux2_1_16b regWrite_muxC (.d0(rw_muxB_o), .d1(LXX_o), .b(rw_muxC_o), .s(rw_muxC_s));

	assign dest_data = rw_muxC_o;
endmodule
