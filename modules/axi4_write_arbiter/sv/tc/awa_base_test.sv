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

class awa_base_test extends uvm_test;

  `uvm_component_utils(awa_base_test)

  // ---------------------------------------------------------------------------
  // UVM variables
  // ---------------------------------------------------------------------------

  uvm_table_printer uvm_table_printer0;
  report_server     report_server0;

  // ---------------------------------------------------------------------------
  // Testbench variables
  // ---------------------------------------------------------------------------

  awa_env               tb_env;
  awa_virtual_sequencer v_sqr;

  // ---------------------------------------------------------------------------
  // VIP Agent configurations
  // ---------------------------------------------------------------------------

  clk_rst_config  clk_rst_config0;
  vip_axi4_cfg_agent axi4_mem_cfg0;
  vip_axi4_cfg_agent axi4_wr_cfg0;
  vip_axi4_cfg_agent axi4_wr_cfg1;
  vip_axi4_cfg_agent axi4_wr_cfg2;
  vip_axi4_cfg_agent axi4_wr_cfg3;

  // ---------------------------------------------------------------------------
  // Sequences
  // ---------------------------------------------------------------------------

  reset_sequence                       reset_seq0;
  vip_axi4_write_seq #(VIP_AXI4_CFG_C) vip_axi4_write_seq0;
  vip_axi4_write_seq #(VIP_AXI4_CFG_C) vip_axi4_write_seq1;
  vip_axi4_write_seq #(VIP_AXI4_CFG_C) vip_axi4_write_seq2;
  vip_axi4_write_seq #(VIP_AXI4_CFG_C) vip_axi4_write_seq3;

  function new(string name = "awa_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    // UVM
    uvm_config_db #(uvm_verbosity)::set(this, "*", "recording_detail", UVM_FULL);

    report_server0 = new("report_server0");
    uvm_report_server::set_server(report_server0);

    uvm_table_printer0                     = new();
    uvm_table_printer0.knobs.depth         = 3;
    uvm_table_printer0.knobs.default_radix = UVM_DEC;

    // Environment
    tb_env = awa_env::type_id::create("tb_env", this);

    // Configurations
    clk_rst_config0 = clk_rst_config::type_id::create("clk_rst_config0", this);
    axi4_mem_cfg0   = vip_axi4_cfg_agent::type_id::create("axi4_mem_cfg0",  this);
    axi4_wr_cfg0    = vip_axi4_cfg_agent::type_id::create("axi4_wr_cfg0",   this);
    axi4_wr_cfg1    = vip_axi4_cfg_agent::type_id::create("axi4_wr_cfg1",   this);
    axi4_wr_cfg2    = vip_axi4_cfg_agent::type_id::create("axi4_wr_cfg2",   this);
    axi4_wr_cfg3    = vip_axi4_cfg_agent::type_id::create("axi4_wr_cfg3",   this);
    axi4_mem_cfg0.wready_delay_period_min = 10;
    axi4_mem_cfg0.wready_delay_period_max = 10;

    axi4_wr_cfg0.wvalid_delay_period_min = 10;
    axi4_wr_cfg0.wvalid_delay_period_max = 10;
    axi4_wr_cfg1.wvalid_delay_period_min = 10;
    axi4_wr_cfg1.wvalid_delay_period_max = 10;
    axi4_wr_cfg2.wvalid_delay_period_min = 10;
    axi4_wr_cfg2.wvalid_delay_period_max = 10;
    axi4_wr_cfg3.wvalid_delay_period_min = 10;
    axi4_wr_cfg3.wvalid_delay_period_max = 10;

    uvm_config_db #(clk_rst_config)::set(this,  {"tb_env.clk_rst_agent0", "*"}, "cfg", clk_rst_config0);
    uvm_config_db #(vip_axi4_cfg_agent)::set(this, {"tb_env.mem_agent0",     "*"}, "cfg", axi4_mem_cfg0);
    uvm_config_db #(vip_axi4_cfg_agent)::set(this, {"tb_env.wr_agent0",      "*"}, "cfg", axi4_wr_cfg0);
    uvm_config_db #(vip_axi4_cfg_agent)::set(this, {"tb_env.wr_agent1",      "*"}, "cfg", axi4_wr_cfg1);
    uvm_config_db #(vip_axi4_cfg_agent)::set(this, {"tb_env.wr_agent2",      "*"}, "cfg", axi4_wr_cfg2);
    uvm_config_db #(vip_axi4_cfg_agent)::set(this, {"tb_env.wr_agent3",      "*"}, "cfg", axi4_wr_cfg3);

  endfunction


  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    v_sqr = tb_env.virtual_sequencer;
    `uvm_info(get_name(), {"VIP AXI4 Agent (Write0):\n",  axi4_wr_cfg0.sprint()}, UVM_LOW)
    `uvm_info(get_name(), {"VIP AXI4 Agent (Memory):\n", axi4_mem_cfg0.sprint()}, UVM_LOW)
  endfunction


  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    reset_seq0          = reset_sequence::type_id::create("reset_seq0");
    vip_axi4_write_seq0 = vip_axi4_write_seq #(VIP_AXI4_CFG_C)::type_id::create("vip_axi4_write_seq0");
    vip_axi4_write_seq1 = vip_axi4_write_seq #(VIP_AXI4_CFG_C)::type_id::create("vip_axi4_write_seq1");
    vip_axi4_write_seq2 = vip_axi4_write_seq #(VIP_AXI4_CFG_C)::type_id::create("vip_axi4_write_seq2");
    vip_axi4_write_seq3 = vip_axi4_write_seq #(VIP_AXI4_CFG_C)::type_id::create("vip_axi4_write_seq3");
  endfunction


  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    clk_delay(8);
    reset_seq0.start(v_sqr.clk_rst_sequencer0);
    phase.drop_objection(this);
  endtask


  task clk_delay(int delay);
    #(delay*clk_rst_config0.clock_period);
  endtask


  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    report_server0.test_report();
  endfunction

endclass
