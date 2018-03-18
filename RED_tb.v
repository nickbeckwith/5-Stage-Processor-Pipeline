module RED_tb(); 
	reg[15:0] A,B; 
	wire [6:0] R; 
	
	RED iDUT(.A(A),.B(B),.R(R));
	
	
	always begin 
		#10; 
		A = 16'd1; 
		B = 16'd2; 
		#10; 
		if(R != 7'd3)begin 
			$display("error");
		end
	end
endmodule
