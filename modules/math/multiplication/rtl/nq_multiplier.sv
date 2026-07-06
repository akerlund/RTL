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

module nq_multiplier #(
    parameter int N_BITS_P = 32,
    parameter int Q_BITS_P = 15
  )(
    input  wire                          clk,
    input  wire                          rst_n,

    input  wire                          ing_valid,
    output logic                         ing_ready,
    input  wire  signed [N_BITS_P-1 : 0] ing_multiplicand,
    input  wire  signed [N_BITS_P-1 : 0] ing_multiplier,

    output logic                         egr_valid,
    output logic signed [N_BITS_P-1 : 0] egr_product,
    output logic                         egr_overflow
  );

  localparam int PRODUCT_WIDTH_C = 2*N_BITS_P;

  logic signed [PRODUCT_WIDTH_C-1 : 0] full_product;
  logic signed [PRODUCT_WIDTH_C-1 : 0] scaled_product;
  logic signed [PRODUCT_WIDTH_C-1 : 0] max_value;
  logic signed [PRODUCT_WIDTH_C-1 : 0] min_value;
  logic                                result_overflow;

  assign full_product = ing_multiplicand * ing_multiplier;
  assign scaled_product = full_product >>> Q_BITS_P;
  assign max_value = ({{(PRODUCT_WIDTH_C-1){1'b0}}, 1'b1} <<< (N_BITS_P-1)) - 1'b1;
  assign min_value = -({{(PRODUCT_WIDTH_C-1){1'b0}}, 1'b1} <<< (N_BITS_P-1));
  assign result_overflow = (scaled_product > max_value) || (scaled_product < min_value);

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ing_ready    <= '1;
      egr_valid    <= '0;
      egr_product  <= '0;
      egr_overflow <= '0;
    end
    else begin
      ing_ready <= '1;
      egr_valid <= '0;

      if (ing_valid) begin
        egr_valid    <= '1;
        egr_overflow <= result_overflow;
        egr_product  <= result_overflow ? '0 : scaled_product[N_BITS_P-1 : 0];
      end
    end
  end

endmodule

`default_nettype wire
