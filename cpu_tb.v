module cpu_tb();


   wire [15:0] PC;
   wire [15:0] Inst;           /* This should be the 15 bits of the FF that
                                  stores instructions fetched from instruction memory
                               */
   wire        RegWrite;       /* Whether register file is being written to */
   wire [3:0]  WriteRegister;  /* What register is written */
   wire [15:0] WriteData;      /* Data */
   wire        MemWrite;       /* Similar as above but for memory */
   wire        MemRead;
   wire [15:0] MemAddress;
   wire [15:0] MemData;

   wire        Halt;         /* Halt executed and in Memory or writeback stage */

   integer     inst_count;
   integer     cycle_count;

   integer     trace_file;
   integer     sim_log_file;
   integer	pipe_reg_file;

   reg clk; /* Clock input */
   reg rst_n; /* (Active low) Reset input */


		wire [15:0] IFID_pc, IFID_ins;
		wire [15:0] IDEX_pc, IDEX_rr1, IDEX_rr2, IDEX_imm;
		wire [8:0] IDEX_br;
		wire [3:0] IDEX_rs, IDEX_rt, IDEX_rd, IDEX_op;
		wire [15:0] EXMEM_alu_in;
		wire [15:0] EXMEM_pc, EXMEM_ma, EXMEM_ad, EXMEM_pcn, EXMEM_imm;
		wire [3:0] EXMEM_rs, EXMEM_rt, EXMEM_rd, EXMEM_op;
		wire [15:0] MEMWB_pc, MEMWB_md, MEMWB_ad, MEMWB_imm; 
		wire [3:0] MEMWB_rs, MEMWB_rt, MEMWB_rd, MEMWB_op;
		wire hzrd, branch;
		wire [1:0] FwdA, FwdB;

   cpu DUT(.clk(clk), .rst_n(rst_n), .pc_out(PC), .hlt(Halt)); /* Instantiate your processor */







   /* Setup */
   initial begin
      $display("Hello world...simulation starting");
      $display("See verilogsim.log and verilogsim.trace for output");
      inst_count = 0;
      trace_file = $fopen("verilogsim.trace");
      sim_log_file = $fopen("verilogsim.log");
      pipe_reg_file = $fopen("verilogsim_prf.log");

   end





  /* Clock and Reset */
// Clock period is 100 time units, and reset length
// to 201 time units (two rising edges of clock).

   initial begin
      $dumpvars;
      cycle_count = 0;
      rst_n = 0; /* Intial reset state */
      clk = 1;
      #201 rst_n = 1; // delay until slightly after two clock periods
    end

    always #50 begin   // delay 1/2 clock period each time thru loop
      clk = ~clk;
    end

    always @(posedge clk) begin
    	cycle_count = cycle_count + 1;
	if (cycle_count > 100000) begin
		$display("hmm....more than 100000 cycles of simulation...error?\n");
		$finish;
	end
    end








  /* Stats */
   always @ (posedge clk) begin
      if (rst_n) begin
         if (Halt || RegWrite || MemWrite) begin
            inst_count = inst_count + 1;
         end
	$fdisplay(pipe_reg_file, "HZRD:%b BRANCH:%b\nIFID-PC:%h INS:%h-\nIDEX-PC:%h RR1:%h RR2:%h RS:%d RT:%d RD:%d Imm:%h Br:%h Op:%d-\nEXMEM_ALU_IN:%h FwdA:%b FwdB:%b\nEXMEM-PC:%h MA:%h AD:%h RS:%d RT:%d RD:%d Imm:%h PCN:%h Op:%d-\nMEMWB-PC:%h MD:%h AD:%h RS:%d RT:%d RD:%d Imm:%h Op:%d-\n\n",
		hzrd, branch,
		IFID_pc, IFID_ins,
		IDEX_pc, IDEX_rr1, IDEX_rr2, IDEX_rs, IDEX_rt, IDEX_rd, IDEX_imm, IDEX_br, IDEX_op,
		EXMEM_alu_in, FwdA, FwdB,
		EXMEM_pc, EXMEM_ma, EXMEM_ad, EXMEM_rs, EXMEM_rt, EXMEM_rd, EXMEM_imm, EXMEM_pcn, EXMEM_op,
		MEMWB_pc, MEMWB_md, MEMWB_ad, MEMWB_rs, MEMWB_rt, MEMWB_rd, MEMWB_imm, MEMWB_op);
         $fdisplay(sim_log_file, "SIMLOG:: Cycle %d PC: %8x I: %8x R: %d %3d %8x M: %d %d %8x %8x",
                  cycle_count,
                  PC,
                  Inst,
                  RegWrite,
                  WriteRegister,
                  WriteData,
                  MemRead,
                  MemWrite,
                  MemAddress,
                  MemData);
         if (RegWrite) begin
            if (MemRead) begin
               // ld
               $fdisplay(trace_file,"INUM: %8d PC: 0x%04x REG: %d VALUE: 0x%04x ADDR: 0x%04x",
                         (inst_count-1),
                        PC,
                        WriteRegister,
                        WriteData,
                        MemAddress);
            end else begin
               $fdisplay(trace_file,"INUM: %8d PC: 0x%04x REG: %d VALUE: 0x%04x",
                         (inst_count-1),
                        PC,
                        WriteRegister,
                        WriteData );
            end
         end else if (Halt) begin
            $fdisplay(sim_log_file, "SIMLOG:: Processor halted\n");
            $fdisplay(sim_log_file, "SIMLOG:: sim_cycles %d\n", cycle_count);
            $fdisplay(sim_log_file, "SIMLOG:: inst_count %d\n", inst_count);
            $fdisplay(trace_file, "INUM: %8d PC: 0x%04x",
                      (inst_count-1),
                      PC );

            $fclose(trace_file);
            $fclose(sim_log_file);

            $finish;
         end else begin
            if (MemWrite) begin
               // st
               $fdisplay(trace_file,"INUM: %8d PC: 0x%04x ADDR: 0x%04x VALUE: 0x%04x",
                         (inst_count-1),
                        PC,
                        MemAddress,
                        MemData);
            end else begin
               // conditional branch or NOP
               // Need better checking in pipelined testbench
               inst_count = inst_count + 1;
               $fdisplay(trace_file, "INUM: %8d PC: 0x%04x",
                         (inst_count-1),
                         PC );
            end
         end
      end

   end


   /* Assign internal signals to top level wires
      The internal module names and signal names will vary depending
      on your naming convention and your design */

   // Edit the example below. You must change the signal
   // names on the right hand side

