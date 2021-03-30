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

class vec_virtual_sequencer extends uvm_virtual_sequencer;

  `uvm_component_utils(vec_virtual_sequencer)

  vip_axi4s_sequencer #(axi4s_cfg) mst0_sequencer;
  vip_axi4s_sequencer #(axi4s_cfg) slv0_sequencer;
  clk_rst_sequencer                clk_rst_sequencer0;
  clk_rst_sequencer                clk_rst_sequencer1;

  function new(string name = "virtual_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass
