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

  localparam int MUL_HIGH_C = N_BITS_P + Q_BITS_P - 1;
  localparam int MUL_LOW_C  = Q_BITS_P;

  typedef enum {
    WAIT_FOR_X0_VALID_E,
    CALCULATE_B1_E,
    CALCULATE_B2_E,
    CALCULATE_A1_E,
    CALCULATE_A2_E,
    CALCULATE_Y0_E
  } iir_state_t;

  iir_state_t iir_state;

  logic signed [N_BITS_P-1 : 0] x1;
  logic signed [N_BITS_P-1 : 0] x2;
  logic signed [N_BITS_P-1 : 0] y00; // Intermediate result register
  logic signed [N_BITS_P-1 : 0] y1;

  // DSP multiplication register
  logic signed [2*N_BITS_P-1 : 0] mul_product;
  logic signed   [N_BITS_P-1 : 0] mul_product_section;

  // The product of a multiplication is stored in this vector
  assign mul_product_section = mul_product[MUL_HIGH_C : MUL_LOW_C];

  always_ff @(posedge clk or negedge rst_n) begin

    if (!rst_n) begin
      iir_state   <= WAIT_FOR_X0_VALID_E;
      x0_ready    <= '0;
      y0_valid    <= '0;
      y0          <= '0;
      y00         <= '0;
      x1          <= '0;
      x2          <= '0;
      y1          <= '0;
      mul_product <= '0;
    end
    else begin

      case (iir_state)

        WAIT_FOR_X0_VALID_E: begin

          x0_ready <= '1;
          y0_valid <= '0;

          if (x0_valid) begin
            x0_ready    <= '0;
            iir_state   <= CALCULATE_B1_E;
            mul_product <= cr_zero_b0 * x0;
          end
        end


        CALCULATE_B1_E: begin
          iir_state   <= CALCULATE_B2_E;
          y00         <= mul_product_section;        // Adding (b0 * x[n])
          mul_product <= cr_zero_b1 * x1;
        end


        CALCULATE_B2_E: begin
          iir_state   <= CALCULATE_A1_E;
          y00         <= y00 + mul_product_section;  // Adding (b1 * x[n-1])
          mul_product <= cr_zero_b2 * x2;
        end


        CALCULATE_A1_E: begin
          iir_state   <= CALCULATE_A2_E;
          y00         <= y00 + mul_product_section;  // Adding (b2 * x[n-2])
          mul_product <= cr_pole_a1 * y0;
        end


        CALCULATE_A2_E: begin
          iir_state   <= CALCULATE_Y0_E;
          y00         <= y00 - mul_product_section;  // Subtracting (a1 * y[n-1])
          mul_product <= cr_pole_a2 * y1;
        end


        CALCULATE_Y0_E: begin
          iir_state <= WAIT_FOR_X0_VALID_E;
          y0_valid  <= '1;
          y0        <= y00 - mul_product_section;    // Subtracting (a2 * y[n-2])
          x1        <= x0;
          x2        <= x1;
          y1        <= y0;
        end

      endcase

    end
  end

endmodule

`default_nettype wire
