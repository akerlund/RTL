////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2026 Fredrik Åkerlund
// https://github.com/akerlund/RTL
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

class awa_env extends uvm_env;

  `uvm_component_utils_begin(awa_env)
  `uvm_component_utils_end

  clk_rst_agent                    clk_rst_agent0;
  vip_axi4_agent #(VIP_AXI4_CFG_C, VIP_AXI4_ROLE_MANAGER_E) wr_agent0;
  vip_axi4_agent #(VIP_AXI4_CFG_C, VIP_AXI4_ROLE_MANAGER_E) wr_agent1;
  vip_axi4_agent #(VIP_AXI4_CFG_C, VIP_AXI4_ROLE_MANAGER_E) wr_agent2;
  vip_axi4_agent #(VIP_AXI4_CFG_C, VIP_AXI4_ROLE_MANAGER_E) wr_agent3;
  vip_axi4_agent #(VIP_AXI4_CFG_C, VIP_AXI4_ROLE_SUBORDINATE_E) mem_agent0;

  awa_scoreboard        scoreboard0;
  awa_virtual_sequencer virtual_sequencer;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    // Create Agents
    clk_rst_agent0 = clk_rst_agent::type_id::create("clk_rst_agent0", this);
    wr_agent0      = vip_axi4_agent #(VIP_AXI4_CFG_C, VIP_AXI4_ROLE_MANAGER_E)::type_id::create("wr_agent0",  this);
    wr_agent1      = vip_axi4_agent #(VIP_AXI4_CFG_C, VIP_AXI4_ROLE_MANAGER_E)::type_id::create("wr_agent1",  this);
    wr_agent2      = vip_axi4_agent #(VIP_AXI4_CFG_C, VIP_AXI4_ROLE_MANAGER_E)::type_id::create("wr_agent2",  this);
    wr_agent3      = vip_axi4_agent #(VIP_AXI4_CFG_C, VIP_AXI4_ROLE_MANAGER_E)::type_id::create("wr_agent3",  this);
    mem_agent0     = vip_axi4_agent #(VIP_AXI4_CFG_C, VIP_AXI4_ROLE_SUBORDINATE_E)::type_id::create("mem_agent0", this);

    uvm_config_db #(int)::set(this, {"clk_rst_agent0", "*"}, "id", 0);
    uvm_config_db #(int)::set(this, {"wr_agent0",      "*"}, "id", 1);
    uvm_config_db #(int)::set(this, {"wr_agent1",      "*"}, "id", 2);
    uvm_config_db #(int)::set(this, {"wr_agent2",      "*"}, "id", 3);
    uvm_config_db #(int)::set(this, {"wr_agent3",      "*"}, "id", 4);
    uvm_config_db #(int)::set(this, {"mem_agent0",     "*"}, "id", 5);

    // Create Scoreboards
    scoreboard0 = awa_scoreboard::type_id::create("scoreboard0", this);

    // Create Virtual Sequencer
    virtual_sequencer = awa_virtual_sequencer::type_id::create("virtual_sequencer", this);
    uvm_config_db #(awa_virtual_sequencer)::set(this, {"virtual_sequencer", "*"}, "virtual_sequencer", virtual_sequencer);

  endfunction


  function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    wr_agent0.monitor.awaddr_port.connect(scoreboard0.awaddr_port0);
    wr_agent0.monitor.wdata_port.connect(scoreboard0.wdata_port0);
    wr_agent1.monitor.awaddr_port.connect(scoreboard0.awaddr_port1);
    wr_agent1.monitor.wdata_port.connect(scoreboard0.wdata_port1);
    wr_agent2.monitor.awaddr_port.connect(scoreboard0.awaddr_port2);
    wr_agent2.monitor.wdata_port.connect(scoreboard0.wdata_port2);
    wr_agent3.monitor.awaddr_port.connect(scoreboard0.awaddr_port3);
    wr_agent3.monitor.wdata_port.connect(scoreboard0.wdata_port3);
    mem_agent0.monitor.wdata_port.connect(scoreboard0.mem_port);

    virtual_sequencer.clk_rst_sequencer0 = clk_rst_agent0.sequencer;
    virtual_sequencer.wr_sequencer0      = wr_agent0.sequencer;
    virtual_sequencer.wr_sequencer1      = wr_agent1.sequencer;
    virtual_sequencer.wr_sequencer2      = wr_agent2.sequencer;
    virtual_sequencer.wr_sequencer3      = wr_agent3.sequencer;

  endfunction

endclass