//   assign PC = DUT.fetch0.pcCurrent; //You won't need this because it's part of the main cpu interface
   assign Inst = DUT.instr_out;

   assign RegWrite = ~(DUT.exmem_op[3]) | ~(DUT.exmem_op[2]) | (DUT.exmem_op[1] & ~(DUT.exmem_op[0]));
   // Is memory being read, one bit signal (1 means yes, 0 means no)

   assign WriteRegister = DUT.exmem_rd;
   // The name of the register being written to. (4 bit signal)

   assign WriteData =  DUT.dest_data;
  // Data being written to the register. (16 bits)

   assign MemRead =  DUT.mem_en;
   // Is memory being read, one bit signal (1 means yes, 0 means no)

   assign MemWrite = (DUT.mem_en & DUT.mem_wr);
   // Is memory being written to (1 bit signal)

   assign MemAddress = DUT.exmem_ma;
   // Address to access memory with (for both reads and writes to memory, 16 bits)

   assign MemData = DUT.exmem_ad;
   // Data to be written to memory for memory writes (16 bits)

//   assign Halt = DUT.memory0.halt; //You won't need this because it's part of the main cpu interface
   // Is processor halted (1 bit signal)

   /* Add anything else you want here */


		assign IFID_pc = DUT.ifid_pc;
		assign IFID_ins = DUT.ifid_instr;
		assign IDEX_pc = DUT.idex_pc;
		assign IDEX_rr1 = DUT.idex_rr1;
		assign IDEX_rr2 = DUT.idex_rr2;
		assign IDEX_imm = DUT.idex_imm;
		assign IDEX_br = DUT.idex_br_off;
		assign IDEX_rs = DUT.idex_rs;
		assign IDEX_rt = DUT.idex_rt;
		assign IDEX_rd = DUT.idex_rd;
		assign IDEX_op = DUT.idex_op;
		assign EXMEM_pc	= DUT.exmem_pc_curr;
		assign EXMEM_ma = DUT.exmem_ma;
		assign EXMEM_ad	= DUT.exmem_ad;
		assign EXMEM_pcn = DUT.exmem_pc_next;
		assign EXMEM_imm = DUT.exmem_imm;
		assign EXMEM_rs = DUT.exmem_rs;
		assign EXMEM_rt = DUT.exmem_rt;
		assign EXMEM_rd = DUT.exmem_rd;
		assign EXMEM_op = DUT.exmem_op;
		assign MEMWB_pc = DUT.memwb_pc;
		assign MEMWB_md = DUT.memwb_md;
		assign MEMWB_ad = DUT.memwb_ad;
		assign MEMWB_imm = DUT.memwb_imm;
		assign MEMWB_rs = DUT.memwb_rs;
		assign MEMWB_rt = DUT.memwb_rt;
		assign MEMWB_rd = DUT.memwb_rd;
		assign MEMWB_op = DUT.memwb_op;
		assign hzrd = DUT.stall_n;
		assign EXMEM_alu_in = DUT.alu_data;
		assign branch = DUT.branch;
		assign FwdA = DUT.alu_mux_a;
		assign FwdB = DUT.alu_mux_b;
endmodule
