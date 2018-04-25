module ReadDecoder_4_16(input [3:0] RegId, output [15:0] Wordline);
	reg [15:0] case_out;
	assign Wordline = case_out;
	always @(RegId) begin
		case (RegId)
			4'h0 : case_out = 16'h0001;
			4'h1 : case_out = 16'h0002;
			4'h2 : case_out = 16'h0004;
			4'h3 : case_out = 16'h0008;
			4'h4 : case_out = 16'h0010;
			4'h5 : case_out = 16'h0020;
			4'h6 : case_out = 16'h0040;
			4'h7 : case_out = 16'h0080;
			4'h8 : case_out = 16'h0100;
			4'h9 : case_out = 16'h0200;
			4'hA : case_out = 16'h0400;
			4'hB : case_out = 16'h0800;
			4'hC : case_out = 16'h1000;
			4'hD : case_out = 16'h2000;
			4'hE : case_out = 16'h4000;
			4'hF : case_out = 16'h8000;
			default : case_out = 0; // shouldn't happen
		endcase
	end
endmodule
