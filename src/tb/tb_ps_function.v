//======================================================================
//
// tb_ps_function.v
// ----------------
// Testbench for the PS function, performing substitution.
// Reference function from Ascon specification:
// https://ascon.iaik.tugraz.at/files/asconv12-nist.pdf
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

module tb_ps_function();
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

  function [4 : 0] ref_ps(input [4 : 0] x);
    begin : ref_ps
      reg x0, t0;
      reg x1, t1;
      reg x2, t2;
      reg x3, t3;
      reg x4, t4;

      x0 = x[4];
      x1 = x[3];
      x2 = x[2];
      x3 = x[1];
      x4 = x[0];

      x0 = x0 ^ x4;
      x2 = x2 ^ x1;
      x4 = x4 ^ x3;

      t0  = x0;
      t1  = x1;
      t2  = x2;
      t3  = x3;
      t4  = x4;

      t0 = ~t0;
      t1 = ~t1;
      t2 = ~t2;
      t3 = ~t3;
      t4 = ~t4;

      t0 = t0 & x1;
      t1 = t1 & x2;
      t2 = t2 & x3;
      t3 = t3 & x4;
      t4 = t4 & x0;

      x0 = x0 ^ t1;
      x1 = x1 ^ t2;
      x2 = x2 ^ t3;
      x3 = x3 ^ t4;
      x4 = x4 ^ t0;

      x1 = x1 ^ x0;
      x0 = x0 ^ x4;
      x3 = x3 ^ x2;
      x2 = ~x2;

      ref_ps = {x0, x1, x2, x3, x4};
    end
  endfunction // ref_ps


  initial
    begin : testloop
      integer j;
      reg [5 : 0] i;
      reg [4 : 0] x;
      reg [4 : 0] xs;
      reg [4 : 0] ref_xs;

      for (i = 0 ; i < 32 ; i = i + 1) begin
	x = i[4 : 0];
	xs = ps(x);
	ref_xs = ref_ps(x);
	$display("x: 0x%01x, xs: 0x%01x  <-->  xrf_xs: 0x%01x", x, xs, ref_xs);
	#(1);
      end
    end
endmodule // tb_ps_function
