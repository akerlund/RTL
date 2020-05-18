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

import cordic_pkg::*;

`default_nettype none

module cordic_top #(
    parameter int DATA_WIDTH_P   = 16,
    parameter int NR_OF_STAGES_P = 16
  )(
    // Clock and reset
    input  wire                       clk,
    input  wire                       rst_n,

    input  wire              [31 : 0] ing_angle_vector,
    output logic [DATA_WIDTH_P-1 : 0] egr_sine_vector,
    output logic [DATA_WIDTH_P-1 : 0] egr_cosine_vector
  );

  logic [DATA_WIDTH_P-1 : 0] ing_x_vector;
  logic [DATA_WIDTH_P-1 : 0] ing_y_vector;

  assign ing_x_vector = 19429; //$floor((2**DATA_WIDTH_P - 1) / CORDIC_GAIN_C);NR_OF_STAGES
  assign ing_y_vector = '0;

  cordic_core #(
    .DATA_WIDTH_P      ( DATA_WIDTH_P      ),
    .NR_OF_STAGES_P    ( NR_OF_STAGES_P    )
  ) cordic_core_i0 (

    // Clock and reset
    .clk               ( clk               ),
    .rst_n             ( rst_n             ),

    // Ingress vectors
    .ing_angle_vector  ( ing_angle_vector  ),
    .ing_x_vector      ( ing_x_vector      ),
    .ing_y_vector      ( ing_y_vector      ),

    // Egress vectors
    .egr_sine_vector   ( egr_sine_vector   ),
    .egr_cosine_vector ( egr_cosine_vector )
  );

endmodule

`default_nettype wire
