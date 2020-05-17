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

package hsl_tc_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;

  import vip_axi4s_types_pkg::*;
  import vip_axi4s_pkg::*;

  // Import testbench and agent packages here
  import hsl_tb_pkg::*;

  // Include testcase files here
  `include "hsl_base_test.sv"
  `include "tc_hsl_simple_test.sv"

endpackage
