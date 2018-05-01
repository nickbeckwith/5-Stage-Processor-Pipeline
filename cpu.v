// Notes
// IATS: is annihilated this stage. Will not continue to pipeline register
// this usually means we need to process it this time instead of piping it.

`include "cpu.vh"

module cpu(input clk, input rst_n, output hlt, output [15:0] pc_out);
// we active high rst in the core
wire rst;
assign rst = ~rst_n;
  //////////////////////////////////////////////////////////////////////////
  //////////////////////////////Hazard Unit/////////////////////////////////
  ///////////////// wires for HZRD//////////////////////////
  wire [1:0]
   forward_B_selE,
   forward_A_selE,
   forwardD;
  wire
   stallF,
   stallD,
   stallE,
   flushD,
   branch_matchD,     // cond match and branch
   reg_wrenE,
   mem_to_regE,
   reg_wrenM,
   i_fsm_busy,
   d_fsm_busy,
   mem_to_regM;
  wire [3:0]
   rdD,
   rsD,
   rtD,
   dst_regW,
   rsE,
   rtE,                   // IATS
   dst_regE,              // either rt or rd
   dst_regM;      // destination register name still

  hazard HZRD (
    .branch_matchD(branch_matchD),
    .i_fsm_busy(i_fsm_busy),
    .d_fsm_busy(d_fsm_busy),
    .mem_to_regE(mem_to_regE),
    .mem_to_regM(mem_to_regM),
    .reg_wrenE(reg_wrenE),
    .reg_wrenM(reg_wrenM),
    .reg_wrenW(reg_wrenM),
    .dst_regE(dst_regE),
    .dst_regM(dst_regM),
    .dst_regW(dst_regW),
    .rsD(rsD),
    .rtD(rtD),
    .rsE(rsE),
    .rtE(rtE),
    .stallF(stallF),
    .stallD(stallD),
    .stallE(stallE),
    .flushD(flushD),
    .forwardD(forwardD),
    .forward_A_selE(forward_A_selE),
    .forward_B_selE(forward_B_selE)
  );
  //////////////////////////////Hazard Unit/////////////////////////////////
  //////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////
  //////////////////////////////// F ///////////////////////////////////////
  wire
   pc_en,                // PC Write Enable. From hzd. AKA StallF
   branch_match,         // did the branch match the flags (& there's a br instr)
   haltF,                 // halt signal makes pc_nxt = pc_curr
   vldF;                 // valid bit for noops
  wire [15:0]
   pc_curr,              // PC value that comes from pc reg
   pc_nxt,               // PC value loaded into pc reg
   pc_plus_2F,           // PC value plus 2
   instrF,               // instruction out from iCache
   main_mem_outM,        // main mem out
   branch_pcD;           // IATS      Next pc if there's a branch

  // Determine next PC depending on if there's a branch
  // If there's a halt, branch takes priority
  assign pc_nxt =
                  branch_match ? branch_pcD :
                  haltF ? pc_curr : pc_plus_2F;

  assign pc_en = ~(stallF);
  PC_register PC(.clk(clk), .rst(rst), .wen(pc_en), .d(pc_nxt), .q(pc_curr));
  /* the only valid instructions are ones that come from
  instrF. Clearing an instruction creates an instructions
  of itself but isn't valid. */
  assign vldF = 1'b1;
  assign pc_out = pc_curr;           // readability
  assign instrF = main_mem_outM;     // value from the main memory
  assign haltF = &instrF[15:12];     // find halt value

  add_16b add2(.a(pc_curr), .b(16'd2), .cin(1'b0), .s(pc_plus_2F), .cout());

  //Pipeline Time
  wire [32:0] if_id_in, if_id_out;
  assign if_id_in = {
      vldF,
      haltF,
      instrF,
      pc_plus_2F
  };
  /////////////////////////////// IF ///////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////
   // ID/ED pipelineregisteer
   pipeline_reg #(33) if_id(
      .clk(clk),
      .rst(rst),
      .clr(flushD),	   // branch_match | i_fsm_busy
      .wren(~stallD),	// StallD
      .d(if_id_in),
      .q(if_id_out)
   );
  //////////////////////////////////////////////////////////////////////////
  /////////////////////////////// D ////////////////////////////////////////
  // pipeline sigs and more
  wire
      vldD,
      haltD;
  wire [2:0]
      b_codeD,               // IATS     also works for B instruction
      flagE;                  // flag register output
  wire [3:0]
      opcodeD,
      opcodeE;               // IATS
  wire [8:0]
      b_offD;                // IATS
  wire [15:0]
      instrD,                 // IATS
      immD,                   // Could be shift or mem offset.
      alu_outE,               // output of ALU
      alu_outM,               // this can also be an address
      pc_plus_2D;

   //Assign Pipeline Values
   assign {
      vldD,
      haltD,
      instrD,
      pc_plus_2D
   } = if_id_out;

   // Control unit and signals
   wire
      reg_wrenD,            // write permissions to register
      mem_to_regD,          // memory read to register
      mem_wrD,              // memory write
      alu_srcD,             // imm or register 2
      dst_reg_selD,         // IATS    write to RT(0) or RD(1)
      branchD;              // IATS    is this a branch operation
   control_unit ControlUnit(
      .opcode(opcodeD),
      .reg_wren(reg_wrenD),
      .mem_to_reg(mem_to_regD),
      .mem_wr(mem_wrD),
      .alu_src(alu_srcD),
      .dst_reg_sel(dst_reg_selD),
      .branch(branchD)
   );

   // instantiate register and signals needed possibly from WB
   wire
      reg_wenW;
   wire [15:0]
      src_data_1D,
      src_data_2D,
      dst_reg_dataW;
   registerfile register(
      .clk(clk),
      .rst(rst),
      .SrcReg1(rsD),
      .SrcReg2(rtD),
      .DstReg(dst_regW),
      .WriteReg(reg_wenW),
      .DstData(dst_reg_dataW),
      .SrcData1(src_data_1D),
      .SrcData2(src_data_2D));

   // decode instruction
   assign opcodeD = instrD[15:12];
   assign rdD = instrD[11:8];
   assign rsD = (opcodeD == `LHB) | (opcodeD == `LLB) ? instrD[11:8] : instrD[7:4];
   assign rtD = opcodeD[3] ? instrD[11:8] : instrD[3:0];
   // Remember to reference only the first 4 LSB bits if you want shift amount
   assign immD = opcodeD[1] ?
            {{8{instrD[7]}}, instrD[7:0]} : {{12{1'b0}}, instrD[3:0]};
   assign b_codeD = instrD[11:9];
   assign b_offD = instrD[8:0];

   // B and Br PC Cacluations and choosing one to send to PC.
   wire [15:0]
      b_off_extD,            // IATS      sign extended and shifted
      b_pcD,                 // IATS      = PC + 2 + (b_offD << 1). assumes br
      br_pcD;                // IATS      = $(RS)

   // Signals meant for checking if branch should be taken
   wire
      cond_passD;              // IATS 1 if the flag reg meets the br conditions
   flag_check Flag_Check(.C(b_codeD), .flag(flagE), .cond_passD(cond_passD));

   // branch_matchD determines if branching will occur
   assign branch_matchD = branchD & cond_passD;

   // create br_off_ext and br_pc as above
   assign b_off_extD = {{7{b_offD[8]}}, b_offD} << 1;
   add_16b br_pc(.a(b_off_extD), .b(pc_plus_2D), .cin(1'b0), .s(b_pcD), .cout());

   // For readability, want to get br_pc as well
   // src_data_1D is a reg value. Reg values need to be forwarded
   assign br_pcD =
                     forwardD == 2'b00 ? src_data_1D :
                     forwardD == 2'b01 ? alu_outE :
                     forwardD == 2'b10 ? alu_outM : dst_reg_dataW;

   // choose between which branch
   // opcode[0] == 1 implies BR, otherwise B
   assign branch_pcD = opcodeD[0] ? br_pcD : b_pcD;

   //Pipeline Time
   wire [75:0] id_ex_in, id_ex_out;
   assign id_ex_in = {
      vldD,
      haltD,
      reg_wrenD,
      mem_to_regD,
      mem_wrD,
      opcodeD,
      alu_srcD,
      dst_reg_selD,
      (opcodeE == `PCS) ? pc_plus_2D : src_data_1D,   // in case of PCS instruction
      src_data_2D,                                    // we want to get pc+2 into the
      rdD,                                            // reg wr data path
      rsD,
      rtD,
      immD
   };
   /////////////////////////////// D ////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////////
   // ID/EX pipelineregisteer
   pipeline_reg #(76) id_ex(
      .clk(clk),
      .rst(rst),
      .clr(vldD),
      .wren(~stallE),      // only occurs from d_fsm_busy
      .d(id_ex_in),
      .q(id_ex_out));
   //////////////////////////////////////////////////////////////////////////
   /////////////////////////////// E ////////////////////////////////////////
   // sigs from the pipeline
   wire
    vldE,
    haltE;
   wire [3:0]
    rdE;                   // IATS
   wire [15:0]
    src_data_1E,           // values from register
    src_data_2E,
    immE;                  // IATS
   // control signals that may also be pipelined
   wire
      mem_wrE,
      alu_srcE,            // IATS
      dst_reg_selE;        // IATS

   //Assign values from pipeline
   assign {
      vldE,
      haltE,
      reg_wrenE,
      mem_to_regE,
      mem_wrE,
      opcodeE,
      alu_srcE,
      dst_reg_selE,
      src_data_1E,
      src_data2E,
      rdE,
      rsE,
      rtE,
      immE
   } = id_ex_out;

   // choose between rt and rd depending on ALU or mem operation
   assign dst_regE = dst_reg_selE ? rdE : rtE;

   // ALU input selection and output. Forwarded values here
   wire [15:0]
      fwd_AE,        // IATS     will be renamed as it goes to ALU
      fwd_BE,        // IATS     renamed as it goes to pipeline
      src_AE,        // IATS     input to ALU
      src_BE,        // IATS     input to ALU
      data_inE;      // What will be written to memory
   wire [1:0]
      fwd_A_selE,    // IATS     Signal from hazard unit
      fwd_B_selE;    // IATS     Signal from hazard unit

   assign fwd_AE = fwd_A_selE == 2'b10 ? dst_reg_dataW :
                   fwd_A_selE == 2'b01 ? alu_outM :
                   fwd_A_selE == 2'b00 ? src_data_1E : 16'hXXXX;

   assign fwd_BE = fwd_B_selE == 2'b10 ? dst_reg_dataW :
                   fwd_B_selE == 2'b01 ? alu_outM :
                   fwd_B_selE == 2'b00 ? src_data_2E : 16'hXXXX;

   assign data_inE = fwd_BE;                    // requested data to wr to mem
   assign src_AE = fwd_AE;
   assign src_BE = alu_srcE ? immE : fwd_BE;    // selects imm or reg values

   // Create alu
   alu_compute alu(
      .input_A(src_AE),
      .input_B(src_BE),
      .opcode(opcodeE),
      .vld(vldE),
      .out(alu_outE),
      .flag(flagE));

   //Pipeline Time
   wire [39:0] ex_mem_in, ex_mem_out;
   assign ex_mem_in = {
      vldE,
      haltE,
      reg_wrenE,
      mem_to_regE,
      mem_wrE,
      dst_regE,
      alu_outE,
      data_inE
   };
   /////////////////////////////// E ////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////////
   // EX/MEM pipeline registeer
   pipeline_reg #(40) ex_mem(
      .clk(clk),
      .rst(rst),
      .clr(vldE),	// VldE
      .wren(stallE),	// stallE is caused from data cache miss
      .d(ex_mem_in),
      .q(ex_mem_out));
   //////////////////////////////////////////////////////////////////////////
   /////////////////////////////// M ////////////////////////////////////////
   // pipeline values coming in
   wire
      vldM,
      haltM,
      mem_wrM;       // IATS
   wire [15:0]
      data_inM;      // IATS data to data memory

   //Assign values from pipeline
   assign {
      vldM,
      haltM,
      reg_wrenM,
      mem_to_regM,
      mem_wrm,
      dst_regM,
      alu_outM,
      data_inM
   } = ex_mem_out;

   // pipeline time
   wire [54:0] mem_wb_in, mem_wb_out;
   assign mem_wb_in = {
      vldM,
      reg_wrenM,
      mem_to_regM,
      dst_regM,
      alu_outM,
      data_inM,
      main_mem_outM
   };
   /////////////////////////////// M ////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////////
   // Mem/WB pipeline register
   pipeline_reg #(55) mem_wb( // 55 comes from the size of concatanation
      .clk(clk),
      .rst(rst),
      .clr(vldM),       // VldM
      .wren(1'b1),      // Always High, No Data Hzrds to worry about
      .d(mem_wb_in),
      .q(mem_wb_out));
   //////////////////////////////////////////////////////////////////////////
   /////////////////////////////// W ////////////////////////////////////////
   // pipeline and assigning
   wire
      vldW,
      haltW,
      reg_wrenW,     // IATS
      mem_to_regW;   // IATS
   wire [15:0]
      main_mem_outW, // IATS
      alu_outW;
   assign {          // remember to change these to W when copying over.
         vldW,
         haltW,
         reg_wrenW,
         mem_to_regW,
         dst_regW,
         alu_outW,
         data_inW,
         main_mem_outW
      } = mem_wb_out;

   // choose between memory and alu out
   assign dst_reg_dataW = mem_to_regW ? main_mem_outW : alu_outW;
   // Need to tell test bench we halted now
   assign hlt = haltW;
   /////////////////////////////// W ////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////////

   //////////////////////////////////////////////////////////////////////////
   /////////////////////////// mem module ///////////////////////////////////
   memory memory(
      .clk(clk),
      .rst(rst),
      .d_wrt_en(mem_wrM),
      .data_in(data_inM),
      .i_addr(pc_curr),
      .d_addr(alu_outM),
      .i_fsm_busy(i_fsm_busy),
      .d_fsm_busy(d_fsm_busy),
      .d_mem_en(mem_to_regM | mem_wrM),
      .instr_out(instrF),
      .data_out(main_mem_outM));

endmodule
