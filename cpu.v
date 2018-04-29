// Notes:
// IATS: is annihilated this stage. Will not continue to pipeline register
// this usually means we need to process it this time instead of piping it.

`include "cpu.vh"

module cpu(input clk, input rst_n, output hlt, output [15:0] pc_out);

  //////////////////////////////////////////////////////////////////////////
  //////////////////////////////// F ///////////////////////////////////////
  wire
   pc_en,                // PC Write Enable. From hzd. // TODO
   i_fsm_busyF,          // fsm busy from iCache       // TODO
   branch_match,         // did the branch match the flags (& there's a br instr)
   vldF;                 // valid bit for noops        // TODO
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
      immD,                   // Could be shift or mem offset.
      pc_plus_2D;

   // signals meant for control unit
   wire
      reg_wrenD,            // write permissions to register
      mem_to_regD,          // memory read to register
      mem_wrD,              // memory write
      alu_srcD,             // imm or register 2
      dst_reg_selD,         // IATS    write to RT(0) or RD(1)
      branchD;              // IATS    is this a branch operation

   // TODO instantiate control unit here
   // TODO Finish control unit in control_unit.v
   // https://github.com/DTV96Calibre/pipelined-mips
   // Look here for what the signals are inspired from.
   /////////////////////////////
   //////////////////////////////

   // Signals meant for checking if branch should be taken
   wire
      cond_passD,              // IATS 1 if the flag reg meets the br conditions
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
      dst_reg_dataW;       // TODO
   registerfile reg(
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
   // TODO src_data_1D is a reg value. Reg values need to be forwarded
   assign br_pcD = src_data_1D;                       // TODO

   // choose between which branch
   // opcode[0] == 1 implies BR, otherwise B
   assign branch_pcD = opcodeD[0] ? br_pcD : b_pcD;

   /////////////////////////////// D ////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////////


   //////////////////////////////////////////////////////////////////////////
   /////////////////////////////// E ////////////////////////////////////////
   // sigs from the pipeline
   wire
    vldE;
   wire [3:0]
    opcodeE,               // IATS
    rdE,                   // IATS
    rsE,
    rtE,                   // IATS
    dst_regE;              // either rt or rd
   wire [15:0]
    src_data_1E,           // values from register
    src_data_2E,
    pc_plus_2E,
    immE;                  // IATS
   // control signals that may also be pipelined
   wire
      reg_wrenE,
      mem_to_regE,
      mem_wrE,
      alu_srcE,            // IATS
      dst_reg_selE;        // IATS

   // choose between rt and rd depending on ALU or mem operation
   assign dst_regE = dst_reg_selE ? rdE : rtE;

   // ALU input selection and output. Forwarded values here
   wire [15:0]
      fwd_AE,        // IATS     will be renamed as it goes to ALU
      fwd_BE,        // IATS     renamed as it goes to pipeline
      src_AE,        // IATS     input to ALU
      src_BE,        // IATS     input to ALU
      data_inE,      // What will be written to memory
      alu_outE;      // output of ALU
   wire [2:0]
      flagE;         // flag register output
   wire [1:0]
      fwd_A_selE,    // IATS     Signal from hazard unit // TODO
      fwd_B_selE;    // IATS     Signal from hazard unit // TODO

   assign fwd_AE = fwd_A_selE == 2'b10 ? dst_reg_dataW :
                   fwd_A_selE == 2'b01 ? alu_out_M :
                   fwd_A_selE == 2'b00 ? src_data_1E : 16'hXXXX;

   assign fwd_BE = fwd_B_selE == 2'b10 ? dst_reg_dataW :
                   fwd_B_selE == 2'b01 ? alu_outM :
                   fwd_B_selE == 2'b00 ? src_data_2E : 16'hXXXX;

   assign data_inE = fwd_BE;
   assign src_AE = fwd_AE;
   assign src_BE = alu_srcE ? immE : fwd_BE;    // selects imm or reg values

   // Create alu
   alu_compute alu(
      .input_A(src_AE),
      .input_B(src_BE),
      .out(alu_outE),
      .flag(flagE));





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
