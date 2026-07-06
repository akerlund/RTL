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

class arb_base_test extends uvm_test;

  `uvm_component_utils(arb_base_test)

  // ---------------------------------------------------------------------------
  // UVM variables
  // ---------------------------------------------------------------------------

  uvm_table_printer uvm_table_printer0;
  report_server     report_server0;

  // ---------------------------------------------------------------------------
  // Testbench variables
  // ---------------------------------------------------------------------------

  arb_env               tb_env;
  arb_virtual_sequencer v_sqr;

  // ---------------------------------------------------------------------------
  // VIP Agent configurations
  // ---------------------------------------------------------------------------

  clk_rst_config   clk_rst_config0;
  vip_axi4s_config axi4s_mst_cfg0;
  vip_axi4s_config axi4s_slv_cfg0;

  // ---------------------------------------------------------------------------
  // Sequences
  // ---------------------------------------------------------------------------

  reset_sequence                    reset_seq0;
  vip_axi4s_seq_t vip_axi4s_seq0;
  vip_axi4s_seq_t vip_axi4s_seq1;
  vip_axi4s_seq_t vip_axi4s_seq2;


  function new(string name = "arb_base_test", uvm_component parent = null);
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
    tb_env = arb_env::type_id::create("tb_env", this);

    // Configurations
    clk_rst_config0 = clk_rst_config::type_id::create("clk_rst_config0",  this);
    axi4s_mst_cfg0  = vip_axi4s_config::type_id::create("axi4s_mst_cfg0", this);
    axi4s_slv_cfg0  = vip_axi4s_config::type_id::create("axi4s_slv_cfg0", this);

    axi4s_mst_cfg0.min_tvalid_delay_period = 2;
    axi4s_mst_cfg0.max_tvalid_delay_period = 10;
    axi4s_slv_cfg0.min_tready_delay_period = 2;
    axi4s_slv_cfg0.max_tready_delay_period = 10;
    axi4s_slv_cfg0.vip_axi4s_agent_type    = VIP_AXI4S_SLAVE_AGENT_E;

    uvm_config_db #(clk_rst_config)::set(this,   {"tb_env.clk_rst_agent0", "*"}, "cfg", clk_rst_config0);
    uvm_config_db #(vip_axi4s_config)::set(this, {"tb_env.mst_agent0",     "*"}, "cfg", axi4s_mst_cfg0);
    uvm_config_db #(vip_axi4s_config)::set(this, {"tb_env.mst_agent1",     "*"}, "cfg", axi4s_mst_cfg0);
    uvm_config_db #(vip_axi4s_config)::set(this, {"tb_env.mst_agent2",     "*"}, "cfg", axi4s_mst_cfg0);
    uvm_config_db #(vip_axi4s_config)::set(this, {"tb_env.slv_agent0",     "*"}, "cfg", axi4s_slv_cfg0);
  endfunction


  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    v_sqr = tb_env.virtual_sequencer;

    `uvm_info(get_type_name(), $sformatf("Topology of the test:\n%s", this.sprint(uvm_table_printer0)), UVM_LOW)
    `uvm_info(get_name(), {"VIP AXI4S Agent (Master):\n", axi4s_mst_cfg0.sprint()}, UVM_LOW)
    `uvm_info(get_name(), {"VIP AXI4S Agent (Slave):\n",  axi4s_slv_cfg0.sprint()}, UVM_LOW)
  endfunction


  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    reset_seq0     = reset_sequence::type_id::create("reset_seq0");
    vip_axi4s_seq0 = vip_axi4s_seq_t::type_id::create("vip_axi4s_seq0");
    vip_axi4s_seq1 = vip_axi4s_seq_t::type_id::create("vip_axi4s_seq1");
    vip_axi4s_seq2 = vip_axi4s_seq_t::type_id::create("vip_axi4s_seq2");
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

endclass
