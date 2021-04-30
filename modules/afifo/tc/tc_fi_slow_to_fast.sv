////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2021 Fredrik Åkerlund
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

class tc_fi_slow_to_fast extends tc_fi_basic;

  `uvm_component_utils(tc_fi_slow_to_fast)

  function new(string name = "tc_fi_slow_to_fast", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    clk_rst_config0.clock_period = 333.3; // 3MHz
    clk_rst_config1.clock_period = 58.8;  // 17MHz
  endfunction


  task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask

endclass
