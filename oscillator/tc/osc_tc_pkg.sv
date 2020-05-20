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

package osc_tc_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;

  import vip_apb3_types_pkg::*;
  import vip_apb3_pkg::*;

  // Import testbench and agent packages here
  import osc_tb_pkg::*;

  // Include testcase files here
  `include "osc_base_test.sv"
  `include "tc_osc_simple_test.sv"

endpackage
