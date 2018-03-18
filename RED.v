module RED(input [15:0] A, input [15:0] B, output [6:0] R); 
	wire [4:0] hbyte_1,hbyte_2,hbyte_3,hbyte_4,hbyte_5,hbyte_6,hbyte_7,hbyte_8,S1,S2,S3,S4; 
	wire [5:0] S1_ext,S2_ext,S3_ext,S4_ext,S5,S6; 
	wire [6:0] S5_ext, S6_ext;
	assign hbyte_1 = {A[3],A[3:0]};
 	assign hbyte_2 = {A[7],A[7:4]}; 
	assign hbyte_3 = {A[11],A[11:8]};
	assign hbyte_4 = {A[15],A[15:12]}; 

	assign hbyte_5 = {B[3],B[3:0]};
 	assign hbyte_6 = {B[7],B[7:4]}; 
	assign hbyte_7 = {B[11],B[11:8]};
	assign hbyte_8 = {B[15],B[15:12]}; 

	CLA_5bit CLA50(.A(hbyte_4),.B(hbyte_8),.S(S1)); 
	CLA_5bit CLA51(.A(hbyte_3),.B(hbyte_7),.S(S2)); 
	CLA_5bit CLA52(.A(hbyte_2),.B(hbyte_6),.S(S3)); 
	CLA_5bit CLA53(.A(hbyte_1),.B(hbyte_5),.S(S4));
	assign S1_ext = {S1[4],S1}; 
	assign S2_ext = {S2[4],S2}; 
	assign S3_ext = {S3[4],S3}; 
	assign S4_ext = {S4[4],S4};
	CLA_6bit CLA60(.A(S1_ext),.B(S2_ext),.S(S5)); 
	CLA_6bit CLA61(.A(S4_ext),.B(S3_ext),.S(S6));  
	assign S5_ext = {S5[5],S5}; 
	assign S6_ext = {S6[5],S6}; 

	CLA_7bit CLA70(.A(S5_ext),.B(S6_ext),.S(R));
endmodule
