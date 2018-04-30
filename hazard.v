module hazard(branch_matchD, mem_to_regE, reg_wrenE, dst_regE, mem_to_regM,
   reg_wrenM, dst_regM, reg_wrenW, dst_regW, stallF, stallD, flushD,
   forwardD, forward_A_selE, forward_B_selE);

   input
      branch_matchD,       // Is a branch being taken?
      mem_to_regE,         // Is this a load instruction?
      mem_to_regM,
      reg_wrenE,           // Is a register being written to (need fwding
      reg_wrenM,           // if so!)
      reg_wrenW;
   input [3:0]
      dst_regE,            // what register is being written to?
      dst_regM,            // (What register should be fwded)
      dst_regW;
      rsD;
      rtD;
      rsE;
      rtE;
   output
      stallF,              // Stops writes to register.
      stallD,
      flushD;              // Just connect it to branch_matchD
   /* In forwarding, the general pattern will be that the oldest signal
   such as a signal in WB will always be selected by the highest sel value */
   output [1:0]
      forwardD,            // This requires forwarding from E/M/W. Complicated
                           // this branch chooses between which branch register
      forward_A_selE,      // Choosing src 1 of ALU, Default to 00
      forward_B_selE;      // Choosing src 2 of ALU, Default to 00


	assign flushD = branch_matchD;

/*TODO Logic For forwardD*/

/* EX Hazard
if (EX/MEM.RegWrite & (EX/MEM.Rd != 0) & (EX/MEM.Rd == ID/EX.RS)) Forward from EX/MEM to ALU_IN_A
if (EX/MEM.RegWrite & (EX/MEM.Rd != 0) & (EX/MEM.Rd == ID/EX.RT)) Forward from EX/MEM to ALU_IN_B
*/	wire fwdA_ex_mem, fwdB_ex_mem;
	assign fwdA_ex_mem = reg_wrenM & ~(dst_regM == 4'b0000) & (dst_regM == rsE); //When High forward_A_selE = 01
	assign fwdB_ex_mem = reg_wrenM & ~(dst_regM == 4'b0000) & (dst_regM == rtE); //When High forward_B_selE = 01

/* MEM Hazard
if (MEM/WB.RegWrite & (MEM/WB.Rd != 0) & (MEM/WB.Rd == ID/EX.RS)) Forward from MEM/WB to ALU_IN_A
if (MEM/WB.RegWrite & (MEM/WB.Rd != 0) & (MEM/WB.Rd == ID/EX.RT)) Forward from MEM/WB to ALU_IN_B
*/
	wire fwdA_mem_wb, fwdB_mem_wb;
	assign fwdA_mem_wb = reg_wrenW & ~(dst_regW == 4'b0000) & (dst_regW == rsE); //When High forward_A_selE = 10
	assign fwdB_mem_wb = reg_wrenW & ~(dst_regW == 4'b0000) & (dst_regW == rtE); //When High forward B_selE = 10


	assign forward_A_selE = fwdA_mem_wb ? 2'b10 : fwd_A_ex_mem ? 2'b01 : 2'b00;
	assign forward_B_selE = fwdB_mem_wb ? 2'b10 : fwd_A_ex_mem ? 2'b01 : 2'b00;

/*
if (ID/EX.MemRead & ((ID/EX.Rt == IF/ID.Rs) | (ID/EX.Rt == IF/ID.Rt))) Stall Pipeline
*/
	wire stall_pipeline;
	assign stall_pipeline = mem_to_regM & ((rtE == rsD) | (rtE == rtD));
	assign stallF = stall_pipeline;
	assign stallD = stall_pipeline;

endmodule
