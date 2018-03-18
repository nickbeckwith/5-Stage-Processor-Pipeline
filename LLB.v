module LLB(input [15:0]A, output [15:0] Lower_byte); 
  
	assign Lower_byte = {A[7],A[7],A[7],A[7],A[7],A[7],A[7],A[7],A[7:0]};
endmodule 
