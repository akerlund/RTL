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

`ifndef SYiir_TC_PKG
`define SYiir_TC_PKG

package iir_tc_pkg;

  `include "uvm_macros.svh"
  import uvm_pkg::*;

  import iir_tb_pkg::*;

  import bool_pkg::*;
  import report_server_pkg::*;
  import clk_rst_types_pkg::*;
  import clk_rst_pkg::*;
  import vip_axi4s_types_pkg::*;
  import vip_axi4s_agent_pkg::*;
  import vip_axi4_types_pkg::*;
  import vip_axi4_agent_pkg::*;

  `include "iir_base_test.sv"
  `include "tc_iir_basic.sv"
  //`include "tc_iir_basic_configuration.sv"
  //`include "tc_iir_reconfiguration.sv"
  //`include "tc_iir_coefficient_check.sv"

endpackage

`endif
