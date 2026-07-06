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

class ara_env extends uvm_env;

  `uvm_component_utils_begin(ara_env)
  `uvm_component_utils_end

  clk_rst_agent                    clk_rst_agent0;
  vip_axi4_agent #(VIP_AXI4_CFG_C, VIP_AXI4_ROLE_MANAGER_E) rd_agent0;
  vip_axi4_agent #(VIP_AXI4_CFG_C, VIP_AXI4_ROLE_SUBORDINATE_E) mem_agent0;

  ara_scoreboard        scoreboard0;
  ara_virtual_sequencer virtual_sequencer;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    // Create Agents
    clk_rst_agent0 = clk_rst_agent::type_id::create("clk_rst_agent0", this);
    rd_agent0      = vip_axi4_agent #(VIP_AXI4_CFG_C, VIP_AXI4_ROLE_MANAGER_E)::type_id::create("rd_agent0", this);
    mem_agent0     = vip_axi4_agent #(VIP_AXI4_CFG_C, VIP_AXI4_ROLE_SUBORDINATE_E)::type_id::create("mem_agent0", this);

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
