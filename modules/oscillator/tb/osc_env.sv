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

class osc_env extends uvm_env;

  `uvm_component_utils_begin(osc_env)
  `uvm_component_utils_end

  // Agents
  vip_apb3_agent #(vip_apb3_cfg) vip_apb3_agent0;

  // Agent configurations
  vip_apb3_config vip_apb3_config0;

  // The block configuration, e.g., clk period, reset time
  osc_config tb_cfg;

  // Scoreboard
  osc_scoreboard scoreboard0;

  // Virtual sequencer, i.e., a collection of agent sequencers
  osc_virtual_sequencer virtual_sequencer;



  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction



  function void build_phase(uvm_phase phase);

    super.build_phase(phase);


    if (tb_cfg == null) begin
      `uvm_info(get_type_name(), "No testbench configuration. Creating a new", UVM_LOW)
      tb_cfg = osc_config::type_id::create("tb_cfg", this);
      void'(uvm_config_db #(osc_config)::get(this, "", "tb_cfg", tb_cfg));
    end

    `uvm_info(get_type_name(), {"Configuration:\n", tb_cfg.sprint()}, UVM_LOW)

    // Configurations
    vip_apb3_config0 = vip_apb3_config::type_id::create("vip_apb3_config0", this);

    // Create Agents
    vip_apb3_agent0 = vip_apb3_agent #(vip_apb3_cfg)::type_id::create("vip_apb3_agent0", this);

    uvm_config_db #(int)::set(this, {"vip_apb3_agent0", "*"}, "id", 0);

    uvm_config_db #(vip_apb3_config)::set(this, {"vip_apb3_agent0", "*"}, "cfg", vip_apb3_config0);

    // Create Scoreboards
    scoreboard0 = osc_scoreboard::type_id::create("scoreboard0", this);

    // Create Virtual Sequencer
    virtual_sequencer = osc_virtual_sequencer::type_id::create("virtual_sequencer", this);
    uvm_config_db #(osc_virtual_sequencer)::set(this, {"virtual_sequencer", "*"}, "virtual_sequencer", virtual_sequencer);

  endfunction



  function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);
    virtual_sequencer.apb3_sequencer = vip_apb3_agent0.sequencer;

  endfunction

endclass
