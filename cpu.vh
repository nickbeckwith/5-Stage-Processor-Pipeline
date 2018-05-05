`ifndef _cpu_vh_
`define _cpu_vh_

`include "hazard.v"
`include "registerfile.v"
`include "control_unit.v"
`include "flag_check.v"
`include "alu_compute.v"
`include "flag_reg.v"

`define ADD     4'b0000
`define SUB     4'b0001
`define RED     4'b0010
`define XOR     4'b0011
`define SLL     4'b0100
`define SRA     4'b0101
`define ROR     4'b0110
`define PADDSB  4'b0111
`define LW      4'b1000
`define SW      4'b1001
`define LHB     4'b1010
`define LLB     4'b1011
`define B       4'b1100
`define BR      4'b1101
`define PCS     4'b1110
`define HLT     4'b1111

`endif
