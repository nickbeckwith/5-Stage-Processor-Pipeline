module LHB(input[15:0] A, output [15:0] Upper_byte); 
	  
	assign Upper_byte = {A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15],A[15:8]};
endmodule 
