//======================================================================
//
// ascon_core.v
// -------------
// Ascon block cipher core.
//
//
// Author: Joachim Strombergson
// Copyright (c) 2019, Assured AB
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

module ascon_core(
                   input wire            clk,
                   input wire            reset_n,

                   input wire            encdec,
                   input wire            init,
                   input wire            next,
                   output wire           ready,

                   input wire [127 : 0]  key,

                   input wire [127 : 0]  block,
                   output wire [127 : 0] result
                  );


  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  localparam CTRL_IDLE = 3'h0;
  localparam CTRL_DONE = 3'h4;


  //----------------------------------------------------------------
  // functions.
  //----------------------------------------------------------------
  // add round constants - pc
  function [63 : 0] pc(input [63 : 0] x, input [3 : 0] r);
    begin
      reg [7 : 0] xor_val;
      case (r)
	0:  xor_val = x[7 : 0] ^ 8'hf0;
	1:  xor_val = x[7 : 0] ^ 8'he1;
	2:  xor_val = x[7 : 0] ^ 8'hd2;
	3:  xor_val = x[7 : 0] ^ 8'hc3;
	4:  xor_val = x[7 : 0] ^ 8'hb4;
	5:  xor_val = x[7 : 0] ^ 8'ha5;
	6:  xor_val = x[7 : 0] ^ 8'h96;
	7:  xor_val = x[7 : 0] ^ 8'h87;
	8:  xor_val = x[7 : 0] ^ 8'h78;
	9:  xor_val = x[7 : 0] ^ 8'h69;
	10: xor_val = x[7 : 0] ^ 8'h5a;
	11: xor_val = x[7 : 0] ^ 8'h4b;
	default begin
	  xor_val = x[7 : 0];
	end
      endcase
      pc = {x[63 : 8], xor_val};
    end
  endfunction // pc

  // apply substitution - ps
  function [4 : 0] ps(input [4 : 0] x);
    begin
      ps = x;
    end
  endfunction // ps

  // linear layer - pl
  function [63 : 0] pl(input [63 : 0] x);
    begin
      pl = x;
    end
  endfunction // pl


  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  reg [63 : 0]  x0_reg;
  reg [63 : 0]  x0_new;
  reg           x0_we;

  reg [63 : 0]  x1_reg;
  reg [63 : 0]  x1_new;
  reg           x1_we;

  reg [63 : 0]  x2_reg;
  reg [63 : 0]  x2_new;
  reg           x2_we;

  reg [63 : 0]  x3_reg;
  reg [63 : 0]  x3_new;
  reg           x3_we;

  reg [63 : 0]  x4_reg;
  reg [63 : 0]  x4_new;
  reg           x4_we;

  reg           ready_reg;
  reg           ready_new;
  reg           ready_we;

  reg [3 : 0]   round_ctr_reg;
  reg [3 : 0]   round_ctr_new;
  reg           round_ctr_rst;
  reg           round_ctr_inc;
  reg           round_ctr_we;

  reg [2 : 0]   ascon_ctrl_reg;
  reg [2 : 0]   ascon_ctrl_new;
  reg           ascon_ctrl_we;

  reg [127 : 0] result_reg;
  reg [127 : 0] result_new;
  reg           result_we;


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg state_init;
  reg state_update;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign ready  = ready_reg;
  assign result = result_reg;


  //----------------------------------------------------------------
  // reg_update
  //
  // Update functionality for all registers in the core.
  // All registers are positive edge triggered with asynchronous
  // active low reset.
  //----------------------------------------------------------------
  always @ (posedge clk or negedge reset_n)begin: reg_update
    if (!reset_n) begin
      x0_reg         <= 64'h0;
      x1_reg         <= 64'h0;
      x2_reg         <= 64'h0;
      x3_reg         <= 64'h0;
      x4_reg         <= 64'h0;
      round_ctr_reg  <= 4'h0;
      result_reg     <= 128'h0;
      ascon_ctrl_reg <= CTRL_IDLE;
    end

    else begin
      if (x0_we) begin
	x0_reg <= x0_new;
      end

      if (x1_we) begin
	x1_reg <= x1_new;
      end

      if (x2_we) begin
	x2_reg <= x2_new;
      end

      if (x3_we) begin
	x3_reg <= x3_new;
      end

      if (x4_we) begin
	x4_reg <= x4_new;
      end

      if (round_ctr_we) begin
	round_ctr_reg <= round_ctr_new;
      end

      if (result_we) begin
	result_reg <= result_new;
      end

      if (ascon_ctrl_we) begin
        ascon_ctrl_reg <= ascon_ctrl_new;
      end
    end
  end // reg_update


  //----------------------------------------------------------------
  // state_logic
  // The actual logic to initialize and update the state.
  //----------------------------------------------------------------
  always @*
    begin : state_logic
      x0_we = 1'h0;
      x1_we = 1'h0;
      x2_we = 1'h0;
      x3_we = 1'h0;
      x4_we = 1'h0;

      x0_new = 64'h0;
      x1_new = 64'h0;
      x2_new = 64'h0;
      x3_new = 64'h0;
      x4_new = 64'h0;
    end


  //----------------------------------------------------------------
  // round_ctr_logic
  //----------------------------------------------------------------
  always @*
    begin : round_ctr
      round_ctr_new = 4'h0;
      round_ctr_we  = 1'h0;

      if (round_ctr_rst) begin
	round_ctr_we = 1'h1;
      end

      if (round_ctr_inc) begin
	round_ctr_new = round_ctr_reg + 1'h1;
	round_ctr_we  = 1'h1;
      end
    end


  //----------------------------------------------------------------
  // ascon_ctrl
  //
  // Control FSM for aes core.
  //----------------------------------------------------------------
  always @*
    begin : ascon_ctrl
      result_we      = 1'h0;
      ready_new      = 1'h0;
      ready_we       = 1'h0;
      state_init     = 1'h0;
      state_update   = 1'h0;
      round_ctr_rst  = 1'h0;
      round_ctr_inc  = 1'h0;
      ascon_ctrl_new = CTRL_IDLE;
      ascon_ctrl_we  = 1'h0;

      result_new = block ^ key;

      case (ascon_ctrl_reg)
        CTRL_IDLE: begin
          if (next) begin
	    result_we     = 1'h1;
	    ready_new     = 1'h0;
	    ready_we      = 1'h1;
            ascon_ctrl_new = CTRL_DONE;
            ascon_ctrl_we  = 1'h1;
          end
        end

        CTRL_DONE: begin
          ready_new     = 1'h1;
          ready_we      = 1'h1;
          ascon_ctrl_new = CTRL_IDLE;
          ascon_ctrl_we  = 1'h1;
        end

        default: begin end
      endcase // case (ascon_ctrl_reg)
    end // ascon_ctrl

endmodule // ascon_core

//======================================================================
// EOF ascon_core.v
//======================================================================
