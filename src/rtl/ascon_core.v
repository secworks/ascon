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
                   input wire           clk,
                   input wire           reset_n,

                   input wire           encdec,
                   input wire           next,
                   output wire          ready,

                   input wire [127 : 0] key,

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
  reg          ready_reg;
  reg          ready_new;
  reg          ready_we;

  reg [2 : 0]  core_ctrl_reg;
  reg [2 : 0]  core_ctrl_new;
  reg          core_ctrl_we;


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign ready  = ready_reg;


  //----------------------------------------------------------------
  // reg_update
  //
  // Update functionality for all registers in the core.
  // All registers are positive edge triggered with asynchronous
  // active low reset.
  //----------------------------------------------------------------
  always @ (posedge clk or negedge reset_n)begin: reg_update
    if (!reset_n) begin
      core_ctrl_reg <= CTRL_IDLE;
    end

    else begin
      if (core_ctrl_we) begin
        core_ctrl_reg <= core_ctrl_new;
      end
    end
  end // reg_update


  //----------------------------------------------------------------
  // ascon_core_ctrl
  //
  // Control FSM for aes core.
  //----------------------------------------------------------------
  always @*
    begin : ascon_core_ctrl
      ready_new     = 1'h0;
      ready_we      = 1'h0;
      core_ctrl_new = CTRL_IDLE;
      core_ctrl_we  = 1'h0;

      case (core_ctrl_reg)
        CTRL_IDLE: begin
          if (next) begin
	    ready_new     = 1'h0;
	    ready_we      = 1'h1;
            core_ctrl_new = CTRL_DONE;
            core_ctrl_we  = 1'h1;
          end
        end

        CTRL_DONE: begin
          ready_new     = 1'h1;
          ready_we      = 1'h1;
          update_state  = 1'h1;
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
