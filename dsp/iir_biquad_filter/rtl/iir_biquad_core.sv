////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
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
// Description: Digital bi-quad filter, containing two poles and two zeros.
// "Biquad" is an abbreviation of "biquadratic", which refers to the fact that
// in the Z domain, its transfer function is the ratio of
// two quadratic functions:
//
//        b0 + b1 * z^-1 + b2 * z^-2
// H(z) = --------------------------
//        a0 + a1 * z^-1 + a2 * z^-2
//
// Normalized output (a0 = 0) for a second order IIR filter in Direct-Form I:
//
// y[n] = b0*x[n] + b1*x[n-1] + b2*[x-2] - a1*y[n-1] - a2*y[n-2]
//
// The b coefficients determine zeros and the a coefficients determine the
// position of the poles.
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module iir_biquad_core #(
    parameter int N_BITS_P = -1,
    parameter int Q_BITS_P = -1
  )(
    // Clock and reset
    input  wire                          clk,
    input  wire                          rst_n,

    // Inputs (x)
    input  wire  signed [N_BITS_P-1 : 0] x0,
    input  wire                          x0_valid,
    output logic                         x0_ready,

    // Output (y)
    output logic                         y0_valid,
    output logic signed [N_BITS_P-1 : 0] y0,

    // Coefficients
    input  wire  signed [N_BITS_P-1 : 0] cr_pole_a1,
    input  wire  signed [N_BITS_P-1 : 0] cr_pole_a2,
    input  wire  signed [N_BITS_P-1 : 0] cr_zero_b0,
    input  wire  signed [N_BITS_P-1 : 0] cr_zero_b1,
    input  wire  signed [N_BITS_P-1 : 0] cr_zero_b2
  );

  localparam int MUL_HIGH_C = N_BITS_P - 1;
  localparam int MUL_LOW_C  = Q_BITS_P;

  typedef enum {
    STAGE_0_E,
    STAGE_1_E,
    STAGE_2_E,
    STAGE_3_E,
    STAGE_4_E,
    STAGE_5_E
  } iir_state_t;

  iir_state_t iir_state;

  logic signed [N_BITS_P-1 : 0] x1;
  logic signed [N_BITS_P-1 : 0] x2;
  logic signed [N_BITS_P-1 : 0] y00;
  logic signed [N_BITS_P-1 : 0] y1;
  logic signed [N_BITS_P-1 : 0] y2;

  // DSP multiplication register
  logic signed [2*N_BITS_P-1 : 0] mul_product;
  logic signed   [N_BITS_P-1 : 0] mul_product_section;

  // The product of the multiplications is registered in this vector
  assign mul_product_section = mul_product[MUL_HIGH_C : MUL_LOW_C];

  always_ff @ (posedge clk or negedge rst_n) begin

    if (!rst_n) begin
      iir_state   <= STAGE_0_E;
      x0_ready    <= '0;
      y0_valid    <= '0;
      y0          <= '0;
      y00         <= '0;
      x1          <= '0;
      x2          <= '0;
      y1          <= '0;
      y2          <= '0;
      mul_product <= '0;
    end
    else begin

      case (iir_state)

        // b0*x[n]
        STAGE_0_E: begin

          x0_ready <= '1;
          y0_valid <= '0;

          if (x0_valid) begin
            x0_ready    <= '0;
            iir_state   <= STAGE_1_E;
            mul_product <= cr_zero_b0 * x0;
          end
        end

        // b1*x[n-1]
        STAGE_1_E: begin
          iir_state   <= STAGE_2_E;
          y00         <= mul_product_section;        // Adding (b0*x[n])
          mul_product <= cr_zero_b1 * x1;
        end

        // b2*[x-2]
        STAGE_2_E: begin
          iir_state   <= STAGE_3_E;
          y00         <= y00 + mul_product_section;  // Adding (b1*x[n-1])
          mul_product <= cr_zero_b2 * x2;
        end

        // -a1*y[n-1]
        STAGE_3_E: begin
          iir_state   <= STAGE_4_E;
          y00         <= y00 + mul_product_section;  // Adding (b2*x[n-2])
          mul_product <= cr_pole_a1 * y1;
        end

        // -a2*y[n-2]
        STAGE_4_E: begin
          iir_state   <= STAGE_5_E;
          y00         <= y00 - mul_product_section;  // Subtracting (a1*y[n-1])
          mul_product <= cr_pole_a2 * y2;
        end

        STAGE_5_E: begin
          iir_state <= STAGE_0_E;
          y0_valid  <= '1;
          y0        <= y00 - mul_product_section;    // Subtracting (a2*y[n-2])
          x1        <= x0;
          x2        <= x1;
          y1        <= y0;
          y2        <= y1;
        end

      endcase

    end
  end

endmodule

`default_nettype wire
