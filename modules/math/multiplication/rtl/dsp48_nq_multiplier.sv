////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
// https://github.com/akerlund/RTL
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
// Description:
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

