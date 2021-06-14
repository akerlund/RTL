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

  clk_rst_agent                      clk_rst_agent0;
  vip_axi4s_agent #(VIP_AXI4S_CFG_C) mst_agent0;
  vip_axi4s_agent #(VIP_AXI4S_CFG_C) slv_agent0;

  vip_axi4s_config vip_axi4s_config_mst;
  vip_axi4s_config vip_axi4s_config_slv;

  mix_scoreboard        scoreboard0;
  mix_virtual_sequencer virtual_sequencer;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    clk_rst_agent0 = clk_rst_agent::type_id::create("clk_rst_agent0", this);
    mst_agent0     = vip_axi4s_agent #(VIP_AXI4S_CFG_C)::type_id::create("mst_agent0", this);
    slv_agent0     = vip_axi4s_agent #(VIP_AXI4S_CFG_C)::type_id::create("slv_agent0", this);

    uvm_config_db #(int)::set(this, {"clk_rst_agent0", "*"}, "id", 0);
    uvm_config_db #(int)::set(this, {"mst_agent0",     "*"}, "id", 1);
    uvm_config_db #(int)::set(this, {"slv_agent0",     "*"}, "id", 2);

    scoreboard0       = mix_scoreboard::type_id::create("scoreboard0", this);
    virtual_sequencer = mix_virtual_sequencer::type_id::create("virtual_sequencer", this);
    uvm_config_db #(mix_virtual_sequencer)::set(this, {"virtual_sequencer", "*"}, "virtual_sequencer", virtual_sequencer);

  endfunction


  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    mst_agent0.monitor.tdata_port.connect(scoreboard0.collected_port_mst0);
    slv_agent0.monitor.tdata_port.connect(scoreboard0.collected_port_slv0);
    virtual_sequencer.clk_rst_sequencer0 = clk_rst_agent0.sequencer;
    virtual_sequencer.mst0_sequencer     = mst_agent0.sequencer;
  endfunction

endclass
