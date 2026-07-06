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

class vec_env extends uvm_env;

  `uvm_component_utils_begin(vec_env)
  `uvm_component_utils_end

  clk_rst_agent                      clk_rst_agent0;
  clk_rst_agent                      clk_rst_agent1;
  vip_axi4s_agent #(VIP_AXI4S_CFG_C) vip_axi4s_agent_mst0;
  vip_axi4s_agent #(VIP_AXI4S_CFG_C) vip_axi4s_agent_slv0;

  vec_scoreboard        scoreboard0;
  vec_virtual_sequencer virtual_sequencer;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    clk_rst_agent0       = clk_rst_agent::type_id::create("clk_rst_agent0", this);
    clk_rst_agent1       = clk_rst_agent::type_id::create("clk_rst_agent1", this);
    vip_axi4s_agent_mst0 = vip_axi4s_agent #(VIP_AXI4S_CFG_C)::type_id::create("vip_axi4s_agent_mst0", this);
    vip_axi4s_agent_slv0 = vip_axi4s_agent #(VIP_AXI4S_CFG_C)::type_id::create("vip_axi4s_agent_slv0", this);

    uvm_config_db #(int)::set(this, {"clk_rst_agent0",       "*"}, "id", 0);
    uvm_config_db #(int)::set(this, {"clk_rst_agent1",       "*"}, "id", 1);
    uvm_config_db #(int)::set(this, {"vip_axi4s_agent_mst0", "*"}, "id", 2);
    uvm_config_db #(int)::set(this, {"vip_axi4s_agent_slv0", "*"}, "id", 3);

    scoreboard0       = vec_scoreboard::type_id::create("scoreboard0", this);
    virtual_sequencer = vec_virtual_sequencer::type_id::create("virtual_sequencer", this);
    uvm_config_db #(vec_virtual_sequencer)::set(this, {"virtual_sequencer", "*"}, "virtual_sequencer", virtual_sequencer);
  endfunction


  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    vip_axi4s_agent_mst0.monitor.tdata_port.connect(scoreboard0.collected_port_mst0);
    vip_axi4s_agent_slv0.monitor.tdata_port.connect(scoreboard0.collected_port_slv0);
    virtual_sequencer.mst0_sequencer     = vip_axi4s_agent_mst0.sequencer;
    virtual_sequencer.slv0_sequencer     = vip_axi4s_agent_slv0.sequencer;
    virtual_sequencer.clk_rst_sequencer0 = clk_rst_agent0.sequencer;
    virtual_sequencer.clk_rst_sequencer1 = clk_rst_agent1.sequencer;
  endfunction

endclass
