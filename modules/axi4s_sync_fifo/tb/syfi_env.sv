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

class syfi_env extends uvm_env;

  `uvm_component_utils_begin(syfi_env)
  `uvm_component_utils_end

  // Agents
  clk_rst_agent                    clk_rst_agent0;
  vip_axi4s_agent #(vip_axi4s_cfg) vip_axi4s_agent_mst0;
  vip_axi4s_agent #(vip_axi4s_cfg) vip_axi4s_agent_slv0;

  // The block configuration, e.g., clk period, reset time
  syfi_config tb_cfg;

  // Scoreboard
  syfi_scoreboard scoreboard0;

  // Virtual sequencer, i.e., a collection of agent sequencers
  syfi_virtual_sequencer virtual_sequencer;



  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction



  function void build_phase(uvm_phase phase);

    super.build_phase(phase);


    if (tb_cfg == null) begin
      `uvm_info(get_type_name(), "No testbench configuration. Creating a new", UVM_LOW)
      tb_cfg = syfi_config::type_id::create("tb_cfg", this);
      void'(uvm_config_db #(syfi_config)::get(this, "", "tb_cfg", tb_cfg));
    end

    `uvm_info(get_type_name(), {"Configuration:\n", tb_cfg.sprint()}, UVM_LOW)

    // Create Agents
    clk_rst_agent0       = clk_rst_agent::type_id::create("clk_rst_agent0", this);
    vip_axi4s_agent_mst0 = vip_axi4s_agent #(vip_axi4s_cfg)::type_id::create("vip_axi4s_agent_mst0", this);
    vip_axi4s_agent_slv0 = vip_axi4s_agent #(vip_axi4s_cfg)::type_id::create("vip_axi4s_agent_slv0", this);

    uvm_config_db #(int)::set(this, {"clk_rst_agent0",       "*"}, "id", 0);
    uvm_config_db #(int)::set(this, {"vip_axi4s_agent_mst0", "*"}, "id", 1);
    uvm_config_db #(int)::set(this, {"vip_axi4s_agent_slv0", "*"}, "id", 2);

    // Create Scoreboards
    scoreboard0 = syfi_scoreboard::type_id::create("scoreboard0", this);

    // Create Virtual Sequencer
    virtual_sequencer = syfi_virtual_sequencer::type_id::create("virtual_sequencer", this);
    uvm_config_db #(syfi_virtual_sequencer)::set(this, {"virtual_sequencer", "*"}, "virtual_sequencer", virtual_sequencer);

  endfunction



  function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    vip_axi4s_agent_mst0.monitor.collected_port.connect(scoreboard0.collected_port_mst0);
    vip_axi4s_agent_slv0.monitor.collected_port.connect(scoreboard0.collected_port_slv0);

    virtual_sequencer.mst0_sequencer     = vip_axi4s_agent_mst0.sequencer;
    virtual_sequencer.slv0_sequencer     = vip_axi4s_agent_slv0.sequencer;
    virtual_sequencer.clk_rst_sequencer0 = clk_rst_agent0.sequencer;

  endfunction

endclass
