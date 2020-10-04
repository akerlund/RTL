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

`ifndef VEC_TB_PKG
`define VEC_TB_PKG

package vec_tb_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import vip_axi4s_types_pkg::*;
  import vip_axi4s_pkg::*;

  import clk_rst_types_pkg::*;
  import clk_rst_pkg::*;

  // Configuration of the AXI4-S VIP
  localparam vip_axi4s_cfg_t axi4s_cfg = '{
    AXI_DATA_WIDTH_P : 24,
    AXI_STRB_WIDTH_P : 0,
    AXI_KEEP_WIDTH_P : 0,
    AXI_ID_WIDTH_P   : 0,
    AXI_DEST_WIDTH_P : 0,
    AXI_USER_WIDTH_P : 0
  };

  `include "vec_config.sv"
  `include "vec_scoreboard.sv"
  `include "vec_virtual_sequencer.sv"
  `include "vec_env.sv"

endpackage

`endif
