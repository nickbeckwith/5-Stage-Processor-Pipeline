`include "add_16b.v"

`include "opcodes.vh"
module PC_control(PC_in, data, offset, op, C, F, PC_out, Branch);
  `define B   4'b1100
  `define BR  4'b1101
  `define PCS 4'b1110
  `define HLT 4'b1111
  input [15:0]
    PC_in,                // PC's value before increment
    data;                 // value stored in register to jump to
  input [8:0]
    offset;               // signed branch offset imm value
  input [3:0]
    op;                   // opcode to determine what instruction
  input [2:0]
    C,                    // encoding for branch conditions
    F;                    // in the format {N, V, S}
  output [15:0]
    PC_out;               // Desired PC value
  output
    Branch;		  // Whether or not a branch is being taken


  // branch instruction calculation
  wire [15:0] PC_b;         // PC target for imm branch
  wire [15:0] PC_plus_2;    // Also known as PC_increment
  wire [15:0] offset_shift;
  assign offset_shift = {{7{offset[8]}}, offset} << 1;
  add_16b add1(.a(PC_in), .b(16'h2), .cin(1'b0), .s(PC_plus_2), .cout());
  add_16b add2(.a(PC_plus_2), .b(offset_shift), .cin(1'b0), .s(PC_b), .cout());

  // Branch register instruction
  wire [15:0] PC_br;        // PC target for branch register
  assign PC_br = data;             // just for readability


  // determine if branching should occur through flags
  wire N, V, Z;
  assign {N, V, Z} = F;
  reg willBranch;
  always @(C, F) begin
    case (C)
      3'b000: willBranch = ~Z;
      3'b001: willBranch = Z;
      3'b010: willBranch = ~Z & ~N;
      3'b011: willBranch = N;
      3'b100: willBranch = Z | (~Z & ~N);
      3'b101: willBranch = N | Z;
      3'b110: willBranch = V;
      3'b111: willBranch = 1'b1;
      default: willBranch = 1'b0;
    endcase
  end

  // update PC_op depending on whether branch is taken and OPcode
  reg [15:0] PC_op;
  always @(op, F) begin
    case (op)
      `B:   PC_op = willBranch ? PC_b : PC_plus_2;
      `BR:  PC_op = willBranch ? PC_br : PC_plus_2;
      `PCS: PC_op = PC_plus_2;
      `HLT: PC_op = PC_in;
      default: PC_op = PC_plus_2;
    endcase
  end

  assign Branch = ((op == `B) | (op == `BR) | (op ==`PCS)) ? willBranch : 1'b0;
  assign PC_out = PC_op;
endmodule
