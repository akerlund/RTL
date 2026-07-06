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

class arb_env extends uvm_env;

  `uvm_component_utils_begin(arb_env)
  `uvm_component_utils_end

  clk_rst_agent                      clk_rst_agent0;
  vip_axi4s_agent #(VIP_AXI4S_CFG_C) mst_agent_0;
  vip_axi4s_agent #(VIP_AXI4S_CFG_C) mst_agent_1;
  vip_axi4s_agent #(VIP_AXI4S_CFG_C) mst_agent_2;
  vip_axi4s_agent #(VIP_AXI4S_CFG_C) slv_agent_0;

  arb_scoreboard        scoreboard0;
  arb_virtual_sequencer virtual_sequencer;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  //----------------------------------------------------------------------------
  //
  //----------------------------------------------------------------------------
  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    // Create Agents
    clk_rst_agent0 = clk_rst_agent::type_id::create("clk_rst_agent0", this);
    mst_agent_0    = vip_axi4s_agent #(VIP_AXI4S_CFG_C)::type_id::create("mst_agent0", this);
    mst_agent_1    = vip_axi4s_agent #(VIP_AXI4S_CFG_C)::type_id::create("mst_agent1", this);
    mst_agent_2    = vip_axi4s_agent #(VIP_AXI4S_CFG_C)::type_id::create("mst_agent2", this);
    slv_agent_0    = vip_axi4s_agent #(VIP_AXI4S_CFG_C)::type_id::create("slv_agent0", this);

    uvm_config_db #(int)::set(this, {"clk_rst_agent0", "*"}, "id", 0);
    uvm_config_db #(int)::set(this, {"mst_agent0",     "*"}, "id", 1);
    uvm_config_db #(int)::set(this, {"mst_agent1",     "*"}, "id", 2);
    uvm_config_db #(int)::set(this, {"mst_agent2",     "*"}, "id", 3);
    uvm_config_db #(int)::set(this, {"slv_agent0",     "*"}, "id", 4);

    // Create Scoreboards
    scoreboard0 = arb_scoreboard::type_id::create("scoreboard0", this);

    // Create Virtual Sequencer
    virtual_sequencer = arb_virtual_sequencer::type_id::create("virtual_sequencer", this);
    uvm_config_db #(arb_virtual_sequencer)::set(this, {"virtual_sequencer", "*"}, "virtual_sequencer", virtual_sequencer);
  endfunction

  //----------------------------------------------------------------------------
  //
  //----------------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    mst_agent_0.monitor.tdata_port.connect(scoreboard0.collected_port_mst0);
    mst_agent_1.monitor.tdata_port.connect(scoreboard0.collected_port_mst1);
    mst_agent_2.monitor.tdata_port.connect(scoreboard0.collected_port_mst2);
    slv_agent_0.monitor.tdata_port.connect(scoreboard0.collected_port_slv0);

    virtual_sequencer.clk_rst_sequencer0 = clk_rst_agent0.sequencer;
    virtual_sequencer.mst0_sequencer     = mst_agent_0.sequencer;
    virtual_sequencer.mst1_sequencer     = mst_agent_1.sequencer;
    virtual_sequencer.mst2_sequencer     = mst_agent_2.sequencer;
    virtual_sequencer.slv0_sequencer     = slv_agent_0.sequencer;
  endfunction

endclass
