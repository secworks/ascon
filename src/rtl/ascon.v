//======================================================================
//
// ascon.v
// --------
// Top level wrapper for the ASCON block cipher core.
//
//
// Author: Joachim Strombergson
// Copyright (c) 2020, Assured AB
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

module ascon(
              // Clock and reset.
              input wire           clk,
              input wire           reset_n,

              // Control.
              input wire           cs,
              input wire           we,

              // Data ports.
              input wire  [7 : 0]  address,
              input wire  [31 : 0] write_data,
              output wire [31 : 0] read_data
             );


  //----------------------------------------------------------------
  // Internal constant and parameter definitions.
  //----------------------------------------------------------------
  localparam ADDR_NAME0        = 8'h00;
  localparam ADDR_NAME1        = 8'h01;
  localparam ADDR_VERSION      = 8'h02;

  localparam ADDR_CTRL         = 8'h08;
  localparam CTRL_NEXT_BIT     = 0;

  localparam ADDR_STATUS       = 8'h09;
  localparam STATUS_READY_BIT  = 0;

  localparam ADDR_CONFIG       = 8'h0a;
  localparam CONFIG_ENCDEC_BIT = 0;
  localparam CONFIG_AD_BIT     = 1;
  localparam CONFIG_NONCE_BIT  = 2;

  localparam ADDR_KEY0         = 8'h10;
  localparam ADDR_KEY3         = 8'h13;

  localparam ADDR_BLOCK0       = 8'h20;
  localparam ADDR_BLOCK1       = 8'h21;
  localparam ADDR_BLOCK2       = 8'h22;
  localparam ADDR_BLOCK3       = 8'h23;

  localparam ADDR_RESULT0      = 8'h30;
  localparam ADDR_RESULT1      = 8'h31;
  localparam ADDR_RESULT2      = 8'h32;
  localparam ADDR_RESULT3      = 8'h33;

  localparam CORE_NAME0        = 32'h6173636f; // "asco"
  localparam CORE_NAME1        = 32'h6e652020; // "n   "
  localparam CORE_VERSION      = 32'h302e3130; // "0.10"


  //----------------------------------------------------------------
  // Registers including update variables and write enable.
  //----------------------------------------------------------------
  reg ad_reg;
  reg config_we;

  reg init_reg;
  reg init_new;

  reg next_reg;
  reg next_new;

  reg finalize_reg;
  reg finalize_new;


  reg [31 : 0] block_reg [0 : 3];
  reg          block_we;

  reg [31 : 0] key_reg [0 : 3];
  reg          key_we;


  //----------------------------------------------------------------
  // Wires.
  //----------------------------------------------------------------
  reg [31 : 0]   tmp_read_data;

  wire [127 : 0] core_key;
  wire [127 : 0] core_nonce;
  wire [127 : 0] core_data;
  wire [2 : 0]   core_mode;
  wire [127 : 0] core_result;
  wire           core_fail;
  wire           core_ready;


  //----------------------------------------------------------------
  // Concurrent connectivity for ports etc.
  //----------------------------------------------------------------
  assign read_data = tmp_read_data;

  assign core_key  = {key_reg[3], key_reg[2], key_reg[1], key_reg[0]};
  assign core_data = {block_reg[3], block_reg[2], block_reg[1], block_reg[0]};


  //----------------------------------------------------------------
  // core instantiation.
  //----------------------------------------------------------------
  ascon_core core(
                  .clk(clk),
                  .reset_n(reset_n),

                  .init(init_reg),
                  .next(next_reg),
                  .finalize(finalize_reg),
                  .mode(core_mode),
                  
                  .key(core_key),
                  .nonce(core_nonce),
                  .data(core_data),

                  .result(core_result),
                  .fail(core_fail),
                  .ready(core_ready)
                 );


  //----------------------------------------------------------------
  // reg_update
  // Update functionality for all registers in the core.
  // All registers are positive edge triggered with asynchronous
  // active low reset.
  //----------------------------------------------------------------
  always @ (posedge clk or negedge reset_n)
    begin : reg_update
      integer i;

      if (!reset_n) begin
        for (i = 0 ; i < 4 ; i = i + 1) begin
          block_reg[i] <= 32'h0;
          key_reg[i]   <= 32'h0;
	    end
        init_reg     <= 1'h0;
        next_reg     <= 1'h0;
        finalize_reg <= 1'h0;
      end
      else begin
        init_reg     <= init_new;
        next_reg     <= next_new;
        finalize_reg <= finalize_new;

        if (key_we) begin
          key_reg[address[1 : 0]] <= write_data;
	    end

        if (block_we) begin
          block_reg[address[0]] <= write_data;
        end
      end
    end // reg_update
  

  //----------------------------------------------------------------
  // api
  //
  // The interface command decoding logic.
  //----------------------------------------------------------------
  always @*
    begin : api
      init_new      = 1'h0;
      next_new      = 1'h0;
      finalize_new  = 1'h0;
      config_we     = 1'h0;
      key_we        = 1'h0;
      block_we      = 1'h0;
      tmp_read_data = 32'h0;

      if (cs) begin
          if (we) begin
            if (core_ready) begin
              if (address == ADDR_CTRL) begin
                next_new = write_data[CTRL_NEXT_BIT];
	      end

	      if (address == ADDR_CONFIG) begin
                    config_we = 1'h1;
	      end

              if ((address >= ADDR_KEY0) && (address <= ADDR_KEY3)) begin
                key_we = 1'h1;
	      end

              if ((address >= ADDR_BLOCK0) && (address <= ADDR_BLOCK3)) begin
                block_we = 1'h1;
              end
            end
	  end

          else begin
            case (address)
              ADDR_NAME0:   tmp_read_data = CORE_NAME0;
              ADDR_NAME1:   tmp_read_data = CORE_NAME1;
              ADDR_VERSION: tmp_read_data = CORE_VERSION;
              ADDR_STATUS:  tmp_read_data = {31'h0, core_ready};
              ADDR_RESULT0: tmp_read_data = core_result[031 : 000];
              ADDR_RESULT1: tmp_read_data = core_result[063 : 032];
              ADDR_RESULT2: tmp_read_data = core_result[095 : 064];
              ADDR_RESULT3: tmp_read_data = core_result[127 : 096];

	      default: begin end
            endcase // case (address)
          end
      end
    end // addr_decoder
endmodule // ascon

//======================================================================
// EOF ascon.v
//======================================================================
