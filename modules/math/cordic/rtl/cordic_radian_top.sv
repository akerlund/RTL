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
