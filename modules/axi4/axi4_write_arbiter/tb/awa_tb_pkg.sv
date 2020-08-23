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

package awa_tb_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import vip_axi4_types_pkg::*;

  // Configuration of the VIP
  localparam vip_axi4_cfg_t vip_axi4_cfg = '{
    AXI_ID_WIDTH_P   : 4,
    AXI_ADDR_WIDTH_P : 32,
    AXI_DATA_WIDTH_P : 128,
    AXI_STRB_WIDTH_P : 16,
    AXI_USER_WIDTH_P : 1
  };

  import axi4_write_pkg::*;
  import axi4_memory_pkg::*;

  `include "awa_config.sv"
  `include "awa_scoreboard.sv"
  `include "awa_virtual_sequencer.sv"
  `include "awa_env.sv"
  `include "awa_vseq_lib.sv"

endpackage
