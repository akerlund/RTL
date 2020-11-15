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
  import oscillator_types_pkg::*;
  import osc_apb_slave_addr_pkg::*;

  // DUT constants
  localparam int SYS_CLK_FREQUENCY_C  = 125000000;
  localparam int PRIME_FREQUENCY_C    = 1000000;
  localparam int WAVE_WIDTH_C         = 24;
  localparam int DUTY_CYCLE_DIVIDER_C = 1000;
  localparam int N_BITS_C             = 32;
  localparam int Q_BITS_C             = 11;
  localparam int AXI_DATA_WIDTH_C     = 32;
  localparam int AXI_ID_WIDTH_C       = 32;
  localparam int AXI_ID_C             = 32'hDEADBEA7;

  localparam int NR_OF_CHANNELS_C = 2;

  // APB
  localparam int OSC_BASE_ADDR_C  = 0;
  localparam int OSC_PSEL_BIT_C   = 0;

  // Configuration of the APB3 VIP
  localparam vip_apb3_cfg_t vip_apb3_cfg = '{
    APB_ADDR_WIDTH_P   : 8,
    APB_DATA_WIDTH_P   : 32,
    APB_NR_OF_SLAVES_P : 1
  };


  `include "osc_config.sv"
  `include "osc_scoreboard.sv"
  `include "osc_virtual_sequencer.sv"
  `include "osc_env.sv"
  `include "osc_seq_lib.sv"

endpackage

`endif
