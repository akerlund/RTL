////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2020 Fredrik Åkerlund
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Description:
//
////////////////////////////////////////////////////////////////////////////////

import cordic_atan_table_pkg::*;

`default_nettype none

module cordic_core #(
    parameter int DATA_WIDTH_P   = 16,
    parameter int NR_OF_STAGES_P = 16
  )(
    // Clock and reset
    input  wire                              clk,
    input  wire                              rst_n,

    input  wire  signed             [31 : 0] ing_angle_vector,
    input  wire  signed [DATA_WIDTH_P-1 : 0] ing_x_vector,
    input  wire  signed [DATA_WIDTH_P-1 : 0] ing_y_vector,

    output logic signed [DATA_WIDTH_P-1 : 0] egr_sine_vector,
    output logic signed [DATA_WIDTH_P-1 : 0] egr_cosine_vector
 );

  logic signed [DATA_WIDTH_P : 0] x_vector [0 : NR_OF_STAGES_P-1];
  logic signed [DATA_WIDTH_P : 0] y_vector [0 : NR_OF_STAGES_P-1];
  logic signed           [31 : 0] z_vector [0 : NR_OF_STAGES_P-1];
  logic                   [1 : 0] quadrant;

  assign quadrant = ing_angle_vector[31 : 30];

  assign egr_sine_vector   = y_vector[NR_OF_STAGES_P-1];
  assign egr_cosine_vector = x_vector[NR_OF_STAGES_P-1];

  always_ff @(posedge clk) begin

    // Make sure the rotation angle is in the -pi/2 to pi/2 range
    case (quadrant)

      2'b00, 2'b11: begin // No changes needed for these quadrants
        x_vector[0] <= ing_x_vector;
        y_vector[0] <= ing_y_vector;
        z_vector[0] <= ing_angle_vector;
      end

      2'b01: begin
        x_vector[0] <= -ing_y_vector;
        y_vector[0] <=  ing_x_vector;
        z_vector[0] <= {2'b00, ing_angle_vector[29 : 0]}; // Subtract pi/2 for angle in this quadrant
      end

      2'b10: begin
        x_vector[0] <=  ing_y_vector;
        y_vector[0] <= -ing_x_vector;
        z_vector[0] <= {2'b11, ing_angle_vector[29 : 0]}; // Add pi/2 to angles in this quadrant
      end
    endcase
  end

  genvar i;
  generate
    for (i = 0; i < (NR_OF_STAGES_P-1); i++) begin: cordic_pipeline

      logic                           z_sign;
      logic signed [DATA_WIDTH_P : 0] x_shr;
      logic signed [DATA_WIDTH_P : 0] y_shr;

      // Arithmetic right shift (>>>) fills with value of sign bit if expression is signed
      assign x_shr = x_vector[i] >>> i;
      assign y_shr = y_vector[i] >>> i;

      // The sign of the current rotation angle
      assign z_sign = z_vector[i][31];

      always_ff @(posedge clk) begin
        x_vector[i+1] <= z_sign ? x_vector[i] + y_shr                  : x_vector[i] - y_shr;
        y_vector[i+1] <= z_sign ? y_vector[i] - x_shr                  : y_vector[i] + x_shr;
        z_vector[i+1] <= z_sign ? z_vector[i] + atan_table_31x32bit[i] : z_vector[i] - atan_table_31x32bit[i];
      end
    end
  endgenerate


endmodule

`default_nettype wire
