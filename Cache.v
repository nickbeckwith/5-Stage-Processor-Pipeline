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
Addr_In[15:11] = Tag
Addr_In[10:4] = Index
Addr_In[3:1] = Offset
	Would use Addr_In[0] but it will always be 1'b0 thus we use 3:1 to grab the 2byte word located at the specified address
	Which works out since our "inout bus" is 2bytes wide

MetaDataArray DataOut:
	DataOut[7] = Valid Bit of block residing in corresponding DataArray Location
	DataOut[4:0] = Tag of block residing in corresponding DataArray Location
*/
`include "MetaDataArray.v"
`include "DataArray.v"
module Cache(clk, rst, Data_In, Addr_In, Meta_W, Data_W, Miss_Detected, Miss_Addr, Data_Out);
	input
		clk,						//Clock Signal
		rst,						//Reset Signal
		Meta_W, 				//Write Signal for MetaDataArray: 0 if Read, 1 if Write
		Data_W;					//Write Signal for DataArray: 0 if Read, 1 if Write
	input [15:0]
		Data_In, 				//Data to Write to Cache
		Addr_In;				//Address to read/write from

	output
		Miss_Detected;	//Asserted When a miss has been detected
	output [15:0]
		Miss_Addr, 			//Address of Missed block
		Data_Out;				//Data Read from cache

	wire [4:0] Tag;			//16 - I - O = Tag
	wire [6:0] Index;		//Log(#Sets) = I, #Sets for Direct Mapped = # Blocks = 128
	wire [2:0] Offset;	//Log(BlockSize) = O, 16bytes (&byte addressable) => O = 4...Reason for wire being 3bits explained above module

	// decode address
	assign Tag = Addr_In[15:11];
	assign Index = Addr_In[10:4];
	assign Offset = Addr_In[3:1];

	//TODO//
	/*
	1. Decode Index to one-hot variation: 7bit to 128bit -> Used for BlockEnable
	2. Decode Offset to one-hot variation: 3*bit to 8bit -> Used for WordEnable
	3. Read MetaDataArray DataOut valid bit and tag bits to verify hit/miss
	4. React to hit/miss accordingly
	*/
	// decode index for blockenable
	wire [127:0] BlockEnable;
	decoder_7_128b dec_indx(.in(Index), .out(BlockEnable));
	// decode offset for wordenable
	wire [7:0] WordEnable;
	decoder_3_8b dec_offs(.in(Offset), .out(WordEnable));


	MetaDataArray META(.clk(), .rst(), .DataIn(), .Write(), .BlockEnable(), .DataOut());
	DataArray DATA(.clk(), .rst(), .DataIn(), .Write(), .BlockEnable(), .WordEnable(), .DataOut());

endmodule
