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

module dsp48_nq_multiplier #(
    parameter N_BITS_P = -1,
    parameter Q_BITS_P = -1
  )(
    input  wire                    clk,
    input  wire                    rst_n,
    input  wire   [N_BITS_P-1 : 0] ing_multiplicand,
    input  wire   [N_BITS_P-1 : 0] ing_multiplier,
    output logic  [N_BITS_P-1 : 0] egr_product,
    output logic                   egr_overflow
  );

  logic [2*N_BITS_P-1 : 0] product_c0;
  logic                    sign_bit;

  assign product_c0 = $signed(ing_multiplicand) * $signed(ing_multiplier);
  assign sign_bit   = ing_multiplicand[N_BITS_P-1] ^ ing_multiplier[N_BITS_P-1];

  always_ff @(posedge clk) begin
    if (clk) begin
      if (!rst_n) begin
        egr_product  <= '0;
        egr_overflow <= '0;
      end
      else begin

        egr_product[N_BITS_P-1 : 0] <= product_c0[N_BITS_P-1+Q_BITS_P : Q_BITS_P];
        egr_overflow                <= sign_bit ? product_c0[2*N_BITS_P-1 : N_BITS_P+Q_BITS_P] != '1 :
                                                  product_c0[2*N_BITS_P-1 : N_BITS_P+Q_BITS_P] != '0;

      end
    end
  end

endmodule

`default_nettype wire

