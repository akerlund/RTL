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
// Given the prime frequency as a parameter, this top module calculates new
// parameters for the core so it will produce a triangle wave of that
// frequency. The calculated parameters makes the core increase the triangle's
// amplitude by some integer every clock cycle until it has reached its highest
// amplitude. Becuase it will only increase when the input signal 'clock_enable'
// is asserted the prime frequency can be reduced to a lower one.
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module osc_triangle_top #(
    parameter int SYS_CLK_FREQUENCY_P = -1, // System clock's frequency
    parameter int PRIME_FREQUENCY_P   = -1, // Output frequency then clock enable is always high
    parameter int WAVE_WIDTH_P        = -1  // Width of the wave
  )(
    // Clock and reset
    input  wire                       clk,
    input  wire                       rst_n,
    input  wire                       clock_enable,

    // Waveform output
    output logic [WAVE_WIDTH_P-1 : 0] osc_triangle
  );

  // The prime (or higest/base) frequency's period in system clock periods, e.g.,
  // 200MHz / 1MHz = 200
  localparam int PERIOD_IN_SYS_CLKS_C = SYS_CLK_FREQUENCY_P / PRIME_FREQUENCY_P;

  // The increment value of the counter depending on the given maximum frequency, e.g.,
  // (2**24 -1) / (200/2) = 16777215 / 100 = 167772
  localparam int WAVE_AMPLITUDE_INC_C =
    (2**WAVE_WIDTH_P-1) / (PERIOD_IN_SYS_CLKS_C/2);

  // The max amplitude of the wave is (minimum amplitude) plus increment size times number of increments, e.g.,
  // -2**(24-1) + 167772*200/2 = -8388608 + 16777200 = 8388592
  localparam logic signed [WAVE_WIDTH_P-1 : 0] WAVE_AMPLITUDE_MAX_C =
    -2**(WAVE_WIDTH_P-1) + WAVE_AMPLITUDE_INC_C*PERIOD_IN_SYS_CLKS_C/2;

  osc_triangle_core #(
    .WAVE_WIDTH_P         ( WAVE_WIDTH_P         ), // Width of the wave
    .WAVE_AMPLITUDE_INC_P ( WAVE_AMPLITUDE_INC_C ), // Increment of amplitude at every clock enable
    .WAVE_AMPLITUDE_MAX_P ( WAVE_AMPLITUDE_MAX_C )  // Max amplitude of the triangle
  ) osc_triangle_core_i0 (
    .clk                  ( clk                  ),
    .rst_n                ( rst_n                ),
    .clock_enable         ( clock_enable         ),
    .osc_triangle         ( osc_triangle         )
  );

endmodule

`default_nettype wire
