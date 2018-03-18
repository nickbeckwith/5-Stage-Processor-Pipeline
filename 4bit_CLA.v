module CLA_Cell( output S, output p,g, input A,B, input Cin);
	wire intermediate;
	and a1(g,A,B); 
	or  o1(p,A,B); 
	xor x1(intermediate,A,B); 
	xor x2(S,Cin,intermediate);
endmodule