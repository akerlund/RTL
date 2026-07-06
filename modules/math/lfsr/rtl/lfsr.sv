////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2026 Fredrik Åkerlund
// https://github.com/akerlund/RTL
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module lfsr #(
    parameter int                   WIDTH_P = 32,
    parameter logic [WIDTH_P-1 : 0] TAPS_P  = 32'h8000_0057,
    parameter logic [WIDTH_P-1 : 0] SEED_P  = 32'h0000_0001
  )(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  advance,
    input  wire                  cmd_load_seed,
    input  wire  [WIDTH_P-1 : 0] cr_seed,
    output logic [WIDTH_P-1 : 0] value,
    output logic                 bit_out
  );

  logic feedback;
  logic [WIDTH_P-1 : 0] next_state;

  function automatic logic [WIDTH_P-1 : 0] get_valid_seed(
      input logic [WIDTH_P-1 : 0] seed_in
    );
    begin
      if (seed_in == '0) begin
        if (SEED_P == '0) begin
          get_valid_seed = {{(WIDTH_P-1){1'b0}}, 1'b1};
        end
        else begin
          get_valid_seed = SEED_P;
        end
      end
      else begin
        get_valid_seed = seed_in;
      end
    end
  endfunction

  assign feedback   = ^(value & TAPS_P);
  assign next_state = {value[WIDTH_P-2 : 0], feedback};
  assign bit_out    = value[WIDTH_P-1];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      value <= get_valid_seed(SEED_P);
    end
    else if (cmd_load_seed) begin
      value <= get_valid_seed(cr_seed);
    end
    else if (advance) begin
      if (value == '0) begin
        value <= get_valid_seed(SEED_P);
      end
      else begin
        value <= next_state;
      end
    end
  end

  initial begin
    if (WIDTH_P < 2) begin
      $error("WIDTH_P must be at least 2");
    end

    if (TAPS_P == '0) begin
      $error("TAPS_P must not be zero");
    end
  end

endmodule

`default_nettype wire
