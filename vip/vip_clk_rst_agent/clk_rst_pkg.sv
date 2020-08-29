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

`ifndef CLK_RST_PKG
`define CLK_RST_PKG

package clk_rst_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"

  import clk_rst_types_pkg::*;

  `include "clk_rst_item.sv"
  `include "clk_rst_config.sv"
  `include "clk_rst_monitor.sv"
  `include "clk_rst_sequencer.sv"
  `include "clk_rst_driver.sv"
  `include "clk_rst_agent.sv"
  `include "clk_rst_seq_lib.sv"

endpackage

`endif
