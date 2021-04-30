////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
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
  //register_model        reg_model;
  uvm_status_e          uvm_status;
  uvm_reg_data_t        value;

  // ---------------------------------------------------------------------------
  // VIP Agent configurations
  // ---------------------------------------------------------------------------

  clk_rst_config clk_rst_config0;

  // ---------------------------------------------------------------------------
  // Sequences
  // ---------------------------------------------------------------------------

  reset_sequence     reset_seq0;

  // ---------------------------------------------------------------------------
  // Testcase variables
  // ---------------------------------------------------------------------------

  // IIR
  int               iir_f0;
  int               iir_fs;
  int               iir_q;
  iir_biquad_type_t iir_type;
  int               iir_bypass;

  // Oscillator
  int                 osc_f;
  int                 osc_duty_cycle;
  osc_waveform_type_t osc_waveform_type;


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
    clk_rst_config0 = clk_rst_config::type_id::create("clk_rst_config0", this);
    uvm_config_db #(clk_rst_config)::set(this,  {"tb_env.clk_rst_agent0", "*"}, "cfg", clk_rst_config0);

  endfunction


  function void end_of_elaboration_phase(uvm_phase phase);

    //if (!uvm_config_db #(register_model)::get(null, "*", "reg_model", reg_model)) begin
    //  `uvm_fatal("NOREG", "No registered register model in the factory")
    //end

    `uvm_info(get_type_name(), $sformatf("Topology of the test:\n%s", this.sprint(uvm_table_printer0)), UVM_LOW)

    v_sqr = tb_env.virtual_sequencer;
  endfunction


  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    reset_seq0 = reset_sequence::type_id::create("reset_seq0");
  endfunction


  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    reset_seq0.start(v_sqr.clk_rst_sequencer0);
    phase.drop_objection(this);
  endtask


  task clk_delay(int delay);
    #(delay*clk_rst_config0.clock_period);
  endtask

endclass
