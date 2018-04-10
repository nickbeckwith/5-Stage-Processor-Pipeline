module Decoder_tb;
	reg [3:0] stim;
	reg option;
	wire [15:0] out1;
	wire [15:0] out2;

	ReadDecoder_4_16 TEST_R (.RegId(stim), .Wordline(out1));
	WriteDecoder_4_16 TEST_W (.RegId(stim), .WriteReg(option), .Wordline(out2));
	initial begin
		stim = 4'b0;
		option = 1'b0;
		repeat(100) begin
			#20 stim = $random;
			#0 option = $random;
		end
		#10;
	end

	initial $monitor("Input:%b Op:%b Output_R:%b Output_W:%b", stim, option, out1, out2); 
endmodule
