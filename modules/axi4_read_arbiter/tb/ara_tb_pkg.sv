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

package ara_tb_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import bool_pkg::*;
  import clk_rst_types_pkg::*;
  import clk_rst_pkg::*;
  import vip_axi4_types_pkg::*;
  import vip_axi4_agent_pkg::*;

  localparam int NR_OF_MASTERS_C = 3;

  // Configuration of the VIP
  localparam vip_axi4_cfg_t VIP_AXI4_CFG_C = '{
    VIP_AXI4_ID_WIDTH_P   : 2,
    VIP_AXI4_ADDR_WIDTH_P : 13,
    VIP_AXI4_DATA_WIDTH_P : 32,
    VIP_AXI4_STRB_WIDTH_P : 4,
    VIP_AXI4_USER_WIDTH_P : 0
  };

  `include "ara_scoreboard.sv"
  `include "ara_virtual_sequencer.sv"
  `include "ara_env.sv"
  `include "vip_axi4_seq_lib.sv"

endpackage
