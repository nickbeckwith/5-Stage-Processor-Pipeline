`include "dff.v"
`define IDLE 0
`define WAIT 1
module cache_fill_FSM(clk, rst, wrt, miss_detected, memory_data_valid, read_req,
                        wrt_mem, miss_address, memory_data, fsm_busy,
                        write_data_array, write_tag_array, memory_address,
						cache_address);
  input
    clk, rst,
    wrt,                  // High when mem needs to be written. On case of hit, wrt makes write_data high.
    miss_detected,        // active high when tag match logic detects a miss
    memory_data_valid,    // active high indicates valid data returning on memory bus
    wrt_mem;            // write signal to cache
  input [15:0]
    miss_address,         // address that missed the cache
    memory_data;          // data returned by memory (after  delay)
  output
    read_req,             // Asks main memory for a read.
    fsm_busy,             // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
    write_data_array,     // write enable to cache data array to signal when filling with memory_data
    write_tag_array;      // write enable to cache tag array to write tag and valid bit once all words are
                          // filled in to data array
  output [15:0]
	cache_address,		  // Determines cache address
    memory_address;       // address to read from memory


  //////////////////////////////////////////////////////////////////////////////
  /////////////////////////// 3 BIT COUNTER ////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  // need a counter that counts up to d'7 from 0 then resets. So 3 bits needed.
  // Easier to create counter with SM so need three DF's
  wire [3:0] cnt, nxt_cnt;     // the two state variables
  wire done;                   // When all blks are received
  wire reading;                // while sending requests for all 8 blocks
  wire incr_cnt;               // continues counting. Should only be on in WAIT
  dff state_ff_0(.q(cnt[0]), .d(nxt_cnt[0]), .wen(incr_cnt), .clk(clk), .rst(rst));
  dff state_ff_1(.q(cnt[1]), .d(nxt_cnt[1]), .wen(incr_cnt), .clk(clk), .rst(rst));
  dff state_ff_2(.q(cnt[2]), .d(nxt_cnt[2]), .wen(incr_cnt), .clk(clk), .rst(rst));
  dff state_ff_3(.q(cnt[3]), .d(nxt_cnt[3]), .wen(incr_cnt), .clk(clk), .rst(rst));
  // reg versions of counter wires and assigning to their counterparts
  reg done_reg;
  reg reading_reg;
  reg [3:0] nxt_cnt_reg;
  assign nxt_cnt = nxt_cnt_reg;
  assign done = done_reg;
  assign reading = incr_cnt ? reading_reg : 1'b0;   // reading should only occur in main mem in WAIT state
  // onto the counter logic
  always @(incr_cnt, cnt) begin
    done_reg = 0;              // equiv to putting ovfl_reg = 0 to every case stmt
    case(cnt)
      4'd0  : begin nxt_cnt_reg = 4'd1;  reading_reg = 1'b1; end
      4'd1  : begin nxt_cnt_reg = 4'd2;  reading_reg = 1'b1; end
      4'd2  : begin nxt_cnt_reg = 4'd3;  reading_reg = 1'b1; end
      4'd3  : begin nxt_cnt_reg = 4'd4;  reading_reg = 1'b1; end
      4'd4  : begin nxt_cnt_reg = 4'd5;  reading_reg = 1'b1; end
      4'd5  : begin nxt_cnt_reg = 4'd6;  reading_reg = 1'b1; end
      4'd6  : begin nxt_cnt_reg = 4'd7;  reading_reg = 1'b1; end
      4'd7  : begin nxt_cnt_reg = 4'd8;  reading_reg = 1'b1; end
      4'd8  : begin nxt_cnt_reg = 4'd9;  reading_reg = 1'b0; end
      4'd9  : begin nxt_cnt_reg = 4'd10; reading_reg = 1'b0; end
      4'd10 : begin nxt_cnt_reg = 4'd11; reading_reg = 1'b0; end
      4'd11 : begin
                nxt_cnt_reg = 4'd0;
                done_reg = incr_cnt ? 1'b1 : 1'b0;
                reading_reg = 1'b0;
      end
      default : nxt_cnt_reg = 3'bxxx;     // shouldn't happen
    endcase
  end
  /////////////////////////// end of counter ///////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  
  //////////////////////////////////////////////////////////////////////////////
  ////////////////////////// counter for cache addr ////////////////////////////
  wire [3:0] blck_off, nxt_blck_off;		// state vars
  dff fsm0(.q(blck_off[0]), .d(nxt_blck_off[0]), .wen(memory_data_valid), .clk(clk), .rst(rst));
  dff fsm1(.q(blck_off[1]), .d(nxt_blck_off[1]), .wen(memory_data_valid), .clk(clk), .rst(rst));
  dff fsm2(.q(blck_off[2]), .d(nxt_blck_off[2]), .wen(memory_data_valid), .clk(clk), .rst(rst));
  dff fsm3(.q(blck_off[3]), .d(nxt_blck_off[3]), .wen(memory_data_valid), .clk(clk), .rst(rst));
  // reg version of wires
  reg [3:0] nxt_blck_off_reg;
  assign nxt_blck_off = nxt_blck_off_reg;
  always @(blck_off) begin
	case(blck_off)
		4'b0000 : nxt_blck_off_reg = 4'b0010;
		4'b0010 : nxt_blck_off_reg = 4'b0100;
		4'b0100 : nxt_blck_off_reg = 4'b0110;
		4'b0110 : nxt_blck_off_reg = 4'b1000;
		4'b1000 : nxt_blck_off_reg = 4'b1010;
		4'b1010 : nxt_blck_off_reg = 4'b1100;
		4'b1100 : nxt_blck_off_reg = 4'b1110;
		4'b1110 : nxt_blck_off_reg = 4'b0000;
		default : nxt_blck_off_reg = 4'bxxxx;
	endcase
  end
  ///////////////////////////////// end /////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  
  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////// FSM /////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  // two states so we need only one DFF and a one bit state signal
  wire state, nxt_state;           // FSM relies on state and nxt_state sigs
  dff state_ff(.q(state), .d(nxt_state), .wen(1'b1), .clk(clk), .rst(rst));
  // list of reg signal version of outputs
  reg
    fsm_busy_reg,
    write_data_array_reg,
    write_tag_array_reg,
    nxt_state_reg,
    read_req_reg,
    incr_cnt_reg,
    wrt_mem_reg;
  reg [15:0]
	cache_address_reg,
    memory_address_reg;
  // assigns reg to their wire counterparts
  assign fsm_busy = fsm_busy_reg;
  assign write_data_array = write_data_array_reg;
  assign write_tag_array = write_tag_array_reg;
  assign nxt_state = nxt_state_reg;
  assign memory_address = memory_address_reg;
  assign cache_address = cache_address_reg;
  assign read_req = read_req_reg;
  assign incr_cnt = incr_cnt_reg;
  assign wrt_mem = wrt_mem_reg;
  // onto the case statement
  always @(state, miss_detected, wrt, miss_address, blck_off, cnt, memory_data_valid, done) begin
    case(state)
      `IDLE : begin
        write_data_array_reg = miss_detected ? 1'b0 : wrt;
        write_tag_array_reg = 1'b0;
		cache_address_reg = miss_detected ? {miss_address[15:2], blck_off} : miss_address;
        memory_address_reg = miss_detected ? {miss_address[15:2], cnt} : miss_address;
        fsm_busy_reg = miss_detected ? 1'b1 : 1'b0;   // on transition to wait
        incr_cnt_reg = 1'b0;
        read_req_reg = 1'b0;
        wrt_mem_reg = miss_detected ? 1'b0 : wrt;
        nxt_state_reg = miss_detected ? `WAIT : `IDLE;
      end
      `WAIT : begin
        write_data_array_reg = memory_data_valid ? 1'b1 : 1'b0;
        write_tag_array_reg = done ? 1'b1 : 1'b0;     // on transition
		cache_address_reg = {miss_address[15:2], blck_off};
        memory_address_reg = {miss_address[15:2], cnt[2:0], 1'b0};
        fsm_busy_reg = 1'b1;      // isn't on transition so a valid write will occur
        incr_cnt_reg = 1'b1;
        read_req_reg = reading;    // only read on the first 8.
        wrt_mem_reg = 1'b0;     // will write after it goes back to idle
        nxt_state_reg = done ? `IDLE : `WAIT;   // while in IDLE
      end
      default : begin     // shouldn't happen
        write_data_array_reg = 1'bx;
        write_tag_array_reg = 1'bx;
		cache_address_reg = 16'hxxxx;
        memory_address_reg = 16'hxxxx;
        fsm_busy_reg = 1'bx;
        incr_cnt_reg = 1'bx;
        read_req_reg = 1'bx;
        nxt_state_reg = 1'bx;
      end
    endcase
  end
  /////////////////////////// end of FSM ///////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
endmodule
