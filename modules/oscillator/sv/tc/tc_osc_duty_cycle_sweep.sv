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

class tc_osc_duty_cycle_sweep extends osc_base_test;

  //osc_frequency_seq #(vip_apb3_cfg) osc_frequency_seq0;

  `uvm_component_utils(tc_osc_duty_cycle_sweep)

  function new(string name = "tc_osc_duty_cycle_sweep", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction


  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);

    // osc_frequency_seq0 = new();

    // // Period of 50kHz is 0.00002s = 20us
    // osc_frequency_seq0.osc_f             = 50000.0;
    // osc_frequency_seq0.osc_waveform_type = OSC_SQUARE_E;

    // osc_duty_cycle = 1001;

    // for (int i = 0; i < 1003; i++) begin

    //   osc_frequency_seq0.osc_duty_cycle = osc_duty_cycle;
    //   osc_frequency_seq0.start(v_sqr.apb3_sequencer);
    //   #40us;
    //   osc_duty_cycle = osc_duty_cycle-1;

    // end

    // #60us;

    phase.drop_objection(this);

  endtask

endclass
