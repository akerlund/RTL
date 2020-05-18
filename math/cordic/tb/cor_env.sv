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

class cor_env extends uvm_env;

  `uvm_component_utils_begin(cor_env)
  `uvm_component_utils_end

  // Agents
  vip_axi4s_agent #(vip_axi4s_cfg) vip_axi4s_agent0;

  // Agent configurations
  vip_axi4s_config vip_axi4s_config0;

  // The block configuration, e.g., clk period, reset time
  cor_config tb_cfg;

  // Scoreboard
  cor_scoreboard scoreboard0;

  // Virtual sequencer, i.e., a collection of agent sequencers
  cor_virtual_sequencer virtual_sequencer;



  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction



  function void build_phase(uvm_phase phase);

    super.build_phase(phase);


    if (tb_cfg == null) begin
      `uvm_info(get_type_name(), "No testbench configuration. Creating a new", UVM_LOW)
      tb_cfg = cor_config::type_id::create("tb_cfg", this);
      void'(uvm_config_db #(cor_config)::get(this, "", "tb_cfg", tb_cfg));
    end

    `uvm_info(get_type_name(), {"Configuration:\n", tb_cfg.sprint()}, UVM_LOW)

    // Configurations
    vip_axi4s_config0 = vip_axi4s_config::type_id::create("vip_axi4s_config0", this);

    // Create Agents
    vip_axi4s_agent0 = vip_axi4s_agent #(vip_axi4s_cfg)::type_id::create("vip_axi4s_agent0", this);

    uvm_config_db #(int)::set(this, {"vip_axi4s_agent0", "*"}, "id", 0);

    uvm_config_db #(vip_axi4s_config)::set(this, {"vip_axi4s_agent0", "*"}, "cfg", vip_axi4s_config0);

    // Create Scoreboards
    scoreboard0 = cor_scoreboard::type_id::create("scoreboard0", this);

    // Create Virtual Sequencer
    virtual_sequencer = cor_virtual_sequencer::type_id::create("virtual_sequencer", this);
    uvm_config_db #(cor_virtual_sequencer)::set(this, {"virtual_sequencer", "*"}, "virtual_sequencer", virtual_sequencer);

  endfunction



  function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);
    virtual_sequencer.axi4s_sequencer = vip_axi4s_agent0.sequencer;

  endfunction

endclass
