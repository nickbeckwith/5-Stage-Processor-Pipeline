module alu_compute(InputA, InputB, Offset, Opcode, OutputA, OutputB, Flag);
	input [15:0] InputA, InputB, Offset;
	input [3:0] Opcode;
	output [15:0] OutputA, OutputB;
	output [2:0] Flag;

	wire [15:0] addsub_o;
	wire [2:0] addsub_f;
	alu_adder ADDSUB (Opcode[0], InputA, InputB, addsub_o, addsub_f[2], addsub_f[1], addsub_f[0]);

	wire [15:0] red_o;
	RED RED_mod (InputA, InputB, red_o);

	wire [15:0] xor_o;
	xor_16b XOR (InputA, InputB, xor_o);

	wire [15:0] shift_o;
	wire shift_f;
	shifter SHIFT (shift_o, shift_f, InputA, InputB[3:0], Opcode[1:0]);

	wire [15:0] paddsb_o;
	paddsb PADDSB (InputA, InputB, paddsb_o);

	wire [15:0] mem_addr, rs_even, imm_shift;
	assign rs_even = InputA & 16'b1111111111111110;
	assign imm_shift = Offset << 1;
	add_16b MEMADD (.a(rs_even), .b(imm_shift), .cin(1'b0), .s(OutputA), .cout());

	wire [15:0] LLB, LHB, LXX_o;
	assign LLB = (InputA & 16'b1111111100000000) | Offset;
	assign LHB = (InputA & 16'b0000000011111111) | (Offset << 8);
	assign LXX_o = Opcode[0] ? LLB : LHB;

	// DETERMINES WHICH OPERATION PASSES AS AN OUTPUT
	//////////////////////////////////////////////////////////////
	reg [15:0] MA_out;
	always @(Opcode, addsub_o, red_o, xor_o, shift_o, paddsb_o) begin
		case (Opcode[2:0])
			3'd0 : MA_out = addsub_o;
			3'd1 : MA_out = addsub_o;
			3'd2 : MA_out = red_o;
			3'd3 : MA_out = xor_o;
			3'd4 : MA_out = shift_o;
			3'd5 : MA_out = shift_o;
			3'd6 : MA_out = shift_o;
			3'd7 : MA_out = paddsb_o;
			default: MA_out = 16'hxxxx;		// this should not happen
		endcase
	end

	wire [15:0] MB_out, MC_out;
	// MB_out gets InputB if LW or SW instruction
	assign MB_out = ((Opcode == 4'b1000) | (Opcode == 4'b1001)) ? InputB : MA_out;

	// MC_out gets LXX_o if the opcode is an LLB or LHB instruction
	assign MC_out = (Opcode == 4'b1010) | (Opcode == 4'b1011) ? LXX_o : MB_out;
	assign OutputB = MC_out;

	/////////////////////////////////////////////////////////////////
	/////////////////////////////////////////////////////////////////

	//0 = Z
	assign Flag[0] = MB_out == 16'b0 ? 1'b1 : 1'b0;
	//1 = V
	assign Flag[1] = addsub_f[1] & ~(Opcode[3] | Opcode[2] | Opcode[1]);
	//2 = N
	assign Flag[2] = addsub_f[2] & ~(Opcode[3] | Opcode[2] | Opcode[1]);
endmodule
