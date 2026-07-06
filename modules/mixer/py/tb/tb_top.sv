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

  localparam int AUDIO_WIDTH_C    = 24;
  localparam int GAIN_WIDTH_C     = 24;
  localparam int NR_OF_CHANNELS_C = 4;
  localparam int Q_BITS_C         = 7;

  logic                                                clk;
  logic                                                rst_n;
  logic                                                x_valid;
  logic signed                         [AUDIO_WIDTH_C-1 : 0] x_data0;
  logic signed                         [AUDIO_WIDTH_C-1 : 0] x_data1;
  logic signed                         [AUDIO_WIDTH_C-1 : 0] x_data2;
  logic signed                         [AUDIO_WIDTH_C-1 : 0] x_data3;
  logic signed [NR_OF_CHANNELS_C-1 : 0] [AUDIO_WIDTH_C-1 : 0] x_data;
  logic                                 [GAIN_WIDTH_C-1 : 0] cr_mix_channel_gain0;
  logic                                 [GAIN_WIDTH_C-1 : 0] cr_mix_channel_gain1;
  logic                                 [GAIN_WIDTH_C-1 : 0] cr_mix_channel_gain2;
  logic                                 [GAIN_WIDTH_C-1 : 0] cr_mix_channel_gain3;
  logic        [NR_OF_CHANNELS_C-1 : 0] [GAIN_WIDTH_C-1 : 0] cr_mix_channel_gain;
  logic                                 [GAIN_WIDTH_C-1 : 0] cr_mix_channel_pan0;
  logic                                 [GAIN_WIDTH_C-1 : 0] cr_mix_channel_pan1;
  logic                                 [GAIN_WIDTH_C-1 : 0] cr_mix_channel_pan2;
  logic                                 [GAIN_WIDTH_C-1 : 0] cr_mix_channel_pan3;
  logic        [NR_OF_CHANNELS_C-1 : 0] [GAIN_WIDTH_C-1 : 0] cr_mix_channel_pan;
  logic                                 [GAIN_WIDTH_C-1 : 0] cr_mix_output_gain;
  logic                                                cmd_mix_clear_dac_min_max;
  logic                                                dac_ready;
  logic                                        [23 : 0] dac_data;
  logic                                                dac_valid;
  logic                                                dac_last;
  logic                                                clip_led;
  logic                                                sr_mix_out_clip;
  logic                    [NR_OF_CHANNELS_C-1 : 0]    sr_mix_channel_clip;
  logic                       [AUDIO_WIDTH_C-1 : 0]    sr_mix_max_dac_amplitude;
  logic                       [AUDIO_WIDTH_C-1 : 0]    sr_mix_min_dac_amplitude;

  assign x_data[0]              = x_data0;
  assign x_data[1]              = x_data1;
  assign x_data[2]              = x_data2;
  assign x_data[3]              = x_data3;
  assign cr_mix_channel_gain[0] = cr_mix_channel_gain0;
  assign cr_mix_channel_gain[1] = cr_mix_channel_gain1;
  assign cr_mix_channel_gain[2] = cr_mix_channel_gain2;
  assign cr_mix_channel_gain[3] = cr_mix_channel_gain3;
  assign cr_mix_channel_pan[0]  = cr_mix_channel_pan0;
  assign cr_mix_channel_pan[1]  = cr_mix_channel_pan1;
  assign cr_mix_channel_pan[2]  = cr_mix_channel_pan2;
  assign cr_mix_channel_pan[3]  = cr_mix_channel_pan3;

  mixer_top #(
    .AUDIO_WIDTH_P    ( AUDIO_WIDTH_C    ),
    .GAIN_WIDTH_P     ( GAIN_WIDTH_C     ),
    .NR_OF_CHANNELS_P ( NR_OF_CHANNELS_C ),
    .Q_BITS_P         ( Q_BITS_C         )
  ) dut (
    .clk                       ( clk                      ),
    .rst_n                     ( rst_n                    ),
    .clip_led                  ( clip_led                 ),
    .x_valid                   ( x_valid                  ),
    .x_data                    ( x_data                   ),
    .dac_data                  ( dac_data                 ),
    .dac_valid                 ( dac_valid                ),
    .dac_ready                 ( dac_ready                ),
    .dac_last                  ( dac_last                 ),
    .cmd_mix_clear_dac_min_max ( cmd_mix_clear_dac_min_max ),
    .cr_mix_channel_gain       ( cr_mix_channel_gain      ),
    .cr_mix_channel_pan        ( cr_mix_channel_pan       ),
    .cr_mix_output_gain        ( cr_mix_output_gain       ),
    .sr_mix_out_clip           ( sr_mix_out_clip          ),
    .sr_mix_channel_clip       ( sr_mix_channel_clip      ),
    .sr_mix_max_dac_amplitude  ( sr_mix_max_dac_amplitude ),
    .sr_mix_min_dac_amplitude  ( sr_mix_min_dac_amplitude )
  );

endmodule

`default_nettype wire
