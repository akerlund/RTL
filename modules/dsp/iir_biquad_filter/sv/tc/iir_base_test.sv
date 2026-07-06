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

class iir_base_test extends uvm_test;

  `uvm_component_utils(iir_base_test)

  // ---------------------------------------------------------------------------
  // UVM variables
  // ---------------------------------------------------------------------------

  uvm_table_printer uvm_table_printer0;
  report_server     report_server0;

  // ---------------------------------------------------------------------------
  // Testbench variables
  // ---------------------------------------------------------------------------

  iir_env               tb_env;
  iir_virtual_sequencer v_sqr;
  register_model        reg_model;
  uvm_status_e          uvm_status;
  uvm_reg_data_t        value;

  // ---------------------------------------------------------------------------
  // VIP Agent configurations
  // ---------------------------------------------------------------------------

  clk_rst_config   clk_rst_config0;
  vip_axi4s_config axi4s_mst_cfg0;
  vip_axi4_cfg_agent  axi4_reg_cfg;

  // ---------------------------------------------------------------------------
  // Sequences
  // ---------------------------------------------------------------------------

  reset_sequence                    reset_seq0;
  vip_axi4s_seq_t vip_axi4s_seq0;

  // ---------------------------------------------------------------------------
  // Testcase variables
  // ---------------------------------------------------------------------------

  int               iir_f0;
  int               iir_fs;
  int               iir_q;
  iir_biquad_type_t iir_type;
  int               iir_bypass;
  int               sleep_counter;


  function new(string name = "iir_base_test", uvm_component parent = null);
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
    tb_env = iir_env::type_id::create("tb_env", this);

    // Configurations
    clk_rst_config0 = clk_rst_config::type_id::create("clk_rst_config0",  this);
    axi4s_mst_cfg0  = vip_axi4s_config::type_id::create("axi4s_mst_cfg0", this);
    axi4_reg_cfg    = vip_axi4_cfg_agent::type_id::create("axi4_reg_cfg",    this);

    axi4s_mst_cfg0.tvalid_delay_enabled = FALSE;
    axi4_reg_cfg.wvalid_delay_enabled   = FALSE;
    axi4_reg_cfg.rready_delay_enabled   = FALSE;

    uvm_config_db #(clk_rst_config)::set(this,   {"tb_env.clk_rst_agent0", "*"}, "cfg", clk_rst_config0);
    uvm_config_db #(vip_axi4s_config)::set(this, {"tb_env.mst_agent0",     "*"}, "cfg", axi4s_mst_cfg0);
    uvm_config_db #(vip_axi4_cfg_agent)::set(this,  {"tb_env.reg_agent0",     "*"}, "cfg", axi4_reg_cfg);

  endfunction


  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);

    if (!uvm_config_db #(register_model)::get(null, "*", "reg_model", reg_model)) begin
      `uvm_fatal("NOREG", "No registered register model in the factory")
    end
    v_sqr = tb_env.virtual_sequencer;
    `uvm_info(get_type_name(), $sformatf("Topology of the test:\n%s", this.sprint(uvm_table_printer0)), UVM_LOW)
    `uvm_info(get_name(), {"VIP AXI4S Agent (Master):\n", axi4s_mst_cfg0.sprint()}, UVM_LOW)
  endfunction


  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    reset_seq0     = reset_sequence::type_id::create("reset_seq0");
    vip_axi4s_seq0 = vip_axi4s_seq_t::type_id::create("vip_axi4s_seq0");
  endfunction


  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);

    reset_seq0.start(v_sqr.clk_rst_sequencer0);

    vip_axi4s_seq0.set_verbose(FALSE);
    vip_axi4s_seq0.set_tdata_type(VIP_AXI4S_TDATA_COUNTER_E);
    vip_axi4s_seq0.set_cfg_burst_length(128, 1);
    vip_axi4s_seq0.set_nr_of_bursts(2**16);
    vip_axi4s_seq0.set_tstrb_type(VIP_AXI4S_TSTRB_ALL_E);
    vip_axi4s_seq0.set_log_denominator(64);

    fork
      vip_axi4s_seq0.start(v_sqr.mst_sequencer);
    join_none

    fork
      forever begin
        #100us;
        sleep_counter++;
        `uvm_info(get_name(), $sformatf("%0dus", sleep_counter*100), UVM_LOW)
      end
    join_none

    phase.drop_objection(this);
  endtask


  task clk_delay(int delay);
    #(delay*clk_rst_config0.clock_period);
  endtask
endclass
