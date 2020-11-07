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

`ifndef SYFI_TC_PKG
`define SYFI_TC_PKG

package syfi_tc_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;

  import vip_axi4s_types_pkg::*;
  import vip_axi4s_pkg::*;

  import clk_rst_types_pkg::*;
  import clk_rst_pkg::*;

  // Import testbench and agent packages here
  import syfi_tb_pkg::*;

  // Include testcase files here
  `include "syfi_base_test.sv"
  `include "tc_syfi_basic.sv"
  `include "tc_syfi_back_pressure.sv"
  `include "tc_syfi_fill_up_read_out.sv"

endpackage

`endif
