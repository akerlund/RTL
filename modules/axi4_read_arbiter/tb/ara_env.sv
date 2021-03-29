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

class ara_env extends uvm_env;

  `uvm_component_utils_begin(ara_env)
  `uvm_component_utils_end

  clk_rst_agent                    clk_rst_agent0;
  vip_axi4_agent #(VIP_AXI4_CFG_C) rd_agent0;
  vip_axi4_agent #(VIP_AXI4_CFG_C) mem_agent0;

  ara_scoreboard        scoreboard0;
  ara_virtual_sequencer virtual_sequencer;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    // Create Agents
    clk_rst_agent0 = clk_rst_agent::type_id::create("clk_rst_agent0", this);
    rd_agent0      = vip_axi4_agent #(VIP_AXI4_CFG_C)::type_id::create("rd_agent0", this);
    mem_agent0     = vip_axi4_agent #(VIP_AXI4_CFG_C)::type_id::create("mem_agent0", this);

    uvm_config_db #(int)::set(this, {"clk_rst_agent0", "*"}, "id", 0);
    uvm_config_db #(int)::set(this, {"rd_agent0",      "*"}, "id", 1);
    uvm_config_db #(int)::set(this, {"mem_agent0",     "*"}, "id", 4);

    // Create Scoreboards
    scoreboard0 = ara_scoreboard::type_id::create("scoreboard0", this);

    // Create Virtual Sequencer
    virtual_sequencer = ara_virtual_sequencer::type_id::create("virtual_sequencer", this);
    uvm_config_db #(ara_virtual_sequencer)::set(this, {"virtual_sequencer", "*"}, "virtual_sequencer", virtual_sequencer);
  endfunction


  function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    rd_agent0.monitor.araddr_port.connect(scoreboard0.ing_araddr_port);
    rd_agent0.monitor.rdata_port.connect(scoreboard0.ing_rdata_port);
    mem_agent0.monitor.rdata_port.connect(scoreboard0.egr_rdata_port);

    virtual_sequencer.clk_rst_sequencer0 = clk_rst_agent0.sequencer;
    virtual_sequencer.rd_sequencer0      = rd_agent0.sequencer;
  endfunction
endclass
