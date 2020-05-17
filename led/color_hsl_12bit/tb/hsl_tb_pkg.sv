////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2020 Fredrik Åkerlund
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Description:
//
////////////////////////////////////////////////////////////////////////////////

`ifndef HSL_TB_PKG
`define HSL_TB_PKG

package hsl_tb_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import vip_axi4s_types_pkg::*;
  import vip_axi4s_pkg::*;
  import vip_math_pkg::*;

  import gamma_12bit_lut_pkg::*;

  // Configuration of the AXI4-S VIP
  localparam vip_axi4s_cfg_t vip_axi4s_cfg = '{
    AXI_DATA_WIDTH_P : 36,
    AXI_STRB_WIDTH_P : 1,
    AXI_KEEP_WIDTH_P : 1,
    AXI_ID_WIDTH_P   : 1,
    AXI_DEST_WIDTH_P : 1,
    AXI_USER_WIDTH_P : 1
  };

  `include "hsl_config.sv"
  `include "hsl_scoreboard.sv"
  `include "hsl_virtual_sequencer.sv"
  `include "hsl_env.sv"
  `include "hsl_seq_lib.sv"

endpackage

`endif
