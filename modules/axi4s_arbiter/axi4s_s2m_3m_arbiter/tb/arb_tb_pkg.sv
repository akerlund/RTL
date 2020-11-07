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

`ifndef ARB_TB_PKG
`define ARB_TB_PKG

package arb_tb_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import vip_axi4s_types_pkg::*;
  import vip_axi4s_pkg::*;

  // Configuration of the AXI4-S VIP
  localparam vip_axi4s_cfg_t vip_axi4s_cfg = '{
    AXI_DATA_WIDTH_P : 16,
    AXI_STRB_WIDTH_P : 1,
    AXI_KEEP_WIDTH_P : 2,
    AXI_ID_WIDTH_P   : 2,
    AXI_DEST_WIDTH_P : 1,
    AXI_USER_WIDTH_P : 1
  };

  `include "arb_config.sv"
  `include "arb_scoreboard.sv"
  `include "arb_virtual_sequencer.sv"
  `include "arb_env.sv"

endpackage

`endif
