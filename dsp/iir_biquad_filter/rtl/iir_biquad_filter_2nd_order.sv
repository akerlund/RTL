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
// Description:
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module iir_biquad_filter_2nd_order #(
    parameter int data_width_p    = -1,
    parameter int nr_of_q_bits_p  = -1
  )(
    // Clock and reset
    input  wire                              clk,
    input  wire                              rst_n,

    // Inputs (x)
    input  wire                              x_valid,
    input  wire  signed [data_width_p-1 : 0] x,

    // Output (y)
    output logic                             y_valid,
    output logic signed [data_width_p-1 : 0] y,

    // Factors
    input  wire  signed [data_width_p-1 : 0] cr_denominator_a1,
    input  wire  signed [data_width_p-1 : 0] cr_denominator_a2,
    input  wire  signed [data_width_p-1 : 0] cr_gain_k
  );

  localparam int mul_high_c = nr_of_q_bits_p + data_width_p - 1;
  localparam int mul_low_c  = nr_of_q_bits_p;

  typedef enum {
    stage_0_e = 0,
    stage_1_e,
    stage_2_e,
    stage_3_e,
    stage_4_e,
    stage_5_e
  } iir_state_t;

  iir_state_t                         iir_state;

  logic signed   [data_width_p-1 : 0] w_n0;
  logic signed   [data_width_p-1 : 0] w_n1;
  logic signed   [data_width_p-1 : 0] w_n2;

  logic signed [2*data_width_p-1 : 0] mul_product;
  logic signed     [data_width_p-1:0] mul_product_section;

  assign mul_product_section = mul_product[mul_high_c:mul_low_c];

  always_ff @ (posedge clk or negedge rst_n) begin

    if (!rst_n) begin
      iir_state   <= stage_0_e;
      y           <= '0;
      y_valid     <= '0;
      w_n0        <= '0;
      w_n1        <= '0;
      w_n2        <= '0;
      mul_product <= '0;
    end
    else begin

      y_valid <= '0;

      case (iir_state)

        // w(n) = x(n) - a1*w(n-1) - a2*w(n-2)
        stage_0_e: begin
          if (x_valid) begin
            iir_state   <= stage_1_e;
            mul_product <= cr_denominator_a1 * w_n1;
          end
        end

        stage_1_e: begin
          iir_state   <= stage_2_e;
          w_n0        <= x - mul_product_section;
          mul_product <= cr_denominator_a2 * w_n2;
        end

        stage_2_e: begin
          iir_state   <= stage_3_e;
          w_n0        <= w_n0 - mul_product_section;
        end

        stage_3_e: begin
          iir_state   <= stage_4_e;
          w_n0        <= w_n0 - mul_product_section;
        end

        // y(n) = b0*w(n) + b1*w(n-1) + b2*w(n-2)
        // b0 = 1, b1 = 2, b2 = 1
        stage_4_e: begin
          iir_state   <= stage_5_e;
          y           <= w_n0 + (w_n1 << 1);
        end

        stage_5_e: begin
          iir_state   <= stage_0_e;
          y_valid     <= 1;
          y           <= y + w_n2;
          w_n1        <= w_n0;
          w_n2        <= w_n1;
        end

      endcase

    end
  end
endmodule

`default_nettype wire