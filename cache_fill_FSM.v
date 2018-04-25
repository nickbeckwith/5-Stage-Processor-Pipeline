`include "dff.v"
`define IDLE 0
`define WAIT 1
module cache_fill_FSM(clk, rst_n, miss_detected, miss_address, fsm_busy,
                        write_data_array, write_tag_array, memory_address,
                        memory_data, memory_data_valid);
  input
    clk, rst_n,
    miss_detected,        // active high when tag match logic detects a miss
    memory_data_valid;    // active high indicates valid data returning on memory bus
  input [15:0]
    miss_address,         // address that missed the cache
    memory_data;          // data returned by memory (after  delay)
  output
    fsm_busy,             // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
    write_data_array,     // write enable to cache data array to signal when filling with memory_data
    write_tag_array;      // write enable to cache tag array to write tag and valid bit once all words are
                          // filled in to data array
  output [15:0]
    memory_address;       // address to read from memory


  //////////////////////////////////////////////////////////////////////////////
  /////////////////////////// 3 BIT COUNTER ////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  // need a counter that counts up to d'7 from 0 then resets. So 3 bits needed.
  // Easier to create counter with SM so need three DF's
  wire [2:0] cnt, nxt_cnt;     // the two state variables
  wire done;                   // set when counter resets
  dff state_ff_0(.q(cnt[0]), .d(nxt_cnt[0]), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff state_ff_1(.q(cnt[1]), .d(nxt_cnt[1]), .wen(1'b1), .clk(clk), .rst(~rst_n));
  dff state_ff_2(.q(cnt[2]), .d(nxt_cnt[2]), .wen(1'b1), .clk(clk), .rst(~rst_n));
  // reg versions of counter wires and assigning to their counterparts
  reg done_reg;
  reg [2:0] nxt_cnt_reg;
  assign nxt_cnt = nxt_cnt_reg;
  assign done = done_reg;
  // for readability. We want to increment count every time we receive data
  // This assumes memory_data_valid only goes high while we're in wait stage
  wire incr_cnt;
  assign incr_cnt = memory_data_valid;
  // onto the counter logic
  always @(incr_cnt, cnt) begin
    done_reg = 0;               // equiv to putting done = 0 to every case stmt
    case(cnt)
      3'd0 : nxt_cnt_reg = incr_cnt ? 3'd1 : 3'd0;
      3'd1 : nxt_cnt_reg = incr_cnt ? 3'd2 : 3'd1;
      3'd2 : nxt_cnt_reg = incr_cnt ? 3'd3 : 3'd2;
      3'd3 : nxt_cnt_reg = incr_cnt ? 3'd4 : 3'd3;
      3'd4 : nxt_cnt_reg = incr_cnt ? 3'd5 : 3'd4;
      3'd5 : nxt_cnt_reg = incr_cnt ? 3'd6 : 3'd5;
      3'd6 : nxt_cnt_reg = incr_cnt ? 3'd7 : 3'd6;
      3'd7 : begin
              nxt_cnt_reg = incr_cnt ? 3'd0 : 3'd7;
              done_reg = incr_cnt ? 1'b1 : 1'b0;
      end
      default : nxt_cnt_reg = 3'bxxx;     // shouldn't happen
    endcase
  end
  /////////////////////////// end of counter ///////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////


  //////////////////////////////////////////////////////////////////////////////
  //////////////////////////////// FSM /////////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
  // two states so we need only one DFF and a one bit state signal
  wire state, nxt_state;           // FSM relies on state and nxt_state sigs
  dff state_ff(.q(state), .d(nxt_state), .wen(1'b1), .clk(clk), .rst(~rst_n));
  // list of reg signal version of outputs
  reg
    fsm_busy_reg,
    write_data_array_reg,
    write_tag_array_reg,
    nxt_state_reg;
  reg [15:0]
    memory_address_reg;
  // assigns reg to their wire counterparts
  assign fsm_busy = fsm_busy_reg;
  assign write_data_array = write_data_array_reg;
  assign write_tag_array = write_tag_array_reg;
  assign nxt_state = nxt_state_reg;
  assign memory_address = memory_address_reg;
  // onto the case statement
  always @(state, miss_address, miss_detected, memory_data_valid, done) begin
    case(state)
      `IDLE : begin
        write_data_array_reg = 1'b0;
        write_tag_array_reg = 1'b0;
        memory_address_reg = {miss_address[15:2], cnt};
        fsm_busy_reg = miss_detected ? 1'b1 : 1'b0;   // on transition to wait
        nxt_state_reg = miss_detected ? `WAIT : `IDLE;
      end
      `WAIT : begin
        write_data_array_reg = memory_data_valid ? 1'b1 : 1'b0;
        write_tag_array_reg = done ? 1'b1 : 1'b0;     // on transition
        memory_address_reg = {miss_address[15:2], cnt};
        fsm_busy_reg = done ? 1'b0 : 1'b1;            // on transition
        nxt_state_reg = done ? `IDLE : `WAIT;
      end
      default : begin     // shouldn't happen
        write_data_array_reg = 1'bx;
        write_tag_array_reg = 1'bx;
        memory_address_reg = 16'hxxxx;
        fsm_busy_reg = 1'bx;
        nxt_state_reg = 1'bx;
      end
    endcase
  end
  /////////////////////////// end of FSM ///////////////////////////////////////
  //////////////////////////////////////////////////////////////////////////////
endmodule
