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

import cordic_atan_radian_table_pkg::*;

`default_nettype none

module cordic_radian_top #(
    parameter int DATA_WIDTH_P   = -1,
    parameter int NR_OF_STAGES_P = -1
  )(
    // Clock and reset
    input  wire                       clk,
    input  wire                       rst_n,

    input  wire  [DATA_WIDTH_P-1 : 0] ing_theta_vector,
    output logic [DATA_WIDTH_P-1 : 0] egr_sine_vector,
    output logic [DATA_WIDTH_P-1 : 0] egr_cosine_vector
  );

  logic [DATA_WIDTH_P-1 : 0] ing_x_vector;
  logic [DATA_WIDTH_P-1 : 0] ing_y_vector;

  assign ing_y_vector = '0;
  assign ing_x_vector = gain_table_32stage_n64q60[NR_OF_STAGES_P-1][63 : 63-DATA_WIDTH_P+1];

  cordic_radian_core #(
    .DATA_WIDTH_P      ( DATA_WIDTH_P      ),
    .NR_OF_STAGES_P    ( NR_OF_STAGES_P    )
  ) cordic_radian_core_i0 (

    // Clock and reset
    .clk               ( clk               ),
    .rst_n             ( rst_n             ),

    // Ingress vectors
    .ing_theta_vector  ( ing_theta_vector  ),
    .ing_x_vector      ( ing_x_vector      ),
    .ing_y_vector      ( ing_y_vector      ),

    // Egress vectors
    .egr_sine_vector   ( egr_sine_vector   ),
    .egr_cosine_vector ( egr_cosine_vector )
  );

endmodule

`default_nettype wire
