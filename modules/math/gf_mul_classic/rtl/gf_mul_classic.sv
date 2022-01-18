////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2022 Fredrik Åkerlund
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

module gf_mul_classic #(
    parameter int M_P = 8
  )(
    input  wire                clk,
    input  wire                rst_n,
    input  wire    [M_P-1 : 0] x0,
    input  wire    [M_P-1 : 0] x1,
    output logic [2*M_P-2 : 0] y
 );

  localparam logic [M_P - 1 : 0] POLY_C = 'b00011011;

  // ---------------------------------------------------------------------------
  // Poly multiplier
  // multiplies two m-bit polynomials and gives a 2*m-1 bits polynomial.
  // ---------------------------------------------------------------------------

  logic [(2 * M_P) - 2 : 0] [(2 * M_P) - 2 : 0] a_by_b;

  // Generate AND lower
  always_comb begin
    for (int i = 0; i < (M_P - 1); i++) begin
      for (int j = 0; j <= i; j++) begin
        a_by_b[i][j] <= x0[j] && x1[i-j];
      end
    end
  end

  // Generate AND higher
  always_comb begin
    for (int i = 0; i < (2*M_P - 2); i++) begin
      for (int j = i; j <= (2*M_P - 2); j++) begin
        a_by_b[i][j] = x0[i - j + M_P - 1] && x1[j - M_P - 1];
      end
    end
  end

  // Generate XOR
  assign y[0] = a_by_b [0][0];
  logic               xor_c0;
  logic [2*M_P-2 : 0] y_c0;
  always_comb begin
    xor_c0 = 0;
    for (int i = 1; i < (2*M_P - 2); i++) begin
      if (i < M_P) begin
        for (int j = 1; j <= i; j++) begin
          xor_c0 = a_by_b[i][j] ^ xor_c0;
        end
      end
      else begin
        for (int j = (i + 1); j <= (2*M_P - 2); j++) begin
          xor_c0 = a_by_b[i][j] ^ xor_c0;
        end
      end
      y_c0[i] = xor_c0;
    end
  end

  // ---------------------------------------------------------------------------
  // Matrix reduction function
  // ---------------------------------------------------------------------------

  typedef logic [0 : (M_P - 1)] [M_P - 2 : 0] mat_red_t;

  function mat_red_t get_matrix_reduction();

    mat_red_t mat_red;

    // Zeros
    for (int i = 0; i < (M_P - 1); i++) begin
      for (int j = 0; j <= (M_P - 2); j++) begin
        mat_red[i][j] = '0;
      end
    end

    // Poly
    for (int i = 0; i < (M_P - 1); i++) begin
      mat_red[i][0] = POLY_C[i];
    end

    // AND/XOR
    for (int i = 1; i < (M_P - 1); i++) begin
      for (int j = i; j < M_P; j++) begin
        if (j == 0) begin
          mat_red[j][i] = mat_red[M_P - 1][i - 1] && mat_red[j][0];
        end
        else begin
          mat_red[j][i] = mat_red[j - 1][i - 1] ^ (mat_red[M_P - 1][i - 1] & mat_red[j][0]);
        end
      end
    end

    get_matrix_reduction = mat_red;
  endfunction

  // ---------------------------------------------------------------------------
  // Poly reducer
  // reduces a (2*m-1)- bit polynomial by f to an m-bit polinomial
  // ---------------------------------------------------------------------------

  localparam mat_red_t MAT_RED_C = get_matrix_reduction();

  mat_red_t mat_red;
  logic xor_c1;
  always_comb begin
    mat_red = MAT_RED_C;
    for (int i = 0; i < M_P; i++) begin
      xor_c1 = y[i];
      for (int j = 0; j < (M_P - 1); j++) begin
        xor_c1 = xor_c1 ^ (y_c0[M_P + j] & mat_red[i][j]);
      end
      y = xor_c1;
    end
  end

endmodule

`default_nettype wire
