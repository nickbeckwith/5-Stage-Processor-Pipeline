`include "mux2_1.v"

module sra(so, si, sv);
	input [15:0] si;
	input [3:0] sv;
	output [15:0] so;

	wire[15:0] ST1, ST2, ST3;

	mux2_1 m00 (.d1(si[15]), .d0(si[15]), .b(ST1[0]), .s(sv[0]));
	mux2_1 m01 (.d1(si[15]), .d0(si[14]), .b(ST1[1]), .s(sv[0]));
	mux2_1 m02 (.d1(si[14]), .d0(si[13]), .b(ST1[2]), .s(sv[0]));
	mux2_1 m03 (.d1(si[13]), .d0(si[12]), .b(ST1[3]), .s(sv[0]));
	mux2_1 m04 (.d1(si[12]), .d0(si[11]), .b(ST1[4]), .s(sv[0]));
	mux2_1 m05 (.d1(si[11]), .d0(si[10]), .b(ST1[5]), .s(sv[0]));
	mux2_1 m06 (.d1(si[10]), .d0(si[9]), .b(ST1[6]), .s(sv[0]));
	mux2_1 m07 (.d1(si[9]), .d0(si[8]), .b(ST1[7]), .s(sv[0]));
	mux2_1 m08 (.d1(si[8]), .d0(si[7]), .b(ST1[8]), .s(sv[0]));
	mux2_1 m09 (.d1(si[7]), .d0(si[6]), .b(ST1[9]), .s(sv[0]));
	mux2_1 m0A (.d1(si[6]), .d0(si[5]), .b(ST1[10]), .s(sv[0]));
	mux2_1 m0B (.d1(si[5]), .d0(si[4]), .b(ST1[11]), .s(sv[0]));
	mux2_1 m0C (.d1(si[4]), .d0(si[3]), .b(ST1[12]), .s(sv[0]));
	mux2_1 m0D (.d1(si[3]), .d0(si[2]), .b(ST1[13]), .s(sv[0]));
	mux2_1 m0E (.d1(si[2]), .d0(si[1]), .b(ST1[14]), .s(sv[0]));
	mux2_1 m0F (.d1(si[1]), .d0(si[0]), .b(ST1[15]), .s(sv[0]));

	mux2_1 m10 (.d1(si[15]), .d0(ST1[0]), .b(ST2[0]), .s(sv[1]));
	mux2_1 m11 (.d1(si[15]), .d0(ST1[1]), .b(ST2[1]), .s(sv[1]));
	mux2_1 m12 (.d1(ST1[0]), .d0(ST1[2]), .b(ST2[2]), .s(sv[1]));
	mux2_1 m13 (.d1(ST1[1]), .d0(ST1[3]), .b(ST2[3]), .s(sv[1]));
	mux2_1 m14 (.d1(ST1[2]), .d0(ST1[4]), .b(ST2[4]), .s(sv[1]));
	mux2_1 m15 (.d1(ST1[3]), .d0(ST1[5]), .b(ST2[5]), .s(sv[1]));
	mux2_1 m16 (.d1(ST1[4]), .d0(ST1[6]), .b(ST2[6]), .s(sv[1]));
	mux2_1 m17 (.d1(ST1[5]), .d0(ST1[7]), .b(ST2[7]), .s(sv[1]));
	mux2_1 m18 (.d1(ST1[6]), .d0(ST1[8]), .b(ST2[8]), .s(sv[1]));
	mux2_1 m19 (.d1(ST1[7]), .d0(ST1[9]), .b(ST2[9]), .s(sv[1]));
	mux2_1 m1A (.d1(ST1[8]), .d0(ST1[10]), .b(ST2[10]), .s(sv[1]));
	mux2_1 m1B (.d1(ST1[9]), .d0(ST1[11]), .b(ST2[11]), .s(sv[1]));
	mux2_1 m1C (.d1(ST1[10]), .d0(ST1[12]), .b(ST2[12]), .s(sv[1]));
	mux2_1 m1D (.d1(ST1[11]), .d0(ST1[13]), .b(ST2[13]), .s(sv[1]));
	mux2_1 m1E (.d1(ST1[12]), .d0(ST1[14]), .b(ST2[14]), .s(sv[1]));
	mux2_1 m1F (.d1(ST1[13]), .d0(ST1[15]), .b(ST2[15]), .s(sv[1]));

	mux2_1 m20 (.d1(si[15]), .d0(ST2[0]), .b(ST3[0]), .s(sv[2]));
	mux2_1 m21 (.d1(si[15]), .d0(ST2[1]), .b(ST3[1]), .s(sv[2]));
	mux2_1 m22 (.d1(si[15]), .d0(ST2[2]), .b(ST3[2]), .s(sv[2]));
	mux2_1 m23 (.d1(si[15]), .d0(ST2[3]), .b(ST3[3]), .s(sv[2]));
	mux2_1 m24 (.d1(ST2[0]), .d0(ST2[4]), .b(ST3[4]), .s(sv[2]));
	mux2_1 m25 (.d1(ST2[1]), .d0(ST2[5]), .b(ST3[5]), .s(sv[2]));
	mux2_1 m26 (.d1(ST2[2]), .d0(ST2[6]), .b(ST3[6]), .s(sv[2]));
	mux2_1 m27 (.d1(ST2[3]), .d0(ST2[7]), .b(ST3[7]), .s(sv[2]));
	mux2_1 m28 (.d1(ST2[4]), .d0(ST2[8]), .b(ST3[8]), .s(sv[2]));
	mux2_1 m29 (.d1(ST2[5]), .d0(ST2[9]), .b(ST3[9]), .s(sv[2]));
	mux2_1 m2A (.d1(ST2[6]), .d0(ST2[10]), .b(ST3[10]), .s(sv[2]));
	mux2_1 m2B (.d1(ST2[7]), .d0(ST2[11]), .b(ST3[11]), .s(sv[2]));
	mux2_1 m2C (.d1(ST2[8]), .d0(ST2[12]), .b(ST3[12]), .s(sv[2]));
	mux2_1 m2D (.d1(ST2[9]), .d0(ST2[13]), .b(ST3[13]), .s(sv[2]));
	mux2_1 m2E (.d1(ST2[10]), .d0(ST2[14]), .b(ST3[14]), .s(sv[2]));
	mux2_1 m2F (.d1(ST2[11]), .d0(ST2[15]), .b(ST3[15]), .s(sv[2]));

	mux2_1 m30 (.d1(si[15]), .d0(ST3[0]), .b(so[15]), .s(sv[3]));
	mux2_1 m31 (.d1(si[15]), .d0(ST3[1]), .b(so[14]), .s(sv[3]));
	mux2_1 m32 (.d1(si[15]), .d0(ST3[2]), .b(so[13]), .s(sv[3]));
	mux2_1 m33 (.d1(si[15]), .d0(ST3[3]), .b(so[12]), .s(sv[3]));
	mux2_1 m34 (.d1(si[15]), .d0(ST3[4]), .b(so[11]), .s(sv[3]));
	mux2_1 m35 (.d1(si[15]), .d0(ST3[5]), .b(so[10]), .s(sv[3]));
	mux2_1 m36 (.d1(si[15]), .d0(ST3[6]), .b(so[9]), .s(sv[3]));
	mux2_1 m37 (.d1(si[15]), .d0(ST3[7]), .b(so[8]), .s(sv[3]));
	mux2_1 m38 (.d1(ST3[0]), .d0(ST3[8]), .b(so[7]), .s(sv[3]));
	mux2_1 m39 (.d1(ST3[1]), .d0(ST3[9]), .b(so[6]), .s(sv[3]));
	mux2_1 m3A (.d1(ST3[2]), .d0(ST3[10]), .b(so[5]), .s(sv[3]));
	mux2_1 m3B (.d1(ST3[3]), .d0(ST3[11]), .b(so[4]), .s(sv[3]));
	mux2_1 m3C (.d1(ST3[4]), .d0(ST3[12]), .b(so[3]), .s(sv[3]));
	mux2_1 m3D (.d1(ST3[5]), .d0(ST3[13]), .b(so[2]), .s(sv[3]));
	mux2_1 m3E (.d1(ST3[6]), .d0(ST3[14]), .b(so[1]), .s(sv[3]));
	mux2_1 m3F (.d1(ST3[7]), .d0(ST3[15]), .b(so[0]), .s(sv[3]));
endmodule
