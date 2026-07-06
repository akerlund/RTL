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

module tb_top;

  localparam int SYS_CLK_FREQUENCY_C  = 125000000;
  localparam int PRIME_FREQUENCY_C    = 1000000;
  localparam int WAVE_WIDTH_C         = 24;
  localparam int DUTY_CYCLE_DIVIDER_C = 1000;
  localparam int N_BITS_C             = 32;
  localparam int Q_BITS_C             = 11;
  localparam int AXI_DATA_WIDTH_C     = 32;
  localparam int AXI_ID_WIDTH_C       = 4;
  localparam int AXI_ID_C             = 1;

  logic                              clk;
  logic                              rst_n;
  logic signed [WAVE_WIDTH_C-1 : 0]  waveform;
  logic                        [1:0] cr_waveform_select;
  logic        [N_BITS_C-1 : 0]      cr_frequency;
  logic        [N_BITS_C-1 : 0]      cr_duty_cycle;

  oscillator_system #(
    .SYS_CLK_FREQUENCY_P  ( SYS_CLK_FREQUENCY_C    ),
    .PRIME_FREQUENCY_P    ( PRIME_FREQUENCY_C      ),
    .WAVE_WIDTH_P         ( WAVE_WIDTH_C           ),
    .DUTY_CYCLE_DIVIDER_P ( DUTY_CYCLE_DIVIDER_C   ),
    .N_BITS_P             ( N_BITS_C               ),
    .Q_BITS_P             ( Q_BITS_C               ),
    .AXI_DATA_WIDTH_P     ( AXI_DATA_WIDTH_C       ),
    .AXI_ID_WIDTH_P       ( AXI_ID_WIDTH_C         ),
    .AXI_ID_P             ( AXI_ID_C               )
  ) dut (
    .clk                  ( clk                    ),
    .rst_n                ( rst_n                  ),
    .waveform             ( waveform               ),
    .cr_waveform_select   ( cr_waveform_select     ),
    .cr_frequency         ( cr_frequency           ),
    .cr_duty_cycle        ( cr_duty_cycle          )
  );

endmodule

`default_nettype wire
