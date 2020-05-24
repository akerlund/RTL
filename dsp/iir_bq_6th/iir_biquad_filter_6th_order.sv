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

module iir_biquad_filter_6th_order #(
    parameter int DATA_WIDTH_P    = -1,
    parameter int NR_OF_Q_BITS_P  = -1
  ) (
    // Clock and reset
    input  wire                              clk,
    input  wire                              rst_n,

    // Inputs (x)
    input  wire                              x_valid,
    input  wire  signed [DATA_WIDTH_P-1 : 0] x,

    // Output (y)
    output logic                             y_valid,
    output logic signed [DATA_WIDTH_P-1 : 0] y,

    // Filter coefficients
    input  wire  signed [DATA_WIDTH_P-1 : 0] cr_a1_section_0,
    input  wire  signed [DATA_WIDTH_P-1 : 0] cr_a2_section_0,
    input  wire  signed [DATA_WIDTH_P-1 : 0] cr_gain_k_section_0,

    input  wire  signed [DATA_WIDTH_P-1 : 0] cr_a1_section_1,
    input  wire  signed [DATA_WIDTH_P-1 : 0] cr_a2_section_1,
    input  wire  signed [DATA_WIDTH_P-1 : 0] cr_gain_k_section_1,

    input  wire  signed [DATA_WIDTH_P-1 : 0] cr_a1_section_2,
    input  wire  signed [DATA_WIDTH_P-1 : 0] cr_a2_section_2,
    input  wire  signed [DATA_WIDTH_P-1 : 0] cr_gain_k_section_2
  );

  iir_biquad_filter_2nd_order #(
    .DATA_WIDTH_P      ( DATA_WIDTH_P        ),
    .NR_OF_Q_BITS_P    ( NR_OF_Q_BITS_P      )
  ) iir_biquad_filter_2nd_order_i0 (
    .clk               ( clk                 ),
    .rst_n             ( rst_n               ),
    .x_valid           ( x_valid             ),
    .x                 ( x                   ),
    .y_valid           ( y_valid_section_0   ),
    .y                 ( y_section_0         ),
    .cr_denominator_a1 ( cr_a1_section_0     ),
    .cr_denominator_a2 ( cr_a2_section_0     ),
    .cr_gain_k         ( cr_gain_k_section_0 )
  );

  iir_biquad_filter_2nd_order #(
    .DATA_WIDTH_P      ( DATA_WIDTH_P        ),
    .NR_OF_Q_BITS_P    ( NR_OF_Q_BITS_P      )
  ) iir_biquad_filter_2nd_order_i1 (
    .clk               ( clk                 ),
    .rst_n             ( rst_n               ),
    .x_valid           ( y_valid_section_0   ),
    .x                 ( y_section_0         ),
    .y_valid           ( y_valid_section_1   ),
    .y                 ( y_section_1         ),
    .cr_denominator_a1 ( cr_a1_section_1     ),
    .cr_denominator_a2 ( cr_a2_section_1     ),
    .cr_gain_k         ( cr_gain_k_section_1 )
  );

  iir_biquad_filter_2nd_order #(
    .DATA_WIDTH_P      ( DATA_WIDTH_P        ),
    .NR_OF_Q_BITS_P    ( NR_OF_Q_BITS_P      )
  ) iir_biquad_filter_2nd_order_i2 (
    .clk               ( clk                 ),
    .rst_n             ( rst_n               ),
    .x_valid           ( y_valid_section_1   ),
    .x                 ( y_section_1         ),
    .y_valid           ( y_valid             ),
    .y                 ( y                   ),
    .cr_denominator_a1 ( cr_a1_section_2     ),
    .cr_denominator_a2 ( cr_a2_section_2     ),
    .cr_gain_k         ( cr_gain_k_section_2 )
  );

endmodule

`default_nettype wire
