`include "alu_compute.vh"

module alu_compute(input_A, input_B, opcode, vld, out, flag);
	input
		vld;				// is this operation valid?
	input [3:0]
		opcode;			// Couldn't figure out how to get this down to 3 sigs
	input [15:0]
		input_A,			// base addr, or first operand, or $(rd)
		input_B;			// shift offset, mem imm, second operand
	output [15:0]
		out;
	output [2:0]
		flag;				// combinational output

	// Adder and subtracter is responsible for some arith and mem address calc
	wire
		sub;				// signal to subtract.
	wire [15:0]
		addsub_o;		// output of adder
	wire [2:1]
		addsub_f;		// output of flags
	wire [15:0]
		add_input_A,
		add_input_B;
	// determine if we need to subtract. Subtract if opcode[0] is 1 and it's not a mem operation
	assign sub = opcode[3] ? 1'b0 : opcode[0];
	// if mem operation, need to make sure address is even
	assign add_input_A = opcode[3] ? input_A & 16'hFFFE : input_A;
	// Need to add 0 back from encoded offset
	assign add_input_B = opcode[3] ? input_B << 1 : input_B;
	alu_adder ADDSUB(
		.mode(sub),
		.A(add_input_A),
		.B(add_input_B),
		.S(addsub_o),
		.N(addsub_f[2]),
		.V(addsub_f[1]));

	wire [15:0] red_o;
	RED RED_mod(input_A, input_B, red_o);

	wire [15:0] xor_o;
	assign xor_o = input_A ^ input_B;

	wire [15:0] shift_o;
	wire shift_imm;
	assign shift_imm = input_B[3:0];
	wire [31:0] ror_full;
	assign ror_full = {data, data} >> shift;
	// shift computations
	assign shift_o = opcode[1:0] == 2'b0 ? input_A << shift_imm :
				 opcode[1:0] == 2'b1 ? input_A >>> shift_imm :
				 ror_full[15:0];

	wire [15:0] paddsb_o;
	paddsb PADDSB(input_A, input_B, paddsb_o);

	wire [15:0] LLB, LHB;
	assign LLB = {input_A[15:8], input_B[7:0]};
	assign LHB = {input_B[7:0], input_A[7:0]};

	// DETERMINES WHICH OPERATION PASSES AS AN OUTPUT
	//////////////////////////////////////////////////////////////
	reg [15:0] out_reg;
	always @* begin
		casez (opcode)
			`PCS		: out_reg = input_A;
			4'bz00z		: out_reg = addsub_o;	//add,sub,lw,sw
			`PADDSB		: out_reg = paddsb_o;
			4'bz1zz		: out_reg = shift_o;	 	// all shift ops
			`RED			: out_reg = red_o;
			`XOR			: out_reg = xor_o;
			`LHB			: out_reg = LHB;
			default 		: out_reg = LLB;			// LLB. and everything else.
		endcase
	end
	assign out = out_reg;
	/////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////

	// flags. Flag register is write restricted depending on opcode
	//0 = Z
	assign flag[0] = out == 16'h0000;
	//1 = V
	assign flag[1] = addsub_f[1];
	//2 = N
	assign flag[2] = addsub_f[2];
endmodule
