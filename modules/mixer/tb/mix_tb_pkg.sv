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

`ifndef MIX_TB_PKG
`define MIX_TB_PKG

package mix_tb_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import vip_axi4s_types_pkg::*;
  import vip_axi4s_pkg::*;
  import vip_fixed_point_pkg::*;

  localparam int AUDIO_WIDTH_C    = 24;
  localparam int GAIN_WIDTH_C     = 24;
  localparam int NR_OF_CHANNELS_C = 4;
  localparam int Q_BITS_C         = 7;


  // Configuration of the AXI4-S VIP
  localparam vip_axi4s_cfg_t vip_axi4s_cfg = '{
    AXI_DATA_WIDTH_P : AUDIO_WIDTH_C,
    AXI_STRB_WIDTH_P : 0,
    AXI_KEEP_WIDTH_P : 0,
    AXI_ID_WIDTH_P   : 2,
    AXI_DEST_WIDTH_P : 0,
    AXI_USER_WIDTH_P : 1
  };

  `include "mix_config.sv"
  `include "mix_scoreboard.sv"
  `include "mix_virtual_sequencer.sv"
  `include "mix_env.sv"
  `include "mix_seq_lib.sv"

endpackage

`endif
