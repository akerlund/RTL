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

`ifndef FIR_TB_PKG
`define FIR_TB_PKG

package fir_tb_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import fir_address_pkg::*;

  import vip_fixed_point_pkg::*;
  import bool_pkg::*;
  import clk_rst_types_pkg::*;
  import clk_rst_pkg::*;
  import vip_axi4s_types_pkg::*;
  import vip_axi4s_agent_pkg::*;
  import vip_axi4_types_pkg::*;
  import vip_axi4_agent_pkg::*;

  localparam int N_BITS_C         = 32;
  localparam int Q_BITS_C         = 11;
  localparam int IIR_BASE_ADDR_C  = 0;
  localparam int IIR_HIGH_ADDR_C  = 2**8 - 1;
  localparam int IIR_ADDR_WIDTH_C = 10;
  localparam int MEM_ADDR_WIDTH_C = 16;
  localparam int MEM_DATA_WIDTH_C = 128;
  localparam int AXI4_ID_C        = 0;

  localparam int VIP_AXI4S_TDATA_WIDTH_C = 32;
  localparam int VIP_AXI4S_TSTRB_WIDTH_C = VIP_AXI4S_TDATA_WIDTH_C/8;
  localparam int VIP_AXI4S_TKEEP_WIDTH_C = 0;
  localparam int VIP_AXI4S_TID_WIDTH_C   = 11;
  localparam int VIP_AXI4S_TDEST_WIDTH_C = 0;
  localparam int VIP_AXI4S_TUSER_WIDTH_C = 0;

  localparam int CFG_DATA_WIDTH_C = 64;

  // Configuration of the VIP (Data)
  localparam vip_axi4s_cfg_t VIP_AXI4S_CFG_C = '{
    VIP_AXI4S_TDATA_WIDTH_P : VIP_AXI4S_TDATA_WIDTH_C,
    VIP_AXI4S_TSTRB_WIDTH_P : VIP_AXI4S_TSTRB_WIDTH_C,
    VIP_AXI4S_TKEEP_WIDTH_P : 0,
    VIP_AXI4S_TID_WIDTH_P   : 0,
    VIP_AXI4S_TDEST_WIDTH_P : 0,
    VIP_AXI4S_TUSER_WIDTH_P : 0
  };

  // Configuration of the VIP (Memory)
  localparam vip_axi4_cfg_t VIP_MEM_CFG_C = '{
    VIP_AXI4_ID_WIDTH_P   : 2,
    VIP_AXI4_ADDR_WIDTH_P : MEM_ADDR_WIDTH_C,
    VIP_AXI4_DATA_WIDTH_P : MEM_DATA_WIDTH_C,
    VIP_AXI4_STRB_WIDTH_P : MEM_DATA_WIDTH_C/8,
    VIP_AXI4_USER_WIDTH_P : 0
  };

  // Configuration of the VIP (Registers)
  localparam vip_axi4_cfg_t VIP_REG_CFG_C = '{
    VIP_AXI4_ID_WIDTH_P   : 2,
    VIP_AXI4_ADDR_WIDTH_P : 16,
    VIP_AXI4_DATA_WIDTH_P : CFG_DATA_WIDTH_C,
    VIP_AXI4_STRB_WIDTH_P : 8,
    VIP_AXI4_USER_WIDTH_P : 0
  };

  `include "fir_reg.sv"
  `include "fir_block.sv"
  `include "register_model.sv"
  `include "vip_axi4_adapter.sv"

  `include "fir_config.sv"
  `include "fir_scoreboard.sv"
  `include "fir_virtual_sequencer.sv"
  `include "fir_env.sv"
  `include "vip_axi4s_seq_lib.sv"

endpackage

`endif
