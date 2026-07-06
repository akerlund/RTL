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

module long_division_core #(
    parameter int N_BITS_P = -1,
    parameter int Q_BITS_P = -1
  )(
    input  wire                          clk,
    input  wire                          rst_n,

    input  wire                          ing_valid,
    output logic                         ing_ready,
    input  wire  signed [N_BITS_P-1 : 0] ing_dividend,
    input  wire  signed [N_BITS_P-1 : 0] ing_divisor,

    output logic                         egr_valid,
    output logic signed [N_BITS_P-1 : 0] egr_quotient,
    output logic signed [N_BITS_P-1 : 0] egr_remainder,
    output logic                         egr_overflow
  );

  localparam int EXT_WIDTH_C = (2*N_BITS_P) + Q_BITS_P + 1;

  logic signed [EXT_WIDTH_C-1 : 0] scaled_dividend;
  logic signed [EXT_WIDTH_C-1 : 0] extended_divisor;
  logic signed [EXT_WIDTH_C-1 : 0] safe_divisor;
  logic signed [EXT_WIDTH_C-1 : 0] quotient;
  logic signed [EXT_WIDTH_C-1 : 0] remainder;
  logic signed [EXT_WIDTH_C-1 : 0] max_value;
  logic signed [EXT_WIDTH_C-1 : 0] min_value;
  logic                            result_overflow;

  assign scaled_dividend = $signed({{(EXT_WIDTH_C-N_BITS_P){ing_dividend[N_BITS_P-1]}}, ing_dividend}) <<< Q_BITS_P;
  assign extended_divisor = $signed({{(EXT_WIDTH_C-N_BITS_P){ing_divisor[N_BITS_P-1]}}, ing_divisor});
  assign safe_divisor = (ing_divisor == '0) ? {{(EXT_WIDTH_C-1){1'b0}}, 1'b1} : extended_divisor;
  assign quotient = scaled_dividend / safe_divisor;
  assign remainder = scaled_dividend % safe_divisor;
  assign max_value = ({{(EXT_WIDTH_C-1){1'b0}}, 1'b1} <<< (N_BITS_P-1)) - 1'b1;
  assign min_value = -({{(EXT_WIDTH_C-1){1'b0}}, 1'b1} <<< (N_BITS_P-1));
  assign result_overflow = (ing_divisor == '0) || (quotient > max_value) || (quotient < min_value);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ing_ready     <= '1;
      egr_valid     <= '0;
      egr_quotient  <= '0;
      egr_remainder <= '0;
      egr_overflow  <= '0;
    end
    else begin
      ing_ready <= '1;
      egr_valid <= '0;

      if (ing_valid) begin
        egr_valid    <= '1;
        egr_overflow <= result_overflow;

        if (result_overflow) begin
          egr_quotient  <= '0;
          egr_remainder <= '0;
        end
        else begin
          egr_quotient  <= quotient[N_BITS_P-1 : 0];
          egr_remainder <= remainder[N_BITS_P-1 : 0];
        end
      end
    end
  end

endmodule

`default_nettype wire
