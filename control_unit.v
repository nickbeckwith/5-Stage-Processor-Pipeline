module control_unit(opcode, reg_wren, mem_to_reg, mem_wr, alu_src, reg_dst,
         branch);
   input [3:0]
      opcode;
   output
      reg_wren,         // Enables writing to register
      mem_to_reg,       // Enables reading from memory and writes to reg
      mem_wr,           // Enables writing to memory
      alu_src,          // 0 is reg, 1 is imm value. Reg/IMm selector
      reg_dst,          // 0 is ALU, 1 is memory. ALU/mem out selector
      branch;           // Is this a branch operation?
endmodule
