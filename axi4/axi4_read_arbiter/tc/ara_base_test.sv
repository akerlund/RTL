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

class ara_base_test extends uvm_test;

  `uvm_component_utils(ara_base_test)

  ara_env               tb_env;
  ara_virtual_sequencer v_sqr;

  bit test_pass = 1;

  uvm_table_printer printer;

  // Write Address Channel
  int nr_of_araddr;
  int nr_of_arid;

  // Memory Agent configuration
  int max_read_requests = 32;
  int max_ooo_bursts    = 0;
  int memory_depth      = 1;

  function new(string name = "ara_base_test", uvm_component parent = null);

    super.new(name, parent);

  endfunction



  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    uvm_config_db #(uvm_verbosity)::set(this, "*", "recording_detail", UVM_FULL);

    tb_env = ara_env::type_id::create("tb_env", this);

    printer = new();
    printer.knobs.depth = 3;


  endfunction


  function void end_of_elaboration_phase(uvm_phase phase);

    // Configure the Memory Agent
    tb_env.axi4_memory_agent0.cfg.configure_parameters(
      max_read_requests,
      max_ooo_bursts,
      memory_depth
    );

    `uvm_info(get_name(), {"Configuration:\n", tb_env.axi4_memory_agent0.cfg.sprint()}, UVM_LOW)

    `uvm_info(get_type_name(), $sformatf("Topology of the test:\n%s", this.sprint(printer)), UVM_LOW)
    v_sqr = tb_env.virtual_sequencer;

  endfunction

endclass
