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

module osc_triangle_top #(
  parameter int DATA_WIDTH_P         = -1,    // Width of the wave
  parameter int PERIOD_IN_SYS_CLKS_P = 48000, // Period (in system clock periods) of the wave
  parameter int COUNTER_WIDTH_P      = 32     // Width of the clock enable's counter

  )(
    // Clock and reset
    input  wire                          clk,
    input  wire                          rst_n,

    // Waveform output
    output logic    [DATA_WIDTH_P-1 : 0] osc_triangle,
    input  wire  [COUNTER_WIDTH_P-1 : 0] cr_enable_period
  );

  // The increment value of the counter depending on the given maximum frequency
  localparam int WAVE_AMPLITUDE_INC_C =
    (2**DATA_WIDTH_P-1) / (PERIOD_IN_SYS_CLKS_P/2);

  // The max amplitude of the wave is (minimum amplitude) plus increment size times number of increments
  localparam logic signed [DATA_WIDTH_P-1 : 0] WAVE_AMPLITUDE_MAX_C =
    -2**(DATA_WIDTH_P-1) + WAVE_AMPLITUDE_INC_C*PERIOD_IN_SYS_CLKS_P/2;

  logic clock_enable;


  osc_triangle_core #(
    .DATA_WIDTH_P         ( DATA_WIDTH_P         ), // Width of the wave
    .WAVE_AMPLITUDE_INC_P ( WAVE_AMPLITUDE_INC_C ), // Increment of amplitude at every clock enable
    .WAVE_AMPLITUDE_MAX_P ( WAVE_AMPLITUDE_MAX_C )  // Max amplitude of the triangle
  ) osc_triangle_core_i0 (
    .clk                  ( clk                  ),
    .rst_n                ( rst_n                ),
    .clock_enable         ( clock_enable         ),
    .osc_triangle         ( osc_triangle         )
  );


  clock_enable #(
    .COUNTER_WIDTH_P  ( COUNTER_WIDTH_P  )
  ) clock_enable_i0 (
    .clk              ( clk              ),
    .rst_n            ( rst_n            ),
    .enable           ( clock_enable     ),
    .cr_enable_period ( cr_enable_period )
  );

endmodule

`default_nettype wire
