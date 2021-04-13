////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
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

`ifndef OSC_TB_PKG
`define OSC_TB_PKG

package osc_tb_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import oscillator_types_pkg::*;
  import osc_address_pkg::*;

  import bool_pkg::*;
  import clk_rst_types_pkg::*;
  import clk_rst_pkg::*;
  import vip_axi4_types_pkg::*;
  import vip_axi4_agent_pkg::*;

  // DUT constants
  localparam int SYS_CLK_FREQUENCY_C  = 125000000;
  localparam int PRIME_FREQUENCY_C    = 1000000;
  localparam int SAMPLING_FREQUENCY_C = 44100;
  localparam int WAVE_WIDTH_C         = 24;
  localparam int DUTY_CYCLE_DIVIDER_C = 1000;
  localparam int N_BITS_C             = 32;
  localparam int Q_BITS_C             = 11;
  localparam int AXI_DATA_WIDTH_C     = 32;
  localparam int AXI_ID_WIDTH_C       = 32;
  localparam int AXI_ID_C             = 32'hDEADBEA7;
  localparam int NR_OF_CHANNELS_C     = 2;
  localparam int COUNTER_WIDTH_C      = $clog2(SYS_CLK_FREQUENCY_C / SAMPLING_FREQUENCY_C);

  // Configuration of the VIP (Registers)
  localparam vip_axi4_cfg_t VIP_REG_CFG_C = '{
    VIP_AXI4_ID_WIDTH_P   : 2,
    VIP_AXI4_ADDR_WIDTH_P : 16,
    VIP_AXI4_DATA_WIDTH_P : 64,
    VIP_AXI4_STRB_WIDTH_P : 8,
    VIP_AXI4_USER_WIDTH_P : 0
  };

  // Register model
  `include "osc_reg.sv"
  `include "osc_block.sv"
  `include "register_model.sv"
  `include "vip_axi4_adapter.sv"

  `include "osc_virtual_sequencer.sv"
  `include "osc_env.sv"

endpackage

`endif
