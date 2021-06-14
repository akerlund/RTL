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
#ifndef MIX_ADDRESS_H
#define MIX_ADDRESS_H

  #define MIX_HIGH_ADDRESS           MIX_PHYSICAL_ADDRESS_C + 0x0070
  #define MIX_CLEAR_DAC_MIN_MAX_ADDR MIX_PHYSICAL_ADDRESS_C + 0x0000
  #define MIXER_CHANNEL_GAIN_0_ADDR  MIX_PHYSICAL_ADDRESS_C + 0x0008
  #define MIXER_CHANNEL_GAIN_1_ADDR  MIX_PHYSICAL_ADDRESS_C + 0x0010
  #define MIXER_CHANNEL_GAIN_2_ADDR  MIX_PHYSICAL_ADDRESS_C + 0x0018
  #define MIXER_CHANNEL_GAIN_3_ADDR  MIX_PHYSICAL_ADDRESS_C + 0x0020
  #define MIX_CHANNEL_PAN_0_ADDR     MIX_PHYSICAL_ADDRESS_C + 0x0028
  #define MIX_CHANNEL_PAN_1_ADDR     MIX_PHYSICAL_ADDRESS_C + 0x0030
  #define MIX_CHANNEL_PAN_2_ADDR     MIX_PHYSICAL_ADDRESS_C + 0x0038
  #define MIX_CHANNEL_PAN_3_ADDR     MIX_PHYSICAL_ADDRESS_C + 0x0040
  #define MIXER_OUTPUT_GAIN_ADDR     MIX_PHYSICAL_ADDRESS_C + 0x0048
  #define MIX_OUT_CLIP_ADDR          MIX_PHYSICAL_ADDRESS_C + 0x0050
  #define MIX_CHANNEL_CLIP_ADDR      MIX_PHYSICAL_ADDRESS_C + 0x0058
  #define MIX_MAX_DAC_AMPLITUDE_ADDR MIX_PHYSICAL_ADDRESS_C + 0x0060
  #define MIX_MIN_DAC_AMPLITUDE_ADDR MIX_PHYSICAL_ADDRESS_C + 0x0068

#endif
