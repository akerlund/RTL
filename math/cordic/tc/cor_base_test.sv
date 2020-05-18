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

class cor_base_test extends uvm_test;

  `uvm_component_utils(cor_base_test)

  cor_env               tb_env;
  cor_config            tb_cfg;

  cor_virtual_sequencer v_sqr;

  uvm_table_printer printer;

  function new(string name = "cor_base_test", uvm_component parent = null);

    super.new(name, parent);

  endfunction



  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    printer = new();
    printer.knobs.depth = 3;

    uvm_config_db #(uvm_verbosity)::set(this, "*", "recording_detail", UVM_FULL);

    tb_env = cor_env::type_id::create("tb_env", this);

    tb_cfg = cor_config::type_id::create("tb_cfg", this);

  endfunction



  function void end_of_elaboration_phase(uvm_phase phase);

    `uvm_info(get_type_name(), $sformatf("Topology of the test:\n%s", this.sprint(printer)), UVM_LOW)
    v_sqr = tb_env.virtual_sequencer;

    tb_env.tb_cfg = tb_cfg;

  endfunction

endclass
