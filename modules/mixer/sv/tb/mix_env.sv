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
