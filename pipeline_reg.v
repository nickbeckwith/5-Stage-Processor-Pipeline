module pipeline_reg(clk, rst, d, clr, wren, q);
   parameter WIDTH = 16;
   input
		clk,
		rst,
		clr,			// synchronous clear.
		wren;			// write enable signal
	input [WIDTH-1:0]
      d;
   output [WIDTH-1:0]
      q;
   wire [WIDTH-1:0]
      dff_in;

   dff ff[WIDTH-1:0](
      .q(q),
      .d(clr ? {WIDTH{1'b0}} : d),     // synchronous clear
      .wen(wren),
      .clk(clk),
      .rst(rst));
endmodule
