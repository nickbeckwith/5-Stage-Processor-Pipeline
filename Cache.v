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
module Cache(clk, rst, Data_In, Addr_In, Meta_W, Data_W, Miss_Detected, Miss_Addr, Data_Out);
	input clk,			//Clock Signal
		rst,			//Reset Signal
		Meta_W, 		//Write Signal for MetaDataArray: 0 if Read, 1 if Write
		Data_W;			//Write Signal for DataArray: 0 if Read, 1 if Write

	input [15:0] Data_In, 		//Data to Write to Cache
		Addr_In;		//Address to read/write from

	output Miss_Detected;		//Asserted When a miss has been detected

	output [15:0] Miss_Addr, 	//Address of Missed block
		Data_Out;		//Data Read from cache

	wire [4:0] Tag;			//16 - I - O = Tag
	wire [6:0] Index;		//Log(#Sets) = I, #Sets for Direct Mapped = # Blocks = 128
	wire [2:0] Offset;		//Log(BlockSize) = O, 16bytes (&byte addressable) => O = 4...Reason for wire being 3bits explained above module

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
	wire [7:0] Decoded_Offset;
	wire[127:0] Decoded_Index;
	assign Decoded_Index = 	(Index==7'h00) ? 128'h00000000000000000000000000000001:
													(Index==7'h01) ? 128'h00000000000000000000000000000002:
	 												(Index==7'h02) ? 128'h00000000000000000000000000000004:
													(Index==7'h03) ? 128'h00000000000000000000000000000008:
													(Index==7'h04) ? 128'h00000000000000000000000000000010:
													(Index==7'h05) ? 128'h00000000000000000000000000000020:
													(Index==7'h06) ? 128'h00000000000000000000000000000040:
													(Index==7'h07) ? 128'h00000000000000000000000000000080:
													(Index==7'h08) ? 128'h00000000000000000000000000000100:
													(Index==7'h09) ? 128'h00000000000000000000000000000200:
													(Index==7'h0A) ? 128'h00000000000000000000000000000400:
													(Index==7'h0B) ? 128'h00000000000000000000000000000800:
													(Index==7'h0C) ? 128'h00000000000000000000000000001000:
													(Index==7'h0D) ? 128'h00000000000000000000000000002000:
													(Index==7'h0E) ? 128'h00000000000000000000000000004000:
													(Index==7'h0F) ? 128'h00000000000000000000000000008000:

													(Index==7'h10) ? 128'h00000000000000000000000000010000:
													(Index==7'h11) ? 128'h00000000000000000000000000020000:
													(Index==7'h12) ? 128'h00000000000000000000000000040000:
													(Index==7'h13) ? 128'h00000000000000000000000000080000:
													(Index==7'h14) ? 128'h00000000000000000000000000100000:
													(Index==7'h15) ? 128'h00000000000000000000000000200000:
													(Index==7'h16) ? 128'h00000000000000000000000000400000:
													(Index==7'h17) ? 128'h00000000000000000000000000800000:
													(Index==7'h18) ? 128'h00000000000000000000000001000000:
													(Index==7'h19) ? 128'h00000000000000000000000002000000:
													(Index==7'h1A) ? 128'h00000000000000000000000004000000:
													(Index==7'h1B) ? 128'h00000000000000000000000008000000:
													(Index==7'h1C) ? 128'h00000000000000000000000010000000:
													(Index==7'h1D) ? 128'h00000000000000000000000020000000:
													(Index==7'h1E) ? 128'h00000000000000000000000040000000:
													(Index==7'h1F) ? 128'h00000000000000000000000080000000:

													(Index==7'h20) ? 128'h00000000000000000000000100000000:
													(Index==7'h21) ? 128'h00000000000000000000000200000000:
 													(Index==7'h22) ? 128'h00000000000000000000000400000000:
													(Index==7'h23) ? 128'h00000000000000000000000800000000:
													(Index==7'h24) ? 128'h00000000000000000000001000000000:
													(Index==7'h25) ? 128'h00000000000000000000002000000000:
													(Index==7'h26) ? 128'h00000000000000000000004000000000:
													(Index==7'h27) ? 128'h00000000000000000000008000000000:
													(Index==7'h28) ? 128'h00000000000000000000010000000000:
													(Index==7'h29) ? 128'h00000000000000000000020000000000:
													(Index==7'h2A) ? 128'h00000000000000000000040000000000:
													(Index==7'h2B) ? 128'h00000000000000000000080000000000:
													(Index==7'h2C) ? 128'h00000000000000000000100000000000:
													(Index==7'h2D) ? 128'h00000000000000000000200000000000:
													(Index==7'h2E) ? 128'h00000000000000000000400000000000:
													(Index==7'h2F) ? 128'h00000000000000000000800000000000:

													(Index==7'h30) ? 128'h00000000000000000001000000000000:
													(Index==7'h31) ? 128'h00000000000000000002000000000000:
													(Index==7'h32) ? 128'h00000000000000000004000000000000:
													(Index==7'h33) ? 128'h00000000000000000008000000000000:
													(Index==7'h34) ? 128'h00000000000000000010000000000000:
													(Index==7'h35) ? 128'h00000000000000000020000000000000:
													(Index==7'h36) ? 128'h00000000000000000040000000000000:
													(Index==7'h37) ? 128'h00000000000000000080000000000000:
													(Index==7'h38) ? 128'h00000000000000000100000000000000:
													(Index==7'h39) ? 128'h00000000000000000200000000000000:
													(Index==7'h3A) ? 128'h00000000000000000400000000000000:
													(Index==7'h3B) ? 128'h00000000000000000800000000000000:
													(Index==7'h3C) ? 128'h00000000000000001000000000000000:
													(Index==7'h3D) ? 128'h00000000000000002000000000000000:
													(Index==7'h3E) ? 128'h00000000000000004000000000000000:
													(Index==7'h3F) ? 128'h00000000000000008000000000000000:

													(Index==7'h40) ? 128'h00000000000000010000000000000000:
													(Index==7'h41) ? 128'h00000000000000020000000000000000:
 													(Index==7'h42) ? 128'h00000000000000040000000000000000:
													(Index==7'h43) ? 128'h00000000000000080000000000000000:
													(Index==7'h44) ? 128'h00000000000000100000000000000000:
													(Index==7'h45) ? 128'h00000000000000200000000000000000:
													(Index==7'h46) ? 128'h00000000000000400000000000000000:
													(Index==7'h47) ? 128'h00000000000000800000000000000000:
													(Index==7'h48) ? 128'h00000000000001000000000000000000:
													(Index==7'h49) ? 128'h00000000000002000000000000000000:
													(Index==7'h4A) ? 128'h00000000000004000000000000000000:
													(Index==7'h4B) ? 128'h00000000000008000000000000000000:
													(Index==7'h4C) ? 128'h00000000000010000000000000000000:
													(Index==7'h4D) ? 128'h00000000000020000000000000000000:
													(Index==7'h4E) ? 128'h00000000000040000000000000000000:
													(Index==7'h4F) ? 128'h00000000000080000000000000000000:

													(Index==7'h50) ? 128'h00000000000100000000000000000000:
													(Index==7'h51) ? 128'h00000000000200000000000000000000:
 													(Index==7'h52) ? 128'h00000000000400000000000000000000:
													(Index==7'h53) ? 128'h00000000000800000000000000000000:
													(Index==7'h54) ? 128'h00000000001000000000000000000000:
													(Index==7'h55) ? 128'h00000000002000000000000000000000:
													(Index==7'h56) ? 128'h00000000004000000000000000000000:
													(Index==7'h57) ? 128'h00000000008000000000000000000000:
													(Index==7'h58) ? 128'h00000000010000000000000000000000:
													(Index==7'h59) ? 128'h00000000020000000000000000000000:
													(Index==7'h5A) ? 128'h00000000040000000000000000000000:
													(Index==7'h5B) ? 128'h00000000080000000000000000000000:
													(Index==7'h5C) ? 128'h00000000100000000000000000000000:
													(Index==7'h5D) ? 128'h00000000200000000000000000000000:
													(Index==7'h5E) ? 128'h00000000400000000000000000000000:
													(Index==7'h5F) ? 128'h00000000800000000000000000000000:

													(Index==7'h60) ? 128'h00000001000000000000000000000000:
													(Index==7'h61) ? 128'h00000002000000000000000000000000:
													(Index==7'h62) ? 128'h00000004000000000000000000000000:
													(Index==7'h63) ? 128'h00000008000000000000000000000000:
													(Index==7'h64) ? 128'h00000010000000000000000000000000:
													(Index==7'h65) ? 128'h00000020000000000000000000000000:
													(Index==7'h66) ? 128'h00000040000000000000000000000000:
													(Index==7'h67) ? 128'h00000080000000000000000000000000:
													(Index==7'h68) ? 128'h00000100000000000000000000000000:
													(Index==7'h69) ? 128'h00000200000000000000000000000000:
													(Index==7'h6A) ? 128'h00000400000000000000000000000000:
													(Index==7'h6B) ? 128'h00000800000000000000000000000000:
													(Index==7'h6C) ? 128'h00001000000000000000000000000000:
													(Index==7'h6D) ? 128'h00002000000000000000000000000000:
													(Index==7'h6E) ? 128'h00004000000000000000000000000000:
													(Index==7'h6F) ? 128'h00008000000000000000000000000000:

													(Index==7'h70) ? 128'h00010000000000000000000000000000:
													(Index==7'h71) ? 128'h00020000000000000000000000000000:
 													(Index==7'h72) ? 128'h00040000000000000000000000000000:
													(Index==7'h73) ? 128'h00080000000000000000000000000000:
													(Index==7'h74) ? 128'h00100000000000000000000000000000:
													(Index==7'h75) ? 128'h00200000000000000000000000000000:
													(Index==7'h76) ? 128'h00400000000000000000000000000000:
													(Index==7'h77) ? 128'h00800000000000000000000000000000:
													(Index==7'h78) ? 128'h01000000000000000000000000000000:
													(Index==7'h79) ? 128'h02000000000000000000000000000000:
													(Index==7'h7A) ? 128'h04000000000000000000000000000000:
													(Index==7'h7B) ? 128'h08000000000000000000000000000000:
													(Index==7'h7C) ? 128'h10000000000000000000000000000000:
													(Index==7'h7D) ? 128'h20000000000000000000000000000000:
													(Index==7'h7E) ? 128'h40000000000000000000000000000000:
													(Index==7'h7F) ? 128'h80000000000000000000000000000000:
													128'h0;

	assign Decoded_Offset = (Offset == 3'd0) ? 8'h01:
													(Offset == 3'd1) ? 8'h02:
													(Offset == 3'd2) ? 8'h04:
													(Offset == 3'd3) ? 8'h08:
													(Offset == 3'd4) ? 8'h10:
													(Offset == 3'd5) ? 8'h20:
													(Offset == 3'd6) ? 8'h40:
													(Offset == 3'd7) ? 8'h80: 
													8'h0;


	MetaDataArray META(.clk(), .rst(), .DataIn(), .Write(), .BlockEnable(), .DataOut());
	DataArray DATA(.clk(), .rst(), .DataIn(), .Write(), .BlockEnable(), .WordEnable(), .DataOut());

endmodule
