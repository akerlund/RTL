////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
// https://github.com/akerlund/PYRG
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

`ifndef MIX_ADDRESS_PKG
`define MIX_ADDRESS_PKG

package mix_address_pkg;

  localparam logic [15 : 0] MIX_HIGH_ADDRESS           = 16'h0070;
  localparam logic [15 : 0] MIX_CLEAR_DAC_MIN_MAX_ADDR = 16'h0000;
  localparam logic [15 : 0] MIXER_CHANNEL_GAIN_0_ADDR  = 16'h0008;
  localparam logic [15 : 0] MIXER_CHANNEL_GAIN_1_ADDR  = 16'h0010;
  localparam logic [15 : 0] MIXER_CHANNEL_GAIN_2_ADDR  = 16'h0018;
  localparam logic [15 : 0] MIXER_CHANNEL_GAIN_3_ADDR  = 16'h0020;
  localparam logic [15 : 0] MIX_CHANNEL_PAN_0_ADDR     = 16'h0028;
  localparam logic [15 : 0] MIX_CHANNEL_PAN_1_ADDR     = 16'h0030;
  localparam logic [15 : 0] MIX_CHANNEL_PAN_2_ADDR     = 16'h0038;
  localparam logic [15 : 0] MIX_CHANNEL_PAN_3_ADDR     = 16'h0040;
  localparam logic [15 : 0] MIXER_OUTPUT_GAIN_ADDR     = 16'h0048;
  localparam logic [15 : 0] MIX_OUT_CLIP_ADDR          = 16'h0050;
  localparam logic [15 : 0] MIX_CHANNEL_CLIP_ADDR      = 16'h0058;
  localparam logic [15 : 0] MIX_MAX_DAC_AMPLITUDE_ADDR = 16'h0060;
  localparam logic [15 : 0] MIX_MIN_DAC_AMPLITUDE_ADDR = 16'h0068;

endpackage

`endif
