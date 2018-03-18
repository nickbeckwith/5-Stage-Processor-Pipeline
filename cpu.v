module CPU(input clk, input rst_n, output hlt, output [15:0] pc); 
	wire[15:0] instr_addr,data_addr,data_out,data_in,instr_out; 
	wire write_en; 
	wire enable, wr, write_reg; 
	wire[3:0] reg1,reg2,reg_dest; 
	wire [15:0] reg_read_val_1,reg_read_val_2,dest_data;
	
	memory1c Data_Mem(.data_out(data_out),.data_in(data_in),.addr(addr),.enable(enable),.wr(wr),.clk(clk),.rst(rst_n)); 
	
	//figure out connections for data_in, enable and wr in instruction memory
	memory1c Instr_Mem(.data_out(instr_out),.addr(instr_addr),.clk(clk),.rst(rst_n));  
	
	//register file
	RegisterFile rf(.clk(clk),.rst(rst_n),.SrcReg1(reg1),.SrcReg2(reg2),.DstReg(reg_dest),.WriteReg(write_reg),.DstData(dest_data),.SrcData1(reg_read_val_1),.SrcData2(reg_read_val_2));
	
	alu_compute ALU();
endmodule
