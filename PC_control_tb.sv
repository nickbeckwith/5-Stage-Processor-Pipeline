module PC_control_tb();
`define B   4'b1100
`define BR  4'b1101
`define PCS 4'b1110
`define HLT 4'b1111
// inputs
logic [15:0]
	PC_in,                // PC's value before increment
	data;                 // value stored in register to jump to
logic [8:0]
	offset;               // signed branch offset imm value
logic [3:0]
	op;                   // opcode to determine what instruction
logic [2:0]
	C,                    // encoding for branch conditions
	F;                    // in the format {N, V, S}
// outputs
logic [15:0]
	PC_out;               // Desired PC value
logic clk;

PC_control iDUT(.PC_in(PC_in), .data(data), .offset(offset), .op(op), .C(C),
										.F(F), .PC_out(PC_out));

initial clk = 0;
always clk = #5 ~clk;

logic N, V, Z;
assign F = {N, V, Z};

initial begin
	data = 0;
	offset = 0;
	op = 1;
	C = 0;
	PC_in = 400;
	{N, V, Z} = 0;
	@(negedge clk);
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	op = `BR;
	data = 400;
	@(posedge clk);
	N = 1;
	@(posedge clk);
	op = `B;
	offset = 4;
	N = 0;
	@(posedge clk);
	op = `PCS;
	N = 1;
	@(posedge clk);
	op = `HLT;
	N = 0;
	@(posedge clk);
	$stop;
	end
endmodule
