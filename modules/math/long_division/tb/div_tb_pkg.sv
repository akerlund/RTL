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

`ifndef DIV_TB_PKG
`define DIV_TB_PKG

package div_tb_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import bool_pkg::*;
  import clk_rst_types_pkg::*;
  import clk_rst_pkg::*;
  import vip_axi4s_types_pkg::*;
  import vip_axi4s_agent_pkg::*;
  import vip_fixed_point_pkg::*;

  localparam int N_BITS_C    = 24;
  localparam int Q_BITS_C    = 15;
  localparam int TID_WIDTH_C = 11;

  // Configuration of the AXI4-S VIP
  localparam vip_axi4s_cfg_t VIP_AXI4S_CFG_C = '{
    VIP_AXI4S_TDATA_WIDTH_P : N_BITS_C,
    VIP_AXI4S_TSTRB_WIDTH_P : N_BITS_C/8,
    VIP_AXI4S_TKEEP_WIDTH_P : 0,
    VIP_AXI4S_TID_WIDTH_P   : TID_WIDTH_C,
    VIP_AXI4S_TDEST_WIDTH_P : 0,
    VIP_AXI4S_TUSER_WIDTH_P : 1
  };

  `include "div_scoreboard.sv"
  `include "div_virtual_sequencer.sv"
  `include "div_env.sv"
  `include "vip_axi4s_seq_lib.sv"

endpackage

`endif
