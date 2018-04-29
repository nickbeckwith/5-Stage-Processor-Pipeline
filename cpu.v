`include "cpu.vh"

module cpu(input clk, input rst_n, output hlt, output [15:0] pc_out);

  //////////////////////////// IF //////////////////////////////////////
  wire
    pc_en;                // allows PC to enable
  wire [15:0]
    pc_curr,              // PC value that comes from pc reg
    pc_nxt;               // PC value loaded into pc reg

  PC_register PC(.clk(clk), .rst(rst), .wen(pc_en), .d(pc_nxt), .q(pc_curr));


endmodule
