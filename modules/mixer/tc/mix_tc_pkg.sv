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

`ifndef MIX_TC_PKG
`define MIX_TC_PKG

package mix_tc_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;

  import vip_axi4s_types_pkg::*;
  import vip_axi4s_pkg::*;

  // Import testbench and agent packages here
  import mix_tb_pkg::*;

  // Include testcase files here
  `include "mix_base_test.sv"
  `include "tc_positive_signals.sv"
  `include "tc_random_signals.sv"

endpackage

`endif
