/*
"I believe the only difference between Icache and Dcache is how the interact with pipeline (no-op vs. stall).
Also, the module interface may need to be changed in order to handle misses correctly and write policy correctly" - Justin


Direct Mapped Cache

Write Through and Write Allocate
-Writes:
	On Hit: Write to Both Cache and Memory (we've been guarenteed that memory write and cache write will finish at the same time)
	On Miss: Pull Block into Cache and write in the same manner that we would on a hit -> Will Require a pipeline stall

-Reads:
	On Hit: Read from cache and move on
	On Miss: Pull Block into Cache and Read in the same manner that we would on a hit -> Will Require a pipeline stall
addr_in[15:11] = tag
addr_in[10:4] = index
addr_in[3:1] = offset
	Would use addr_in[0] but it will always be 1'b0 thus we use 3:1 to grab the 2byte word located at the specified address
	Which works out since our "inout bus" is 2bytes wide

MetaDataArray DataOut:
	DataOut[7] = Valid Bit of block residing in corresponding DataArray Location
	DataOut[4:0] = Tag of block residing in corresponding DataArray Location
*/
`include "opcodes.vh"
module dCache(clk, rst, wrt_en, mem_data_vld, read_req, mem_data, addr_in,
				fsm_busy, wrt_mem, miss_addr, data_out, mem_en, ifsm_busy, reg_in);
	input
		clk,							//Clock Signal
		rst,							//Reset Signal
		wrt_en, 					//High if processor wants to write
		mem_en,					// enables memory/cache
		ifsm_busy,				// prevents fsm starting while i_cache fsm is busy
		mem_data_vld;		// active high indicates valid data returning on memory bus
	input [15:0]
		mem_data, 				//Data to write to Cache
		reg_in,					// data from register
		addr_in;					//Address to read/write from

	output
		read_req,					// Should control the enable signal if there's no write anywhere
		fsm_busy,					// asserted while FSM is busy handling the miss
		wrt_mem;					// write command from FSM that should be connected to memory
	output [15:0]				// (can be used as pipeline stall signal)
		miss_addr, 				//Address that should be attached to main memory
		data_out;					//Data Read from cache

	wire [15:0] cache_addr, data_in;	// data_in is either mem_data, reg_data
	wire wrt_tag;
	wire wrt_hit;
	wire hit;						//set if there's a hit. Cleared if no hit.
	wire [4:0] tag;			//16 - I - O = tag
	wire [6:0] index;		//Log(#Sets) = I, #Sets for Direct Mapped = # Blocks = 128
	wire [2:0] offset;	//Log(BlockSize) = O, 16bytes (&byte addressable) => O = 4...Reason for wire being 3bits explained above module

	// decode address
	// using address from FSM because it's equiv to addr_in unless there's a miss
	// if there's a miss, we want to reference the correct offset as it counts from 0 to __
	assign tag = cache_addr[15:11];
	assign index = cache_addr[10:4];
	assign offset = cache_addr[3:1];

	// decode index for blockenable
	wire [127:0] block_en;
	decoder_7_128b dec_indx(.in(index), .out(block_en));
	// decode offset for wordenable
	wire [7:0] word_en;
	decoder_3_8b dec_offs(.in(offset), .out(word_en));

	// determine what data to put what data into data_array
	assign data_in = hit ? reg_in : mem_data;

	// meta data stored in the cache
	wire [7:0] meta_data;
	wire [7:0] meta_data_vld; 	// This is the only write we'd ever make to the tag.
	assign meta_data_vld = {1'b1, 2'b0, tag};		// valid bit is 1.

	// determine if hit or not. Valid && the tag matches
	// if memory isn't being touched. It shouldn't be hit!
	// if write to meta data, assume hit is instead just 0.
	assign hit = ~mem_en ? 1'b1 :
				wrt_tag ? 1'b0 : meta_data[7] & (meta_data[4:0] == tag);

	// fsm
	cache_fill_FSM FSM(.clk(clk), .rst(rst), .wrt(wrt_en), .miss_detected(~hit),
											.memory_data_vld(mem_data_vld), .read_req(read_req),
											.wrt_mem(wrt_mem), .miss_addr(addr_in),
											.memory_data(mem_data), .fsm_busy(fsm_busy),
											.write_data_array(wrt_hit), .write_tag_array(wrt_tag),
											.memory_address(miss_addr), .cache_addr(cache_addr),
											.pause(ifsm_busy));

	// Creation of cache
	MetaDataArray META(.clk(clk), .rst(rst), .DataIn(meta_data_vld), .Write(wrt_tag),
										.BlockEnable(block_en), .DataOut(meta_data));
	DataArray DATA(.clk(clk), .rst(rst), .DataIn(data_in), .Write(wrt_hit),
										.BlockEnable(block_en), .WordEnable(word_en), .DataOut(data_out));

endmodule
