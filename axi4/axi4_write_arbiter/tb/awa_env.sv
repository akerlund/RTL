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

class awa_env extends uvm_env;

  `uvm_component_utils_begin(awa_env)
  `uvm_component_utils_end

  // Agents
  axi4_write_agent  #(vip_axi4_cfg) axi4_write_agent0;
  axi4_write_agent  #(vip_axi4_cfg) axi4_write_agent1;
  axi4_write_agent  #(vip_axi4_cfg) axi4_write_agent2;
  axi4_memory_agent #(vip_axi4_cfg) axi4_memory_agent0;

  // Agent configuration
  axi4_write_config  axi4_mst_config;
  axi4_memory_config axi4_mem_config;

  // The block configuration, e.g., clk period, reset time
  awa_config tb_cfg;

  // Scoreboard
  awa_scoreboard scoreboard0;

  // Virtual sequencer, i.e., a collection of agent sequencers
  awa_virtual_sequencer virtual_sequencer;



  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction



  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (tb_cfg == null) begin
      `uvm_info(get_type_name(), "No testbench configuration. Creating a new", UVM_LOW)
      tb_cfg = awa_config::type_id::create("tb_cfg", this);
      void'(uvm_config_db #(awa_config)::get(this, "", "tb_cfg", tb_cfg));
    end

    `uvm_info(get_type_name(), {"Configuration:\n", tb_cfg.sprint()}, UVM_LOW)

    // Configurations
    axi4_mst_config = axi4_write_config::type_id::create("axi4_mst_config",  this);
    axi4_mem_config = axi4_memory_config::type_id::create("axi4_mem_config", this);

    // Create Agents
    axi4_write_agent0  = axi4_write_agent #(vip_axi4_cfg)::type_id::create("axi4_write_agent0",   this);
    axi4_write_agent1  = axi4_write_agent #(vip_axi4_cfg)::type_id::create("axi4_write_agent1",   this);
    axi4_write_agent2  = axi4_write_agent #(vip_axi4_cfg)::type_id::create("axi4_write_agent2",   this);
    axi4_memory_agent0 = axi4_memory_agent #(vip_axi4_cfg)::type_id::create("axi4_memory_agent0", this);

    uvm_config_db #(int)::set(this, {"axi4_write_agent0", "*"},  "id", 0);
    uvm_config_db #(int)::set(this, {"axi4_write_agent1", "*"},  "id", 1);
    uvm_config_db #(int)::set(this, {"axi4_write_agent2", "*"},  "id", 2);
    uvm_config_db #(int)::set(this, {"axi4_memory_agent0", "*"}, "id", 3);

    uvm_config_db #(axi4_write_config)::set(this,  {"axi4_write_agent0", "*"},  "cfg", axi4_mst_config);
    uvm_config_db #(axi4_write_config)::set(this,  {"axi4_write_agent1", "*"},  "cfg", axi4_mst_config);
    uvm_config_db #(axi4_write_config)::set(this,  {"axi4_write_agent2", "*"},  "cfg", axi4_mst_config);
    uvm_config_db #(axi4_memory_config)::set(this, {"axi4_memory_agent0", "*"}, "cfg", axi4_mem_config);

    // Create Scoreboards
    scoreboard0 = awa_scoreboard::type_id::create("scoreboard0", this);

    // Create Virtual Sequencer
    virtual_sequencer = awa_virtual_sequencer::type_id::create("virtual_sequencer", this);
    uvm_config_db #(awa_virtual_sequencer)::set(this, {"virtual_sequencer", "*"}, "virtual_sequencer", virtual_sequencer);

  endfunction



  function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    // Write Agents
    axi4_write_agent0.monitor.write_address_port.connect(scoreboard0.address_port0);
    axi4_write_agent0.monitor.write_data_port.connect(scoreboard0.data_port0);
    axi4_write_agent1.monitor.write_address_port.connect(scoreboard0.address_port1);
    axi4_write_agent1.monitor.write_data_port.connect(scoreboard0.data_port1);
    axi4_write_agent2.monitor.write_address_port.connect(scoreboard0.address_port2);
    axi4_write_agent2.monitor.write_data_port.connect(scoreboard0.data_port2);

    // Memory Agent
    axi4_memory_agent0.monitor.write_data_port.connect(scoreboard0.mem_port);

    virtual_sequencer.write_sequencer0 = axi4_write_agent0.sequencer;
    virtual_sequencer.write_sequencer1 = axi4_write_agent1.sequencer;
    virtual_sequencer.write_sequencer2 = axi4_write_agent2.sequencer;

  endfunction

endclass