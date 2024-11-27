//======================================================================
//
// ascon_permutation.v
// -------------------
// Ascon block cipher permutation.
// Given a 320 blt block, the state will be set and then updated the
// given number of rounds.
//
//
// Author: Joachim Strombergson
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

`default_nettype none

module ascon_permutation(
                         input wire            clk,
                         input wire            reset_n,
                         
                         input wire [319 : 0]  block,
                         input wire [3 : 0]    num_rounds,
                         input wire            start,
                         
                         output wire           ready,
                         output wire [319 : 0] state
                        );


  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  localparam CTRL_IDLE   = 2'h0;
  localparam CTRL_WAIT1  = 2'h1;
  localparam CTRL_WAIT2  = 2'h2;
  localparam CTRL_ROUNDS = 2'h3;


  //----------------------------------------------------------------
  // functions.
  //----------------------------------------------------------------
  // Constant addition layer (pc) for state word S2.
  function automatic [63 : 0] pc(input [63 : 0] x, input [3 : 0] r);
    begin : pc
      reg [7 : 0] xor_val;
      case (r)
	    0:  xor_val = x[7 : 0] ^ 8'h3c;
	    1:  xor_val = x[7 : 0] ^ 8'h2d;
	    2:  xor_val = x[7 : 0] ^ 8'h1d;
	    3:  xor_val = x[7 : 0] ^ 8'h0f;
	    4:  xor_val = x[7 : 0] ^ 8'hf0;
	    5:  xor_val = x[7 : 0] ^ 8'he1;
	    6:  xor_val = x[7 : 0] ^ 8'hd2;
	    7:  xor_val = x[7 : 0] ^ 8'hc3;
	    8:  xor_val = x[7 : 0] ^ 8'hb4;
	    9:  xor_val = x[7 : 0] ^ 8'ha5;
	    10: xor_val = x[7 : 0] ^ 8'h96;
	    11: xor_val = x[7 : 0] ^ 8'h87;
	    12: xor_val = x[7 : 0] ^ 8'h78;
	    13: xor_val = x[7 : 0] ^ 8'h69;
	    14: xor_val = x[7 : 0] ^ 8'h5a;
	    15: xor_val = x[7 : 0] ^ 8'h4b;
	    default begin
	    end
      endcase
      pc = {x[63 : 8], x[7 : 0] ^  xor_val};
    end
  endfunction // pc


  // Linear diffusion (lp) for each state word.
  function automatic [63 : 0] pls0(input [63 : 0] s0);
    begin
      pls0 = s0 ^ {s0[18 : 0], s0[63 : 19]} ^ {s0[27 : 0], s0[63 : 28]};
    end
  endfunction // pls0

  function automatic [63 : 0] pls1(input [63 : 0] s1);
    begin
      pls1 = s1 ^ {s1[60 : 0], s1[63 : 61]} ^ {s1[38 : 0], s1[63 : 39]};
    end
  endfunction // pls1

  function automatic [63 : 0] pls2(input [63 : 0] s2);
    begin
      pls2 = s2 ^ {s2[0], s2[63 : 1]} ^ {s2[5 : 0], s2[63 : 6]};
    end
  endfunction // pls2

  function automatic [63 : 0] pls3(input [63 : 0] s3);
    begin
      pls3 = s3 ^ {s3[9 : 0], s3[63 : 10]} ^ {s3[16 : 0], s3[63 : 17]};
    end
  endfunction // pls3

  function automatic [63 : 0] pls4(input [63 : 0] s4);
    begin
      pls4 = s4 ^ {s4[6 : 0], s4[63 : 7]} ^ {s4[40 : 0], s4[63 : 41]};
    end
  endfunction // pls4

  function automatic [4 : 0] ps(input [4 : 0] x);
    begin
      case (x)
        00: ps = 5'h04;
        01: ps = 5'h0b;
        02: ps = 5'h1f;
        03: ps = 5'h14;
        04: ps = 5'h1a;
        05: ps = 5'h15;
        06: ps = 5'h09;
        07: ps = 5'h02;
        08: ps = 5'h1b;
        09: ps = 5'h05;
        
        10: ps = 5'h08;
        11: ps = 5'h12;
        12: ps = 5'h1d;
        13: ps = 5'h03;
        14: ps = 5'h06;
        15: ps = 5'h1c;
        16: ps = 5'h1e;
        17: ps = 5'h13;
        18: ps = 5'h07;
        19: ps = 5'h0e;
        
        20: ps = 5'h00;
        21: ps = 5'h0d;
        22: ps = 5'h11;
        23: ps = 5'h18;
        24: ps = 5'h10;
        25: ps = 5'h0c;
        26: ps = 5'h01;
        27: ps = 5'h19;
        28: ps = 5'h16;
        29: ps = 5'h0a;
        
        30: ps = 5'h0f;
        31: ps = 5'h17;
	    default begin
	    end
      endcase      
    end
  endfunction // ps
 
    
  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  reg [63 : 0]  s0_reg;
  reg [63 : 0]  s0_new;
  reg [63 : 0]  s1_reg;
  reg [63 : 0]  s1_new;
  reg [63 : 0]  s2_reg;
  reg [63 : 0]  s2_new;
  reg [63 : 0]  s3_reg;
  reg [63 : 0]  s3_new;
  reg [63 : 0]  s4_reg;
  reg [63 : 0]  s4_new;
  reg           state_we;
  reg           state_set;

  reg           ready_reg;
  reg           ready_new;
  reg           ready_we;

  reg [3 : 0]   num_rounds_reg;
  reg           num_rounds_we;
  
  reg [3 : 0]   round_ctr_reg;
  reg [3 : 0]   round_ctr_new;
  reg           round_ctr_rst;
  reg           round_ctr_inc;
  reg           round_ctr_we;

  reg  [1 : 0]  ascon_permutation_ctrl_reg;
  reg  [1 : 0]  ascon_permutation_ctrl_new;
  reg  [1 : 0]  ascon_permutation_ctrl_we;


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign ready  = ready_reg;
  assign state = {s0_reg, s1_reg, s2_reg, s3_reg, s4_reg};


  //----------------------------------------------------------------
  // reg_update
  //
  // Update functionality for all registers in the core.
  // All registers are positive edge triggered with asynchronous
  // active low reset.
  //----------------------------------------------------------------
  always @ (posedge clk or negedge reset_n)begin: reg_update
    if (!reset_n) begin
      s0_reg                     <= 64'h0;
      s1_reg                     <= 64'h0;
      s2_reg                     <= 64'h0;
      s3_reg                     <= 64'h0;
      s4_reg                     <= 64'h0;
      ready_reg                  <= 1'h1;
      num_rounds_reg             <= 4'h0;
      round_ctr_reg              <= 4'h0;
      ascon_permutation_ctrl_reg <= CTRL_IDLE;
    end

    else begin
      if (state_we) begin
        s0_reg <= s0_new;
        s1_reg <= s1_new;
        s2_reg <= s2_new;
        s3_reg <= s3_new;
        s4_reg <= s4_new;
      end

      if (ready_we) begin
        ready_reg <= ready_new;
      end
      
      if (num_rounds_we) begin
        num_rounds_reg <= num_rounds;
      end
      
      if (round_ctr_we) begin
	    round_ctr_reg <= round_ctr_new;
      end
      
      if (ascon_permutation_ctrl_we) begin
        ascon_permutation_ctrl_reg <= ascon_permutation_ctrl_new;
      end
    end
  end // reg_update


  //----------------------------------------------------------------
  // state_logic
  // The actual logic to initialize and update the state.
  // The state logic is a composition of PL, PS and PC.
  //----------------------------------------------------------------
  always @*
    begin : state_logic
      integer i;
      reg [4 : 0] ps_in;
      reg [4 : 0] ps_out;
      
      reg [63 : 0] s0_pc;
      reg [63 : 0] s0_ps;
      reg [63 : 0] s0_ls;

      reg [63 : 0] s1_ps;
      reg [63 : 0] s1_ls;

      reg [63 : 0] s2_ps;
      reg [63 : 0] s2_ls;

      reg [63 : 0] s3_ps;
      reg [63 : 0] s3_ls;

      reg [63 : 0] s4_ps;
      reg [63 : 0] s4_ls;
      
      // Constant addition
      s0_pc = pc(s0_reg, round_ctr_reg);

      // Substitution
      for (i = 0 ; i < 64 ; i = i + 1) begin
        ps_in = {s4_reg[i], s3_reg[i], s2_reg[i], s1_reg[i], s0_pc[i]}; 
        ps_out = ps(ps_in);

        s0_ps[i] = ps_out[0];
        s1_ps[i] = ps_out[1];
        s2_ps[i] = ps_out[2];
        s3_ps[i] = ps_out[3];
        s4_ps[i] = ps_out[4];
      end
      
      // Linear diffusion
      s0_ls = pls0(s0_ps);
      s1_ls = pls1(s1_ps);
      s2_ls = pls2(s2_ps);
      s3_ls = pls3(s3_ps);
      s4_ls = pls4(s4_ps);

      // state update mux
      if (state_set) begin
        s0_new = block[319 : 256];
        s1_new = block[255 : 192];
        s2_new = block[191 : 128];
        s3_new = block[127 : 064];
        s4_new = block[063 : 000];
      end
      else begin
        s0_new = s0_ls;
        s1_new = s1_ls;
        s2_new = s2_ls;
        s3_new = s3_ls;
        s4_new = s4_ls;
      end
    end // round_logic  
  

  //----------------------------------------------------------------
  // round_ctr_logic
  //----------------------------------------------------------------
  always @*
    begin : round_ctr
      round_ctr_we  = 1'h0;

      if (round_ctr_rst) begin
        round_ctr_new = 4'h0;
	    round_ctr_we  = 1'h1;
      end

      if (round_ctr_inc) begin
	    round_ctr_new = round_ctr_reg + 1'h1;
	    round_ctr_we  = 1'h1;
      end
    end


  //----------------------------------------------------------------
  // ascon_permutation_ctrl
  //
  // Control FSM for the permutation.
  //----------------------------------------------------------------
  always @*
    begin : ascon_permutation_ctrl
      state_set                  = 1'h0;
      state_we                   = 1'h0;
      num_rounds_we              = 1'h0;
      ready_new                  = 1'h0;
      ready_we                   = 1'h0;
      round_ctr_rst              = 1'h0;
      round_ctr_inc              = 1'h0;
      ascon_permutation_ctrl_new = CTRL_IDLE;
      ascon_permutation_ctrl_we  = 1'h0;
      
      case (ascon_permutation_ctrl_reg)
        CTRL_IDLE: begin
          if (start) begin
            state_set      = 1'h1;
            state_we       = 1'h1;
            num_rounds_we  = 1'h1;
            round_ctr_rst  = 1'h1;
	        ready_new      = 1'h0;
	        ready_we       = 1'h1;
            ascon_permutation_ctrl_new = CTRL_ROUNDS;
            ascon_permutation_ctrl_we  = 1'h1;
          end
        end
          
        CTRL_ROUNDS: begin
          if (round_ctr_reg == num_rounds_reg) begin
	        ready_new      = 1'h1;
	        ready_we       = 1'h1;
            ascon_permutation_ctrl_new = CTRL_IDLE;
            ascon_permutation_ctrl_we  = 1'h1;
          end else begin
            state_we       = 1'h1;
            round_ctr_inc  = 1'h1;
          end
        end

        default: begin end
      endcase // case (ascon_permutation_ctrl_reg)
    end // ascon_permutation_ctrl

endmodule // ascon_core

//======================================================================
// EOF ascon_core.v
//======================================================================
