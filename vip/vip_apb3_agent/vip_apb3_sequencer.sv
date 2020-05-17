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

class vip_apb3_sequencer #(
  vip_apb3_cfg_t vip_cfg = '{default: '0}
  ) extends uvm_sequencer #(vip_apb3_item #(vip_cfg));

  `uvm_component_param_utils(vip_apb3_sequencer #(vip_cfg));

  vip_apb3_config cfg;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass
