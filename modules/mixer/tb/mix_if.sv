////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2021 Fredrik Åkerlund
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

`ifndef MIX_IF
`define MIX_IF

import mix_tb_pkg::*;

interface mix_if(input clk, input rst_n);
  logic                                                fs_strobe;
  logic [NR_OF_CHANNELS_C-1 : 0] [AUDIO_WIDTH_C-1 : 0] channel_data;
  logic  [NR_OF_CHANNELS_C-1 : 0] [GAIN_WIDTH_C-1 : 0] cr_channel_gain;
  logic  [NR_OF_CHANNELS_C-1 : 0] [GAIN_WIDTH_C-1 : 0] cr_channel_pan;
  logic                           [GAIN_WIDTH_C-1 : 0] cr_output_gain;
  logic                                        [1 : 0] sr_out_clip;
  logic                       [NR_OF_CHANNELS_C-1 : 0] sr_channel_clip;
  logic                          [AUDIO_WIDTH_C-1 : 0] sr_max_dac_amplitude;
  logic                          [AUDIO_WIDTH_C-1 : 0] sr_min_dac_amplitude;
endinterface

`endif