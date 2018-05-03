module hazard(branch_matchD, i_fsm_busy, d_fsm_busy, mem_to_regE, reg_wrenE,
   dst_regE, mem_to_regM, reg_wrenM, dst_regM, reg_wrenW, dst_regW, rsD, rtD,
   rsE, rtE, stallF, stallD, stallE, flushD, forwardD, forward_A_selE, forward_B_selE);

   input
      branch_matchD,       // Is a branch being taken?
      i_fsm_busy,
      d_fsm_busy,
      mem_to_regE,         // Is this a load instruction?
      mem_to_regM,
      reg_wrenE,           // Is a register being written to (need fwding
      reg_wrenM,           // if so!)
      reg_wrenW;
   input [3:0]
      dst_regE,            // what register is being written to?
      dst_regM,            // (What register should be fwded)
      dst_regW,
      rsD,
      rtD,
      rsE,
      rtE;
   output
      stallF,              // Stops writes to register.
      stallD,
      stallE,              // upstream from memory..
      flushD;              // Just connect it to branch_matchD
   /* In forwarding, the general pattern will be that the oldest signal
   such as a signal in WB will always be selected by the highest sel value */
   output [1:0]
      forwardD,            // This requires forwarding from E/M/W. Complicated
                           // this branch chooses between which branch register
      forward_A_selE,      // Choosing src 1 of ALU, Default to 00
      forward_B_selE;      // Choosing src 2 of ALU, Default to 00

   /*If forwarding is needed for branch instruction:
         11 - dst reg in write back stage needs to be forwarded
         10 - dst reg in mem stage needs to be forwarded
         01 - dst reg in ex stage needs to be forwarded
         00 - forwarding not needed
   */
   assign forwardD =
                     (reg_wrenE & (rsD == dst_regE)) ? 2'b01:
                     (reg_wrenM & (rsD == dst_regM)) ? 2'b10:
                     (reg_wrenW & (rsD == dst_regW)) ? 2'b11: 2'b0;

	assign flushD = branch_matchD | i_fsm_busy;


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


	assign forward_A_selE = fwdA_ex_mem ? 2'b01 : fwdA_mem_wb ? 2'b10 : 2'b00;
	assign forward_B_selE = fwdB_ex_mem ? 2'b01 : fwdB_mem_wb ? 2'b10 : 2'b00;

/*
if (ID/EX.MemRead & ((ID/EX.Rt == IF/ID.Rs) | (ID/EX.Rt == IF/ID.Rt))) Stall Pipeline
*/
   /* We only forward memory reads in the WB stage to reduce clk. However, both
   the decode stage and the execute stage require what is read from memory.
   Therefore, we must stall while the offending instruction is in the decode stage.
   We must stall if mem load is in execute or mem stage and its data is requested. */
	wire stall_frm_E;      // mem load is in execute stage while dependent is in decode
                          // is stalled on both ALU and branch depndency
   wire stall_frm_M;      // mem load is in mem stage while dependent is in decode
                          // is stalled only on branch dependency
   // stall_Frm_x sigs are only data dependence stalls. On cache busy, further
   // logic needs to occur with d_cache_fsm_busy.
   assign stall_frm_E = mem_to_regE & ((dst_regE == rsD) | (dst_regE == rtD));
   assign stall_frm_M = mem_to_regM & (dst_regM == rsD);
   assign stall_pipeline = stall_frm_E | stall_frm_M | d_fsm_busy;
	assign stallF = stall_pipeline | i_fsm_busy;
	assign stallD = stall_pipeline;
   assign stallE = d_fsm_busy;

endmodule
