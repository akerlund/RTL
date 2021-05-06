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

class mix_env extends uvm_env;

  `uvm_component_utils_begin(mix_env)
  `uvm_component_utils_end

  // Agents
  vip_axi4s_agent #(VIP_AXI4S_CFG_C) vip_axi4s_agent_mst0;
  vip_axi4s_agent #(VIP_AXI4S_CFG_C) vip_axi4s_agent_slv0;

  // Agent configurations
  vip_axi4s_config vip_axi4s_config_mst;
  vip_axi4s_config vip_axi4s_config_slv;

  // Scoreboard
  mix_scoreboard scoreboard0;

  // Virtual sequencer, i.e., a collection of agent sequencers
  mix_virtual_sequencer virtual_sequencer;



  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction



  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    // Configurations
    vip_axi4s_config_mst = vip_axi4s_config::type_id::create("vip_axi4s_config_mst", this);
    vip_axi4s_config_slv = vip_axi4s_config::type_id::create("vip_axi4s_config_slv", this);
    vip_axi4s_config_slv.vip_axi4s_agent_type = VIP_AXI4S_SLAVE_AGENT_E;

    // Create Agents
    vip_axi4s_agent_mst0 = vip_axi4s_agent #(VIP_AXI4S_CFG_C)::type_id::create("vip_axi4s_agent_mst0", this);
    vip_axi4s_agent_slv0 = vip_axi4s_agent #(VIP_AXI4S_CFG_C)::type_id::create("vip_axi4s_agent_slv0", this);

    uvm_config_db #(int)::set(this, {"vip_axi4s_agent_mst0", "*"}, "id", 0);
    uvm_config_db #(int)::set(this, {"vip_axi4s_agent_slv0", "*"}, "id", 1);

    uvm_config_db #(vip_axi4s_config)::set(this, {"vip_axi4s_agent_mst0", "*"}, "cfg", vip_axi4s_config_mst);
    uvm_config_db #(vip_axi4s_config)::set(this, {"vip_axi4s_agent_slv0", "*"}, "cfg", vip_axi4s_config_slv);

    // Create Scoreboards
    scoreboard0 = mix_scoreboard::type_id::create("scoreboard0", this);

    // Create Virtual Sequencer
    virtual_sequencer = mix_virtual_sequencer::type_id::create("virtual_sequencer", this);
    uvm_config_db #(mix_virtual_sequencer)::set(this, {"virtual_sequencer", "*"}, "virtual_sequencer", virtual_sequencer);

  endfunction



  function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    vip_axi4s_agent_mst0.monitor.tdata_port.connect(scoreboard0.collected_port_mst0);
    vip_axi4s_agent_slv0.monitor.tdata_port.connect(scoreboard0.collected_port_slv0);

    virtual_sequencer.mst0_sequencer = vip_axi4s_agent_mst0.sequencer;

  endfunction

endclass
