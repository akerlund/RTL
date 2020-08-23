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

import cordic_atan_radian_table_pkg::*;

`default_nettype none

module cordic_radian_core #(
    parameter int DATA_WIDTH_P   = -1,
    parameter int NR_OF_STAGES_P = -1
  )(
    // Clock and reset
    input  wire                              clk,
    input  wire                              rst_n,

    input  wire  signed [DATA_WIDTH_P-1 : 0] ing_theta_vector,
    input  wire  signed [DATA_WIDTH_P-1 : 0] ing_x_vector,
    input  wire  signed [DATA_WIDTH_P-1 : 0] ing_y_vector,

    output logic signed [DATA_WIDTH_P-1 : 0] egr_sine_vector,
    output logic signed [DATA_WIDTH_P-1 : 0] egr_cosine_vector
 );

  // Positive radian values
  localparam logic signed [DATA_WIDTH_P-1 : 0] pos_pi_2_quarter = pi_2_4_pos_n54_q50[53 : 53-DATA_WIDTH_P+1];
  localparam logic signed [DATA_WIDTH_P-1 : 0] pos_pi_4_quarter = pi_4_4_pos_n54_q50[53 : 53-DATA_WIDTH_P+1];
  localparam logic signed [DATA_WIDTH_P-1 : 0] pos_pi_6_quarter = pi_6_4_pos_n54_q50[53 : 53-DATA_WIDTH_P+1];
  localparam logic signed [DATA_WIDTH_P-1 : 0] pos_pi_8_quarter = pi_8_4_pos_n54_q50[53 : 53-DATA_WIDTH_P+1];

  // CORDIC vectors
  logic signed [DATA_WIDTH_P-1 : 0] theta_vector;
  logic signed [DATA_WIDTH_P-1 : 0] x_vector [0 : NR_OF_STAGES_P-1]; // Cosine vector
  logic signed [DATA_WIDTH_P-1 : 0] y_vector [0 : NR_OF_STAGES_P-1]; // Sine vector
  logic signed [DATA_WIDTH_P-1 : 0] z_vector [0 : NR_OF_STAGES_P-1]; // Rotating vector

  // Sign correction of the input theta vector
  assign theta_vector = !ing_theta_vector[DATA_WIDTH_P-1] ? ing_theta_vector : -ing_theta_vector;

  // Assigning the output registers
  assign egr_sine_vector   = y_vector[NR_OF_STAGES_P-1];
  assign egr_cosine_vector = x_vector[NR_OF_STAGES_P-1];


  always_ff @(posedge clk or negedge rst_n) begin: stage_0
    if (!rst_n) begin
      x_vector[0] <= '0;
      y_vector[0] <= '0;
      z_vector[0] <= '0;
    end
    else begin

      // Quadrant 1 - Do nothing
      if (theta_vector <= pos_pi_2_quarter) begin
        x_vector[0] <= ing_x_vector;
        y_vector[0] <= ing_y_vector;
        z_vector[0] <= theta_vector;
      end
      // Quadrant 2 - Move theta into Quadrant 1
      else if (theta_vector <= pos_pi_4_quarter) begin
        x_vector[0] <= -ing_y_vector;
        y_vector[0] <=  ing_x_vector;
        z_vector[0] <=  theta_vector - pos_pi_2_quarter;
      end
      // Quadrant 3 - Move theta into Quadrant 4
      else if (theta_vector <= pos_pi_6_quarter) begin
        x_vector[0] <=  ing_y_vector;
        y_vector[0] <= -ing_x_vector;
        z_vector[0] <=  theta_vector - pos_pi_6_quarter;
      end
      // Quadrant 4 - Do nothing
      else begin
        x_vector[0] <= ing_x_vector;
        y_vector[0] <= ing_y_vector;
        z_vector[0] <= theta_vector - pos_pi_8_quarter;
      end
    end
  end

  genvar i;
  generate
    for (i = 0; i < (NR_OF_STAGES_P-1); i++) begin: stage_n

      logic                             z_sign;
      logic signed [DATA_WIDTH_P-1 : 0] x_shr;
      logic signed [DATA_WIDTH_P-1 : 0] y_shr;
      logic        [DATA_WIDTH_P-1 : 0] atan_value;

      // Arithmetic right shift (>>>) fills with value of sign bit if expression is signed
      assign x_shr = x_vector[i] >>> i;
      assign y_shr = y_vector[i] >>> i;

      // Value of atan(2^-i)
      assign atan_value = atan_radian_table_32stage_n64q60[i][63 : 63-DATA_WIDTH_P+1];

      // The sign of the current rotation angle
      assign z_sign = z_vector[i][31];

      always_ff @(posedge clk or negedge rst_n) begin: cordic_stage
        if (!rst_n) begin
          x_vector[i+1] <= '0;
          y_vector[i+1] <= '0;
          z_vector[i+1] <= '0;
        end
        else begin
          x_vector[i+1] <= z_sign ? x_vector[i] + y_shr      : x_vector[i] - y_shr;
          y_vector[i+1] <= z_sign ? y_vector[i] - x_shr      : y_vector[i] + x_shr;
          z_vector[i+1] <= z_sign ? z_vector[i] + atan_value : z_vector[i] - atan_value;
        end
      end
    end
  endgenerate

endmodule

`default_nettype wire
