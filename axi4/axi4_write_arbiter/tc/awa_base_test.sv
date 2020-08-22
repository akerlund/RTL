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

class awa_base_test extends uvm_test;

  `uvm_component_utils(awa_base_test)

  awa_env               tb_env;
  awa_virtual_sequencer v_sqr;

  bit test_pass = 1;

  uvm_table_printer printer;

  // Write Address Channel
  int nr_of_awaddr;
  int nr_of_awid;

  // Write Data Channel
  int use_response_channel = 0;

  // Memory Agent configuration
  int memory_depth = 9;

  // Backpressure on 'wready'. Time and period are number of clock periods.
  int wready_back_pressure_enabled = 0;
  int min_wready_deasserted_time   = 1;
  int max_wready_deasserted_time   = 10;
  int min_wready_deasserted_period = 10;
  int max_wready_deasserted_period = AXI4_MAX_BURST_LENGTH_C;

  function new(string name = "awa_base_test", uvm_component parent = null);

    super.new(name, parent);

  endfunction



  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    uvm_config_db #(uvm_verbosity)::set(this, "*", "recording_detail", UVM_FULL);

    tb_env = awa_env::type_id::create("tb_env", this);

    printer = new();
    printer.knobs.depth = 3;

  endfunction



  function void end_of_elaboration_phase(uvm_phase phase);

    `uvm_info(get_type_name(), $sformatf("Topology of the test:\n%s", this.sprint(printer)), UVM_LOW)
    v_sqr = tb_env.virtual_sequencer;

    // Configure the Write Agent
    tb_env.axi4_write_agent0.cfg.use_response_channel = 0;

    // Configure the Memory Agent
    tb_env.axi4_memory_agent0.cfg.configure_parameters(
      '0,
      '0,
      memory_depth,
      1
    );

    tb_env.axi4_memory_agent0.cfg.set_randomize_memory(0);
    tb_env.axi4_memory_agent0.cfg.set_wready_back_pressure_enabled(wready_back_pressure_enabled);
    tb_env.axi4_memory_agent0.cfg.configure_wready_parameters(min_wready_deasserted_time,
                                                              max_wready_deasserted_time,
                                                              min_wready_deasserted_period,
                                                              max_wready_deasserted_period
                                                            );

    `uvm_info(get_name(), {"Configuration:\n", tb_env.axi4_memory_agent0.cfg.sprint()}, UVM_LOW)
  endfunction

endclass
