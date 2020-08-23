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

`ifndef COR_TB_PKG
`define COR_TB_PKG

package cor_tb_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import vip_axi4s_types_pkg::*;
  import vip_axi4s_pkg::*;

  import cordic_atan_table_pkg::*;
  import cordic_pkg::*;
  import cordic_test_angles_pkg::*;

  // Configuration of the AXI4-S VIP
  localparam vip_axi4s_cfg_t vip_axi4s_cfg = '{
    AXI_DATA_WIDTH_P : 32,
    AXI_STRB_WIDTH_P : 0,
    AXI_KEEP_WIDTH_P : 0,
    AXI_ID_WIDTH_P   : 1,
    AXI_DEST_WIDTH_P : 0,
    AXI_USER_WIDTH_P : 1
  };

  `include "cor_config.sv"
  `include "cor_scoreboard.sv"
  `include "cor_virtual_sequencer.sv"
  `include "cor_env.sv"
  `include "cor_seq_lib.sv"

endpackage

`endif
