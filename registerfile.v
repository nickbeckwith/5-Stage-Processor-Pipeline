module registerfile (input clk, input rst, input [3:0] SrcReg1, input [3:0] SrcReg2,
			input [3:0] DstReg, input WriteReg, input [15:0] DstData,
			output [15:0] SrcData1, output [15:0] SrcData2);

	reg [15:0] regmem [0:15];

	// initialize to zero
	integer i;
	initial begin
		for (i = 0; i < 16; i = i + 1)
			regmem[i] = 16'b0;
	end

	// Mips would have this be negedge but I'm not sure...
	always @(posedge clk)
		if (WriteReg) begin
			regmem[4'b0] <= 16'b0;
			regmem[DstReg] <= DstData;
		end

	//Implement Internal Bypassing Somehow
	// forwarding time
	// if SrcReg1 == DstReg then set SrcData1 to DstData
	// if SrcReg2 == DstReg then set SrcData2 to DstData
	// Should use combinational logic because buffers might result in a high impedence read
	assign SrcData1 = SrcReg1 == DstReg ? DstData : regmem[SrcReg1];
	assign SrcData2 = SrcReg2 == DstReg ? DstData : regmem[SrcReg2];
endmodule
