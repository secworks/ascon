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

      $display("In ps function:");
      $display("x0: 0x%1x, x1: 0x%1x, x2: 0x%1x, x3: 0x%1x, x4: 0x%1x", x0, x1, x2, x3, x4);

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
      x3_2 = x3_1 ^ x4_2;
      x4_3 = x4_1 ^ x0_2;

      x0_4 = x0_3 ^ x4_3;
      x1_3 = x1_2 ^ x0_3;
      x2_4 = ~x2_3;
      x3_3 = x3_2 ^ x2_3;

      ps = {x0_4, x1_3, x2_4, x3_3, x4_3};

      $display("Leaving ps function.\n");
    end
  endfunction // ps


  initial
    begin : testloop
      integer j;
      reg [5 : 0] i;
      reg [4 : 0] x;
      reg [4 : 0] xs;

      for (i = 0 ; i < 32 ; i = i + 1) begin
	x = i[4 : 0];
	xs = ps(x);
	$display("x: 0x%01x, xs: 0x%01x", x, xs);
	#(1);
      end
    end
endmodule // tb_ps_function
