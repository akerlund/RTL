////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2021 Fredrik Åkerlund
// https://github.com/akerlund/FPGA
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

class register_model extends uvm_reg_block;

  `uvm_object_utils(register_model)

  osc_block  osc;
  uvm_reg_map reg_map;

  function new (string name = "register_model");
    super.new(name, build_coverage(UVM_NO_COVERAGE));
    uvm_reg::include_coverage("*", UVM_CVR_ALL);
  endfunction

  virtual function void build();

    `uvm_info(get_name(), $sformatf("Creating uvm_reg"), UVM_LOW)
    osc = osc_block::type_id::create("osc");

    `uvm_info(get_name(), $sformatf("Configuring uvm_reg"), UVM_LOW)
    osc.configure(this);

    `uvm_info(get_name(), $sformatf("Building uvm_reg"), UVM_LOW)
    osc.build();

    `uvm_info(get_name(), $sformatf("Creating register map"), UVM_LOW)
    reg_map = create_map("reg_map", 'h0, 8, UVM_LITTLE_ENDIAN);

    default_map = reg_map;

    `uvm_info(get_name(), $sformatf("Adding submap AXI4"), UVM_LOW)
    reg_map.add_submap(osc.default_map, 0);

    lock_model();

  endfunction

endclass
