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

`ifndef OSC_TB_PKG
`define OSC_TB_PKG

package osc_tb_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import vip_apb3_types_pkg::*;
  import vip_apb3_pkg::*;

  // Configuration of the APB3 VIP
  localparam vip_apb3_cfg_t vip_apb3_cfg = '{
    APB_ADDR_WIDTH_P : 8,
    APB_DATA_WIDTH_P : 32
  };

  localparam int WAVE_WIDTH_C    = 16;
  localparam int COUNTER_WIDTH_C = 32;

  `include "osc_config.sv"
  `include "osc_scoreboard.sv"
  `include "osc_virtual_sequencer.sv"
  `include "osc_env.sv"
  `include "osc_seq_lib.sv"

endpackage

`endif
