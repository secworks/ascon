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
  // Wires.
  //----------------------------------------------------------------
  reg [63 : 0] tmp_x0;
  reg [63 : 0] tmp_x1;
  reg [63 : 0] tmp_x2;
  reg [63 : 0] tmp_x3;
  reg [63 : 0] tmp_x4;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports.
  //----------------------------------------------------------------
  assign x0_prim = tmp_x0;
  assign x1_prim = tmp_x1;
  assign x2_prim = tmp_x2;
  assign x3_prim = tmp_x3;
  assign x4_prim = tmp_x4;


  //----------------------------------------------------------------
  // p_logic
  //----------------------------------------------------------------
  always @*
    begin : p_logic
      tmp_x0 = x0;
      tmp_x1 = x1;
      tmp_x2 = x2;
      tmp_x3 = x3;
      tmp_x4 = x4;
    end // p_logic

endmodule // ascon_permutation

//======================================================================
// EOF ascon_permutation.v
//======================================================================
