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

class cor_env extends uvm_env;

  `uvm_component_utils_begin(cor_env)
  `uvm_component_utils_end

  protected virtual clk_rst_if vif;

  // Agents
  clk_rst_agent                      clk_rst_agent0;
  vip_axi4s_agent #(VIP_AXI4S_CFG_C) mst_agent0;

  //cor_scoreboard        scoreboard0;
  cor_virtual_sequencer virtual_sequencer;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  //----------------------------------------------------------------------------
  //
  //----------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db #(virtual clk_rst_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"});
    end

    // Create Agents
    clk_rst_agent0 = clk_rst_agent::type_id::create("clk_rst_agent0", this);
    mst_agent0     = vip_axi4s_agent #(VIP_AXI4S_CFG_C)::type_id::create("mst_agent0",  this);

    uvm_config_db #(int)::set(this, {"clk_rst_agent0", "*"}, "id", 0);
    uvm_config_db #(int)::set(this, {"mst_agent0",     "*"}, "id", 1);

    // Create Scoreboards
    //scoreboard0 = cor_scoreboard::type_id::create("scoreboard0", this);

    // Create Virtual Sequencer
    virtual_sequencer = cor_virtual_sequencer::type_id::create("virtual_sequencer", this);
    uvm_config_db #(cor_virtual_sequencer)::set(this, {"virtual_sequencer", "*"}, "virtual_sequencer", virtual_sequencer);

  endfunction


  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    virtual_sequencer.clk_rst_sequencer0 = clk_rst_agent0.sequencer;
    virtual_sequencer.mst_sequencer      = mst_agent0.sequencer;
  endfunction

endclass
