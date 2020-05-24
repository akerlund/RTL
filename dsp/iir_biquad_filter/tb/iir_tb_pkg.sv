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

  import vip_apb3_types_pkg::*;
  import vip_apb3_pkg::*;
  import iir_biquad_types_pkg::*;

  localparam int WAVE_WIDTH_C     = 24;
  localparam int COUNTER_WIDTH_C  = 32;
  localparam int AXI_DATA_WIDTH_C = 32;
  localparam int AXI_ID_WIDTH_C   = 32;
  localparam int N_BITS_C         = 24;
  localparam int Q_BITS_C         = 16;

  // Configuration of the APB3 VIP
  localparam vip_apb3_cfg_t vip_apb3_cfg = '{
    APB_ADDR_WIDTH_P : 8,
    APB_DATA_WIDTH_P : 32
  };

  `include "iir_config.sv"
  `include "iir_scoreboard.sv"
  `include "iir_virtual_sequencer.sv"
  `include "iir_env.sv"
  `include "iir_seq_lib.sv"

endpackage

`endif
