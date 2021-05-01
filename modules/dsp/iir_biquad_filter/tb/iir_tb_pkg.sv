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

`ifndef IIR_TB_PKG
`define IIR_TB_PKG

package iir_tb_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import iir_biquad_types_pkg::*;

  import bool_pkg::*;
  import clk_rst_types_pkg::*;
  import clk_rst_pkg::*;
  import vip_axi4_types_pkg::*;
  import vip_axi4_agent_pkg::*;
  //import vip_axi4s_types_pkg::*;
  //import vip_axi4s_agent_pkg::*;

  // DUT constants
  localparam int WAVE_WIDTH_C     = 24;
  localparam int COUNTER_WIDTH_C  = 32;
  localparam int AXI_DATA_WIDTH_C = 32;
  localparam int AXI_ID_WIDTH_C   = 32;
  localparam int N_BITS_C         = 32;
  localparam int Q_BITS_C         = 11;

  // Base addresses
  localparam int OSC_BASE_ADDR_C  = 0;
  localparam int IIR_BASE_ADDR_C  = 16;
  localparam int OSC_PSEL_BIT_C   = 0;
  localparam int IIR_PSEL_BIT_C   = 1;

  // Configuration of the VIP (Registers)
  localparam vip_axi4_cfg_t VIP_REG_CFG_C = '{
    VIP_AXI4_ID_WIDTH_P   : 2,
    VIP_AXI4_ADDR_WIDTH_P : 16,
    VIP_AXI4_DATA_WIDTH_P : 64,
    VIP_AXI4_STRB_WIDTH_P : 8,
    VIP_AXI4_USER_WIDTH_P : 0
  };

  // Configuration of the AXI4-S VIP
  //localparam vip_axi4s_cfg_t VIP_AXI4S_CFG_C = '{
  //  VIP_AXI4S_TDATA_WIDTH_P : WAVE_WIDTH_C,
  //  VIP_AXI4S_TSTRB_WIDTH_P : WAVE_WIDTH_C/8,
  //  VIP_AXI4S_TKEEP_WIDTH_P : 0,
  //  VIP_AXI4S_TID_WIDTH_P   : 2,
  //  VIP_AXI4S_TDEST_WIDTH_P : 0,
  //  VIP_AXI4S_TUSER_WIDTH_P : 1
  //};

  // Register model
  `include "iir_reg.sv"
  `include "iir_block.sv"
  `include "register_model.sv"
  `include "vip_axi4_adapter.sv"

  //`include "vip_axi4s_seq_lib.sv"

  //`include "iir_scoreboard.sv"
  `include "iir_virtual_sequencer.sv"
  `include "iir_env.sv"

endpackage

`endif
