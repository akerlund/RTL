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

class tc_iir_reconfiguration extends iir_base_test;

  iir_configuration_seq     #(vip_apb3_cfg) iir_configuration_seq0;
  iir_read_coefficients_seq #(vip_apb3_cfg) iir_read_coefficients_seq0;
  iir_cr_iir_f0_seq         #(vip_apb3_cfg) iir_cr_iir_f0_seq0;

  `uvm_component_utils(tc_iir_reconfiguration)



  function new(string name = "tc_iir_reconfiguration", uvm_component parent = null);

    super.new(name, parent);

    // IIR parameters
    iir_f0     = 3000;
    iir_fs     = 64000;
    iir_q      = 1;
    iir_type   = IIR_LOW_PASS_E;
    iir_bypass = '0;

    // Oscillator parameters
    osc_f             = 1000; // Hz
    osc_duty_cycle    = 500;  // Percentage/1000
    osc_waveform_type = OSC_TRIANGLE_E;

  endfunction



  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

  endfunction



  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);

    iir_configuration_seq0     = new();
    iir_read_coefficients_seq0 = new();
    iir_cr_iir_f0_seq0         = new();

    // IIR parameters
    iir_configuration_seq0.iir_f0     = iir_f0;
    iir_configuration_seq0.iir_fs     = iir_fs;
    iir_configuration_seq0.iir_q      = iir_q;
    iir_configuration_seq0.iir_type   = iir_type;
    iir_configuration_seq0.iir_bypass = iir_bypass;

    // Oscillator parameters
    iir_configuration_seq0.osc_f             = osc_f;
    iir_configuration_seq0.osc_duty_cycle    = osc_duty_cycle;
    iir_configuration_seq0.osc_waveform_type = osc_waveform_type;

    iir_configuration_seq0.start(v_sqr.apb3_sequencer);

    #1us;

    iir_read_coefficients_seq0.start(v_sqr.apb3_sequencer);

    #3ms;

    for (int i = 0; i < 14; i++) begin

      iir_f0 = iir_f0 - 200;
      iir_cr_iir_f0_seq0.iir_f0 = iir_f0;
      iir_cr_iir_f0_seq0.start(v_sqr.apb3_sequencer);
      #1us;
      iir_read_coefficients_seq0.start(v_sqr.apb3_sequencer);
      #3ms;

    end

    #10ms;

    phase.drop_objection(this);

  endtask

endclass
