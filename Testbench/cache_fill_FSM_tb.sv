`include "cache_fill_FSM.v"
module cache_fill_FSM_tb();
  // inputs
  logic
    clk, rst_n,
    miss_detected,        // active high when tag match logic detects a miss
    memory_data_vld;    // active high indicates valid data returning on memory bus
  logic [15:0]
    miss_addr,         // address that missed the cache
    memory_data;          // data returned by memory (after  delay)

  // outputs
  logic
    fsm_busy,             // asserted while FSM is busy handling the miss (can be used as pipeline stall signal)
    write_data_array,     // write enable to cache data array to signal when filling with memory_data
    write_tag_array;      // write enable to cache tag array to write tag and valid bit once all words are
                          // filled in to data array
  logic [15:0]
    memory_address;       // address to read from memory

  cache_fill_FSM iDUT(clk, rst_n, miss_detected, miss_addr, fsm_busy,
                          write_data_array, write_tag_array, memory_address,
                          memory_data, memory_data_vld);

  initial begin
    clk = 0;
    rst_n = 0;
    miss_detected = 0;
    memory_data_vld = 0;
    miss_addr = 16'h0002;
    memory_data = 0;
    @(negedge clk);
    rst_n = 1;
    @(posedge clk);
    @(posedge clk);
    miss_detected = 1;
    @(negedge clk);
    if (fsm_busy == 0) begin
      $display("FSM BUSY SHOULD BE 1.");
      $stop;
    end
    if (memory_address != 16'h0) begin
      $display("Req address should be 0");
      $stop;
    end
    @(posedge clk);
    if (memory_address != 16'h0) begin
      $display("Req address should be 0");
      $stop;
    end
    repeat(3) @(posedge clk);
    memory_data_vld = 1;
    @(posedge clk);
    memory_data_vld = 0;
    #2;
    if (memory_address != 16'h1) begin
      $display("Req address should be 1");
      $stop;
    end
    repeat(3) @(posedge clk);
    memory_data_vld = 1;
    @(posedge clk);
    memory_data_vld = 0;


  end

  always #5 clk = ~clk;

endmodule
