`include "cpu.vh"

module cpu(input clk, input rst_n, output hlt, output [15:0] pc_out);

  //////////////////////////////////////////////////////////////////////////
  /////////////////////////////// IF ///////////////////////////////////////
  wire
    pc_en;                // allows PC to enable
  wire [15:0]
    pc_curr,              // PC value that comes from pc reg
    pc_nxt,               // PC value loaded into pc reg
    pc_plus_4F,           // PC value plus 4
    instrF;               // instruction out from iCache

  PC_register PC(.clk(clk), .rst(rst), .wen(pc_en), .d(pc_nxt), .q(pc_curr));

  assign pc_out = pc_curr; // readability

  add_16b add4(.a(pc_curr), .b(16'd4), .cin(1'b0), .s(pc_plus_4F), .cout());
  /////////////////////////////// IF ///////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////

  //////////////////////////////////////////////////////////////////////////
  /////////////////////////////// D ////////////////////////////////////////
  wire [2:0]
   br_codeD;               // branch flags that should be met to branch
  wire [3:0]
   opcodeD,
   rdD,
   rsD,
   rtD;
  wire [8:0]
   br_offD;                // branch offset
  wire [15:0]
   instrD,
   immD,
   PC_plus_4D;

   // signals meant for pc_control
   wire
      reg_wrD,              // write permissions to register
      mem_to_regD,          // memory read to register
      mem_wrD,              // memory write
      alu_srcD,             // imm or register 2
      reg_dstD,             // which register to write to (mem or alu op reg)
      branchD;              // branch??? yes or no
   wire [2:0]
      alu_controlD;         // control signals for ALU

   // instantiate control unit here
   /////////////////////////////
   //////////////////////////////

   // instantiate register and signals needed possibly from WB
   wire
      reg_wrW;
   wire [3:0]
      write_regW;
   wire [15:0]
      src_data_1D,
      src_data_2D,
      reg_dst_dataW;
   registerfile reg(
      .clk(clk),
      .rst(rst),
      .SrcReg1(rsD),
      .SrcReg2(rtD),
      .DstReg(write_regW),
      .WriteReg(reg_wrW),
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
   /////////////////////////////// D ////////////////////////////////////////
   //////////////////////////////////////////////////////////////////////////

   //////////////////////// mem module ///////////////////////////////////
   memory memory(
      .clk(clk),
      .rst(rst),
      .d_wrt_en(),
      .data_in(),
      .i_addr(pc_curr),
      .d_addr(),
      .i_fsm_busy(),
      .d_fsm_busy(),
      .d_mem_en(),
      .instr_out(instrF),
      .data_out();
      )

endmodule
