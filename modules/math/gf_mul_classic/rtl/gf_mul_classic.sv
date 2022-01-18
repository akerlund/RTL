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
    input  wire              clk,
    input  wire              rst_n,
    input  wire  [M_P-1 : 0] x0,
    input  wire  [M_P-1 : 0] x1,
    output logic [M_P-1 : 0] y
 );

 localparam logic [M_P - 1 : 0] POLY_C = 'b00011011;
 localparam int                 M      = M_P;

  // ---------------------------------------------------------------------------
  // Poly multiplier
  // multiplies two m-bit polynomials and gives a 2*m-1 bits polynomial.
  // ---------------------------------------------------------------------------

  logic [0 : 2*M-2] [2*M-2 : 0] a_by_b;
  logic                         xor_c0;
  logic             [2*M-2 : 0] y_c0;

  always_comb begin

    a_by_b = '0;

    // Generate AND lower
    for (int i = 0; i < M; i++) begin
      for (int j = 0; j <= i; j++) begin
        a_by_b[i][j] = x0[j] & x1[i-j];
      end
    end

    // Generate AND higher
    for (int i = M; i < (2*M - 1); i++) begin
      for (int j = i; j < (2*M - 1); j++) begin
        a_by_b[i][j] = x0[i - j + (M - 1)] & x1[j - (M - 1)];
      end
    end
  end

  assign y_c0[0] = a_by_b[0][0];

  // Generate XOR
  always_comb begin
    xor_c0          = '0;
    y_c0[2*M-2 : 1] = '0;
    for (int i = 1; i < (2*M - 1); i++) begin
      if (i < M) begin
        xor_c0 = a_by_b[i][0];
        for (int j = 1; j <= i; j++) begin
          xor_c0 = a_by_b[i][j] ^ xor_c0;
        end
      end
      else begin
        xor_c0 = a_by_b[i][i];
        for (int j = (i + 1); j < (2*M - 1); j++) begin
          xor_c0 = a_by_b[i][j] ^ xor_c0;
        end
      end
      y_c0[i] = xor_c0;
    end
  end

  // ---------------------------------------------------------------------------
  // Matrix reduction function
  // ---------------------------------------------------------------------------

  typedef logic [0 : M-1] [M-2 : 0] mat_red_t;

  function mat_red_t get_matrix_reduction();

    mat_red_t mat_red;

    // Zeros
    for (int i = 0; i < M; i++) begin
      for (int j = 0; j < (M - 1); j++) begin
        mat_red[i][j] = '0;
      end
    end

    // Poly
    for (int i = 0; i < M; i++) begin
      mat_red[i][0] = POLY_C[i];
    end

    // AND/XOR
    for (int i = 1; i < (M - 1); i++) begin
      for (int j = 0; j < M; j++) begin
        if (j == 0) begin
          mat_red[j][i] = mat_red[M - 1][i - 1] && mat_red[j][0];
        end
        else begin
          mat_red[j][i] = mat_red[j - 1][i - 1] ^ (mat_red[M - 1][i - 1] & mat_red[j][0]);
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

  logic           xor_c1;
  logic [M-1 : 0] y_c1;

  // AND/XOR
  always_comb begin
    xor_c1 = '0;
    y_c1   = '0;
    for (int i = 0; i < M; i++) begin
      xor_c1 = y_c0[i];
      for (int j = 0; j < (M - 1); j++) begin
        xor_c1 = xor_c1 ^ (y_c0[M + j] & MAT_RED_C[i][j]);
      end
      y_c1[i] = xor_c1;
    end
  end

  assign y = y_c1;

endmodule

`default_nettype wire
