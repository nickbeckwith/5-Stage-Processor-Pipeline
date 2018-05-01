`include "iCache.v"
`include "dCache.v"
`include "multicycle_memory.v"
`define iCache 1'b1
`define dCache 1'b0

module memory(clk, rst, d_wrt_en, data_in, i_addr, d_addr,
         i_fsm_busy, d_fsm_busy, d_mem_en, instr_out, data_out);
   input
      clk,
      rst,
      d_wrt_en,         // data mem write
      d_mem_en;         // enables data memory for reads
   input [15:0]
      data_in,          // data from data memory in
      i_addr,           // address to instruction wanted. (PC)
      d_addr;           // address to data wanted
   output
      i_fsm_busy,       // instruction cache busy
      d_fsm_busy;       // data cache busy
   output [15:0]
      instr_out,        // instruction from icache
      data_out;         // data from data cache

   // wires needed between all three units or mem wires
   wire
      mem_en,
      mem_wr,
      data_vld;
   wire [15:0]
      mem_data_out,
      mem_data_in,
      mem_addr;

   // iCache and its wires
   wire
      i_data_vld,
      i_read_req,
      i_wrt_mem;
   wire [15:0]
      i_addr_in,
      i_miss_addr;

   // dCache and its wires
   wire
      d_wrt_en,
      d_data_vld,
      d_read_req,
      d_wrt_mem;
   wire [15:0]
      d_addr_in,
      d_miss_addr;

   iCache iCache(
      .clk(clk),
      .rst(rst),
      .mem_data_vld(i_data_vld),
      .read_req(i_read_req),
      .mem_data(mem_data_out),
      .addr_in(i_addr),
      .fsm_busy(i_fsm_busy),
      .wrt_mem(i_wrt_mem),
      .miss_addr(i_miss_addr),
      .data_out(instr_out));

   dCache dCache(
      .clk(clk),
      .rst(rst),
      .wrt_en(d_wrt_en),
      .mem_data_vld(d_data_vld),
      .read_req(d_read_req),
      .mem_data(mem_data_out),
      .addr_in(d_addr),
      .fsm_busy(d_fsm_busy),
      .wrt_mem(d_wrt_mem),
      .miss_addr(d_miss_addr),
      .data_out(data_out),
      .mem_en(d_mem_en),
      .ifsm_busy(i_fsm_busy),
      .reg_in(data_in));


   memory4c mem(
      .data_out(mem_data_out),
      .data_in(mem_data_in),
      .addr(mem_addr),
      .enable(mem_en),
      .wr(mem_wr),
      .clk(clk),
      .rst(rst),
      .data_valid(data_vld));


   // arbitration logic begins here
   // give i_cache priority
   assign sel = i_fsm_busy ? `iCache : `dCache;

   assign mem_addr = sel ? i_miss_addr : d_miss_addr;

   assign mem_en = sel ? i_read_req : d_read_req | d_wrt_mem;

   assign mem_wr = sel ? i_wrt_mem : d_wrt_mem;

   assign i_data_vld = sel ? data_vld : 1'b0;

   assign d_data_vld = sel ? 1'b0 : data_vld;

   assign mem_data_in = sel ? 16'b0 : data_in;

endmodule
