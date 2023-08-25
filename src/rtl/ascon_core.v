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
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  reg [63 : 0] x0_reg;
  reg [63 : 0] x0_new;
  reg          x0_we;

  reg [63 : 0] x1_reg;
  reg [63 : 0] x1_new;
  reg          x1_we;

  reg [63 : 0] x2_reg;
  reg [63 : 0] x2_new;
  reg          x2_we;

  reg [63 : 0] x3_reg;
  reg [63 : 0] x3_new;
  reg          x3_we;

  reg [63 : 0] x4_reg;
  reg [63 : 0] x4_new;
  reg          x4_we;

  reg          ready_reg;
  reg          ready_new;
  reg          ready_we;

  reg [2 : 0]  core_ctrl_reg;
  reg [2 : 0]  core_ctrl_new;
  reg          core_ctrl_we;

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
      x0_reg        <= 64'h0;
      x1_reg        <= 64'h0;
      x2_reg        <= 64'h0;
      x3_reg        <= 64'h0;
      x4_reg        <= 64'h0;
      result_reg    <= 128'h0;
      core_ctrl_reg <= CTRL_IDLE;
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

      if (result_we) begin
	result_reg <= result_new;
      end

      if (core_ctrl_we) begin
        core_ctrl_reg <= core_ctrl_new;
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
  // ascon_core_ctrl
  //
  // Control FSM for aes core.
  //----------------------------------------------------------------
  always @*
    begin : ascon_core_ctrl
      result_we     = 1'h0;
      ready_new     = 1'h0;
      ready_we      = 1'h0;
      state_init    = 1'h0
      state_update  = 1'h0
      core_ctrl_new = CTRL_IDLE;
      core_ctrl_we  = 1'h0;

      result_new = block ^ key;

      case (core_ctrl_reg)
        CTRL_IDLE: begin
          if (next) begin
	    result_we     = 1'h1;
	    ready_new     = 1'h0;
	    ready_we      = 1'h1;
            core_ctrl_new = CTRL_DONE;
            core_ctrl_we  = 1'h1;
          end
        end

        CTRL_DONE: begin
          ready_new     = 1'h1;
          ready_we      = 1'h1;
          core_ctrl_new = CTRL_IDLE;
          core_ctrl_we  = 1'h1;
        end

        default: begin end
      endcase // case (core_ctrl_reg)
    end // ascon_core_ctrl

endmodule // ascon_core

//======================================================================
// EOF ascon_core.v
//======================================================================
