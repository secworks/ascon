//======================================================================
//
// tb_ascon_permutation.v
// ----------------------
// Testbench for the Ascon permutation module.
// https://ascon.iaik.tugraz.at/files/asconv12-nist.pdf
//
//
// Author: Joachim Strömbergson
// Copyright (c) 2024, Assured AB
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or
// without modification, are permitted provided that the following
// conditions are met:
//
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in
//    the documentation and/or other materials provided with the
//    distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
// COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
// LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
// ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//======================================================================

module tb_ascon_permutation();
  localparam CLK_HALF_PERIOD = 1;
  localparam CLK_PERIOD      = 2 * CLK_HALF_PERIOD;

  //----------------------------------------------------------------
  // Register and wire declarations.
  //----------------------------------------------------------------
  reg [31 : 0]   cycle_ctr;
  reg [31 : 0]   error_ctr;
  reg [31 : 0]   tc_ctr;
  reg            monitor;

  reg            tb_clk;
  reg            tb_reset_n;
  reg [319 : 0]  tb_block;
  reg [3 : 0]    tb_num_rounds;
  reg            tb_start;
  wire           tb_ready;
  wire [319 : 0] tb_result;


  //----------------------------------------------------------------
  // Device Under Test.
  //----------------------------------------------------------------
  ascon_permutation dut(
                        .clk(tb_clk),
                        .reset_n(tb_reset_n),
                        .block(tb_block),
                        .num_rounds(tb_num_rounds),
                        .start(tb_start),
                        
                        .ready(tb_ready),
                        .result(tb_result)
                        );


  //----------------------------------------------------------------
  // clk_gen
  //
  // Always running clock generator process.
  //----------------------------------------------------------------
  always
    begin : clk_gen
      #CLK_HALF_PERIOD;
      tb_clk = !tb_clk;
    end // clk_gen


  //----------------------------------------------------------------
  // sys_monitor()
  //
  // An always running process that creates a cycle counter and
  // conditionally displays information about the DUT.
  //----------------------------------------------------------------
  always
    begin : sys_monitor
      #(CLK_PERIOD);
      cycle_ctr = cycle_ctr + 1;
      if (monitor)
        begin
          display_state();
        end
    end


  //----------------------------------------------------------------
  // init_sim()
  //
  // Initialize all counters and testbed functionality as well
  // as setting the DUT inputs to defined values.
  //----------------------------------------------------------------
  task init_sim;
    begin
      cycle_ctr     = 0;
      error_ctr     = 0;
      tc_ctr        = 0;
      monitor       = 0;

      tb_clk        = 0;
      tb_reset_n    = 1;
      tb_block      = 320'h0;
      tb_num_rounds = 4'h0;
      tb_start      = 0;
    end
  endtask // init_sim


  //----------------------------------------------------------------
  // reset_dut()
  //
  // Toggle reset to put the DUT into a well known state.
  //----------------------------------------------------------------
  task reset_dut;
    begin
      $display("--- DUT before reset:");
      display_state();
      $display("--- Toggling reset.");
      tb_reset_n = 0;
      #(2 * CLK_PERIOD);
      tb_reset_n = 1;
      $display("--- DUT after reset:");
      display_state();
    end
  endtask // reset_dut


  //----------------------------------------------------------------
  // display_state
  //
  // Display the state of the dut when needed.
  //----------------------------------------------------------------
  task display_state;
    begin
      $display("State of the DUT");
      $display("----------------");
      $display("Cycle: %016d", cycle_ctr);
      $display("");

      $display("Inputs and outputs:");
      $display("start: %1x, ready: %1x", tb_start, tb_ready);
      $display("num_rounds: block:  %02d", tb_num_rounds);
      $display("");
      $display("block:  0x%040x", tb_block);
      $display("result: 0x%040x", tb_result);
      $display("");

      $display("Internal state:");
      $display("");
    end
  endtask // display_state


  //----------------------------------------------------------------
  // display_test_result()
  //
  // Display the accumulated test results.
  //----------------------------------------------------------------
  task display_test_result;
    begin
      if (error_ctr == 0)
        begin
          $display("--- All %02d test cases completed successfully", tc_ctr);
        end
      else
        begin
          $display("--- %02d tests completed - %02d test cases did not complete successfully.",
                   tc_ctr, error_ctr);
        end
    end
  endtask // display_test_result

  //----------------------------------------------------------------
  //----------------------------------------------------------------
  task inc_tc;
    begin
      tc_ctr = tc_ctr + 1;
    end
  endtask // inc_tc
  
  //----------------------------------------------------------------
  //----------------------------------------------------------------
  task enable_monitor;
    begin
      monitor = 1;
    end
  endtask


  task disable_monitor;
    begin
      monitor = 0;
    end
  endtask

    
  //----------------------------------------------------------------
  // tc1: It's alive.
  //----------------------------------------------------------------
  task tc1;
    begin : tc1
      inc_tc();
      enable_monitor();
      
      tb_start = 1'h1;
      $display("tc1: Block permutation started at cycle %016d", cycle_ctr);
      #(2 * CLK_PERIOD);

      while (tb_ready == 0) begin
        #(CLK_PERIOD);
      end

      $display("tc1: Block permutation should be completed at cycle %016d", cycle_ctr);
      $display("tc1: tb_result: 0x%040x", tb_result);      

      disable_monitor();
    end
  endtask // tc!
  
  
  //----------------------------------------------------------------
  //----------------------------------------------------------------
  initial
    begin : tb_ascon_permutation;
      $display("--- Simulation of Ascon permutation started.");
      $display("");

      init_sim();
      reset_dut();
      tc1();
      display_test_result();

      $display("");
      $display("--- Simulation of Ascon permutation completed.");
      $finish;
    end
endmodule // tb_ascon_permutation
