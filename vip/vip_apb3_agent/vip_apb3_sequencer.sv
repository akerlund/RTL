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

class vip_apb3_sequencer #(
  vip_apb3_cfg_t vip_cfg = '{default: '0}
  ) extends uvm_sequencer #(vip_apb3_item #(vip_cfg));

  `uvm_component_param_utils(vip_apb3_sequencer #(vip_cfg));

  vip_apb3_config cfg;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass
