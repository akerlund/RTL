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

class mix_base_test extends uvm_test;

  `uvm_component_utils(mix_base_test)

  // ---------------------------------------------------------------------------
  // UVM variables
  // ---------------------------------------------------------------------------

  uvm_table_printer uvm_table_printer0;
  report_server     report_server0;

  // ---------------------------------------------------------------------------
  // Testbench variables
  // ---------------------------------------------------------------------------

  mix_env               tb_env;
  mix_virtual_sequencer v_sqr;
  protected virtual mix_if mix_vif;

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
  //vip_axi4s_seq_t vip_axi4s_seq0;


  function new(string name = "mix_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db #(virtual mix_if)::get(this, "", "mix_vif", mix_vif)) begin
      `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".mix_vif"});
    end

    // UVM
    uvm_config_db #(uvm_verbosity)::set(this, "*", "recording_detail", UVM_FULL);

    report_server0 = new("report_server0");
    uvm_report_server::set_server(report_server0);

    uvm_table_printer0                     = new();
    uvm_table_printer0.knobs.depth         = 3;
    uvm_table_printer0.knobs.default_radix = UVM_DEC;

    tb_env          = mix_env::type_id::create("tb_env", this);
    clk_rst_config0 = clk_rst_config::type_id::create("clk_rst_config0",  this);
    axi4s_mst_cfg0  = vip_axi4s_config::type_id::create("axi4s_mst_cfg0", this);
    axi4s_slv_cfg0  = vip_axi4s_config::type_id::create("axi4s_slv_cfg0", this);

    axi4s_slv_cfg0.vip_axi4s_agent_type = VIP_AXI4S_SLAVE_AGENT_E;

    uvm_config_db #(vip_axi4s_config)::set(this, {"tb_env.mst_agent0",     "*"}, "cfg", axi4s_mst_cfg0);
    uvm_config_db #(vip_axi4s_config)::set(this, {"tb_env.slv_agent0",     "*"}, "cfg", axi4s_slv_cfg0);
    uvm_config_db #(clk_rst_config)::set(this,   {"tb_env.clk_rst_agent0", "*"}, "cfg", clk_rst_config0);

  endfunction


  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    v_sqr = tb_env.virtual_sequencer;
  endfunction


  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    reset_seq0     = reset_sequence::type_id::create("reset_seq0");
    //vip_axi4s_seq0 = vip_axi4s_seq_t::type_id::create("vip_axi4s_seq0");
  endfunction


  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    mix_vif.fs_strobe <= '0;
    reset_seq0.start(v_sqr.clk_rst_sequencer0);
    fork
      set_fs_strobe();
    join_none
    phase.drop_objection(this);
  endtask


  task clk_delay(int delay);
    #(delay*clk_rst_config0.clock_period);
  endtask


  task set_fs_strobe();
    forever begin
      mix_vif.fs_strobe <= '0;
      clk_delay(9);
      mix_vif.fs_strobe <= '1;
      clk_delay(1);
    end
  endtask


  task set_channel_data(real val);
    for (int i = 0; i < NR_OF_CHANNELS_C; i++) begin
      mix_vif.channel_data[i] = float_to_fixed_point(val, Q_BITS_C);
    end
  endtask


  task set_channel_gain(real val);
    for (int i = 0; i < NR_OF_CHANNELS_C; i++) begin
      mix_vif.cr_channel_gain[i] = float_to_fixed_point(val, Q_BITS_C);
    end
  endtask


  task set_channel_pan(real val);
    for (int i = 0; i < NR_OF_CHANNELS_C; i++) begin
      mix_vif.cr_channel_pan[i] = float_to_fixed_point(val, Q_BITS_C);
    end
  endtask


  task set_output_gain(real val);
    mix_vif.cr_output_gain = float_to_fixed_point(val, Q_BITS_C);
  endtask

endclass
