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

module osc_triangle_top #(
    parameter int SYS_CLK_FREQUENCY_P = -1, // System clock's frequency
    parameter int PRIME_FREQUENCY_P   = -1, // Output frequency then clock enable is always high
    parameter int WAVE_WIDTH_P        = -1, // Width of the wave
    parameter int COUNTER_WIDTH_P     = $clog2(SYS_CLK_FREQUENCY_P)
  )(
    // Clock and reset
    input  wire                                 clk,
    input  wire                                 rst_n,

    // Waveform output
    output logic signed    [WAVE_WIDTH_P-1 : 0] osc_triangle,

    // The counter period of the Clock Enable, i.e., PRIME_FREQUENCY_P / frequency
    input  wire         [COUNTER_WIDTH_P-1 : 0] cr_clock_enable
  );

  // A 24-bit signed wave has a maximum amplitude of 8388607
  localparam int MAX_WAVE_AMPLITUDE_C      = 2**(WAVE_WIDTH_P-1)-1;

  // A 24-bit signed wave has a minimum amplitude of -8388608
  localparam int MIN_WAVE_AMPLITUDE_C      =  -2**(WAVE_WIDTH_P-1);

  // The prime (or higest/base) frequency's period in system clock periods, e.g.,
  // 125MHz / 1MHz = 125
  localparam int PERIOD_IN_SYS_CLKS_C      = SYS_CLK_FREQUENCY_P / PRIME_FREQUENCY_P;

  // For example: 125 / 2 = 63
  localparam int HALF_PERIOD_IN_SYS_CLKS_C = int'($ceil(real'(PERIOD_IN_SYS_CLKS_C) / real'(2.0)));

  // The increment value of the counter depending on the given maximum frequency, e.g.,
  // For example: 8388607 / 63 = 133152
  localparam logic signed [WAVE_WIDTH_P-1 : 0] WAVE_AMPLITUDE_INC_C = MAX_WAVE_AMPLITUDE_C / HALF_PERIOD_IN_SYS_CLKS_C;

  // The max amplitude of the wave is (minimum amplitude) plus increment size times number of increments, e.g.,
  // For example: (-8388608 + 133152*125 = 8255392) < 8388607 => 8388607 - 8255392 = 133215
  localparam logic signed [WAVE_WIDTH_P-1 : 0] WAVE_AMPLITUDE_MAX_C = MIN_WAVE_AMPLITUDE_C + WAVE_AMPLITUDE_INC_C*PERIOD_IN_SYS_CLKS_C;

  logic clock_enable;

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


  clock_enable #(
    .COUNTER_WIDTH_P  ( COUNTER_WIDTH_P )
  ) clock_enable_i0 (
    .clk              ( clk             ), // input
    .rst_n            ( rst_n           ), // input
    .reset_counter_n  ( '1              ), // input
    .enable           ( clock_enable    ), // output
    .cr_enable_period ( cr_clock_enable )  // input
  );


endmodule

`default_nettype wire
