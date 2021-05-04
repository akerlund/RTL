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

class tc_iir_coefficient_check extends iir_base_test;

  `uvm_component_utils(tc_iir_coefficient_check)

  function new(string name = "tc_iir_coefficient_check", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction


  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    `uvm_info(get_name(), $sformatf("Reading an IIR configuration"), UVM_LOW)
    reg_model.iir.iir_w0.read(uvm_status,   value);
    reg_model.iir.iir_alfa.read(uvm_status, value);
    reg_model.iir.iir_b0.read(uvm_status,   value);
    reg_model.iir.iir_b1.read(uvm_status,   value);
    reg_model.iir.iir_b2.read(uvm_status,   value);
    reg_model.iir.iir_a0.read(uvm_status,   value);
    reg_model.iir.iir_a1.read(uvm_status,   value);
    reg_model.iir.iir_a2.read(uvm_status,   value);
    phase.drop_objection(this);
  endtask

endclass
