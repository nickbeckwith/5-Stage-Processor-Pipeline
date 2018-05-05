module iCache(clk, rst, mem_data_vld, read_req, mem_data, addr_in,
									fsm_busy, wrt_mem, miss_addr, data_out);
   input
		clk,						// Clock Signal
		rst,						// Reset Signal
		mem_data_vld;	     	// active high indicates valid data returning on memory bus
	input [15:0]
		mem_data, 				// Data to write to Cache
		addr_in;					// Address to read/write from
	output
		read_req,				// Enables read to memory
		fsm_busy,				// asserted while FSM is busy handling the miss
		wrt_mem;					// Allows write to memory
	output [15:0]
		miss_addr, 				// Address that is connected to main memory
		data_out;				// Data read from cache

   // create array to hold cache data
   typedef reg [15:0] word_t;
   typedef word_t [0:7] block_t;
   typedef block_t [0:1] set_t;
   set_t [0:63] data;
   
   always_ff @(posedge clk) begin

   end
endmodule
