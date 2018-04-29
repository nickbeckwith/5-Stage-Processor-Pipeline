module control_unit(opcode, reg_wren, mem_to_reg, mem_wr, alu_src, dst_reg_sel,
         branch);
   input [3:0]
      opcode;
   output
      reg_wren,         // Enables writing to register
      mem_to_reg,       // Enables reading from memory and writes to reg
      mem_wr,           // Enables writing to memory
      alu_src,          // 0 is reg, 1 is imm value. Reg/IMm selector
      dst_reg_sel,      // write to register in rt or rd. rt is 0
      branch;           // Is this a branch operation?
endmodule
