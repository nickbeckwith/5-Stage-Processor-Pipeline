b_pcDIATS// Notes:
// IATS: is annihilated this stage. Will not continue to pipeline register
// this usually means we need to process it this time instead of piping it.

`include "cpu.vh"

module cpu(input clk, input rst_n, output hlt, output [15:0] pc_out);

  //////////////////////////////////////////////////////////////////////////
  //////////////////////////////// F ///////////////////////////////////////
  wire
    pc_en,                // PC Write Enable. Connected to stall from hazard
    i_fsm_busyF,          // fsm busy from iCache
    branch_match,         // did the branch match the flags (& there's a br instr)
    vldF;                 // valid bit for noops
  wire [15:0]
    pc_curr,              // PC value that comes from pc reg
    pc_nxt,               // PC value loaded into pc reg
    pc_plus_2F,           // PC value plus 2
    instrF,               // instruction out from iCache
    branch_pcD;           // IATS      Next pc if there's a branch

  // Determine next PC depending on if there's a branch
  assign pc_nxt = branch_match ? branch_pcD : pc_plus_2F;

  PC_register PC(.clk(clk), .rst(rst), .wen(pc_en), .d(pc_nxt), .q(pc_curr));

  assign pc_out = pc_curr;          // readability
  assign instrF = main_mem_out;     // value from the main memory

  add_16b add2(.a(pc_curr), .b(16'd2), .cin(1'b0), .s(pc_plus_2F), .cout());
  /////////////////////////////// IF ///////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////
  /////////////////////////////// D ////////////////////////////////////////
  // pipeline sigs and more
  wire
   vldD;
  wire [2:0]
   br_codeD;               // IATS     also works for B instruction
  wire [3:0]
   opcodeD,
   rdD,
   rsD,
   rtD;
  wire [8:0]
   br_offD;                // IATS
  wire [15:0]
   instrD,                 // IATS
   immD,
   pc_plus_2D;

   // signals meant for control unit
   wire
      reg_wrenD,            // write permissions to register
      mem_to_regD,          // memory read to register
      mem_wrD,              // memory write
      alu_srcD,             // imm or register 2
      reg_dstD,             // which register to write to (mem or alu op reg)
      branchD;              // IATS    is this a branch operation

   // TODO instantiate control unit here
   // TODO Finish control unit in control_unit.v
   // https://github.com/DTV96Calibre/pipelined-mips
   // Look here for what the signals are inspired from.
   /////////////////////////////
   //////////////////////////////

   // Signals meant for checking if branch should be taken
   wire
      cond_passD,             // IATS 1 if the flag reg meets the br conditions
      branch_matchD;           // cond match and branch

   // TODO Create flag_check module that outputs cond_passD
   // might want to look in old Pc_control i think?
   // Condition passD is 1 if the flag reg meets the conditions to branchD
   /////////////////////////////
   //////////////////////////////
   assign branch_matchD = branchD & cond_passD;

   // instantiate register and signals needed possibly from WB
   wire
      reg_wenW;
   wire [3:0]
      dst_regW;
   wire [15:0]
      src_data_1D,
      src_data_2D,
      reg_dst_dataW;
   registerfile reg(
      .clk(clk),
      .rst(rst),
      .SrcReg1(rsD),
      .SrcReg2(rtD),
      .DstReg(dst_regW),
      .WriteReg(reg_wenW),
      .DstData(reg_dst_dataW),
      .SrcData1(src_data_1D),
      .SrcData2(src_data_2D));

   // decode instruction
   assign opcodeD = instrD[15:12];
   assign rdD = instrD[11:8];
   assign rsD = instrD[7:4];
   assign rtD = opcodeD[3] ? instrD[11:8] : instrD[3:0];
   assign immD = opcodeD[1] ?
            {{8{instrD[7]}}, instrD[7:0]} : {{12{instrD[3]}}, instrD[3:0]};
   assign br_codeD = instrD[11:9];
   assign br_offD = instrD[8:0];

   // B and Br PC Cacluations and choosing one to send to PC.
   wire [15:0]
      b_off_extD,            // IATS      sign extended and shifted
      b_pcD,                 // IATS      = PC + 2 + (br_offD << 1). assumes br
      br_pcD;                // IATS      = $(RS)

   // create br_off_ext and br_pc as above
   assign b_off_extD = {{7{b_offD[8]}}, b_offD} << 1;
   add16b br_pc(.a(b_off_extD), .b(pc_plus_2D), .cin(1'b0), .s(b_pcD), .cout());

   // For readability, want to get br_pc as well
   assign br_pcD = src_data_1D;

   // choose between which branch
   // opcode[0] == 1 implies BR, otherwise B
   assign branch_pcD = opcodeD[0] ? br_pcD : b_pcD;

   /////////////////////////////// D ////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////////


   //////////////////////////////////////////////////////////////////////////
   /////////////////////////////// E ////////////////////////////////////////
   // pipeline sigs
   wire
    vldE;
   wire [3:0]
    opcodeE,               // IATS
    rdE,
    rsE,                   // IATS
    rtE;                   // IATS
   wire [8:0]
   wire [15:0]
    immE,                  // IATS
   // control signals that may also be pipelined
   wire
      reg_wrenE,
      mem_to_regE,
      mem_wrE,
      reg_dstE,
      branchE;             // annihilated
   /////////////////////////////// E ////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////////

   //////////////////////////////////////////////////////////////////////////
   /////////////////////////////// M ////////////////////////////////////////

   /////////////////////////////// M ////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////////

   //////////////////////////////////////////////////////////////////////////
   /////////////////////////////// W ////////////////////////////////////////

   /////////////////////////////// W ////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////////

   //////////////////////////////////////////////////////////////////////////
   /////////////////////////// mem module ///////////////////////////////////
   memory memory(
      .clk(clk),
      .rst(rst),
      .d_wrt_en(),
      .data_in(),
      .i_addr(pc_curr),
      .d_addr(),
      .i_fsm_busy(i_fsm_busyF),
      .d_fsm_busy(),
      .d_mem_en(),
      .instr_out(instrF),
      .data_out(main_mem_out);
      )

endmodule
