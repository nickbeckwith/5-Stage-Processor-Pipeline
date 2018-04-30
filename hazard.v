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
   output
      stallF,              // Stops writes to register.
      stallD,
      flushD;              // Just connect it to branch_matchD
   /* In forwarding, the general pattern will be that the oldest signal
   such as a signal in WB will always be selected by the highest sel value */
   output [1:0]
      forwardD,            // This requires forwarding from E/M/W. Complicated
                           // this branch chooses between which branch register
      forward_A_selE,      // Choosing src 1 of ALU
      forward_B_selE;      // Choosing src 2 of ALU

endmodule
