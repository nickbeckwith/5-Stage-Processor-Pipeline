module LHB(input A[15:0], output [15:0] Upper_byte); 
	  
	assign Upper_byte = {A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15:8]};
endmodule 
