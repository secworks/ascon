//======================================================================
//
// ascon_permutation.v
// -------------------
// Verilog 2001 implementation of the Ascon permutation.
//
//
// Author: Joachim Strömbergson
// Copyright (c) 2022, Assured AB
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
			 input wire [63 : 0]  x0,
			 input wire [63 : 0]  x1,
			 input wire [63 : 0]  x2,
			 input wire [63 : 0]  x3,
			 input wire [63 : 0]  x4,

			 output wire [63 : 0] x0_prim,
			 output wire [63 : 0] x1_prim,
			 output wire [63 : 0] x2_prim,
			 output wire [63 : 0] x3_prim,
			 output wire [63 : 0] x4_prim
			);


  //----------------------------------------------------------------
  // P functions
  //----------------------------------------------------------------
  function [4 : 0] ps(input [4 : 0] x);
    begin : ps
      reg x0, x0_1, x0_2, x0_3, x0_4;
      reg x1, x1_1, x1_2, x1_3;
      reg x2, x2_1, x2_2, x2_3, x2_4;
      reg x3, x3_1, x3_2, x3_3;
      reg x4, x4_1, x4_2, x4_3;

      x0 = x[4];
      x1 = x[3];
      x2 = x[2];
      x3 = x[1];
      x4 = x[0];

      x0_1 = x0 ^ x4;
      x2_1 = x2 ^ x1;
      x4_1 = x4 ^ x3;

      x0_2 = ~x0_1 & x1;
      x1_1 = ~x1 & x2_1;
      x2_2 = ~x2_1 & x3;
      x3_1 = ~x3 & x4_1;
      x4_2 = ~x4_1 & x0_1;

      x0_3 = x0_1 ^ x1_1;
      x1_2 = x1 ^ x2_2;
      x2_3 = x2_1 ^ x3_1;
      x3_2 = x3 ^ x4_2;
      x4_3 = x4_1 ^ x0_2;

      x0_4 = x0_3 ^ x4_3;
      x1_3 = x1_2 ^ x0_3;
      x2_4 = ~x2_3;
      x3_3 = x3_2 ^ x2_3;

      ps = {x0_4, x1_3, x2_4, x3_3, x4_3};
    end
  endfunction // ps


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg [63 : 0] ps_x0;
  reg [63 : 0] ps_x1;
  reg [63 : 0] ps_x2;
  reg [63 : 0] ps_x3;
  reg [63 : 0] ps_x4;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports.
  //----------------------------------------------------------------
  assign x0_prim = ps_x0;
  assign x1_prim = ps_x1;
  assign x2_prim = ps_x2;
  assign x3_prim = ps_x3;
  assign x4_prim = ps_x4;


  //----------------------------------------------------------------
  // ps_logic
  //----------------------------------------------------------------
  always @*
    begin : ps_logic
      integer i;
      reg [4 : 0] x;
      reg [4 : 0] xp;

      for (i = 0 ; i < 64 ; i = i + 1) begin
	x[4] = x0[i];
	x[3] = x1[i];
	x[2] = x2[i];
	x[1] = x3[i];
	x[0] = x4[i];

	xp = ps(x);

	ps_x0[i] = xp[4];
	ps_x1[i] = xp[3];
	ps_x2[i] = xp[2];
	ps_x3[i] = xp[1];
	ps_x4[i] = xp[0];
      end
    end // ps_logic

endmodule // ascon_permutation

//======================================================================
// EOF ascon_permutation.v
//======================================================================
