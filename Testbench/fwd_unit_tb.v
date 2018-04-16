module fwd_unit_tb ();
	reg [3:0] emo, emd, mwo, mwd, ies, iet;
	wire [1:0] fa, fb;

	fwd_unit TEST (emo, emd, mwo, mwd, ies, iet, fa, fb);

	initial begin
		emo = 4'b0;
		emd = 4'b0;
		mwo = 4'b0;
		mwd = 4'b0;
		ies = 4'b0;
		iet = 4'b0;
		repeat(100) begin
			#20 emo = $random;
			#0 emd = $random;
			#0 mwo = $random;	
			#0 mwd = $random;
			#0 ies = $random;
			#0 iet = $random;
		end
		#10;
	end
	
	initial $monitor("EMO:%b EMD:%b MWO:%b MWD:%b IES:%b IET:%b FA:%b FB:%b", emo, emd, mwo, mwd, ies, iet, fa, fb);
endmodule
