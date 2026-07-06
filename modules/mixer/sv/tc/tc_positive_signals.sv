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

class tc_positive_signals extends mix_base_test;

  `uvm_component_utils(tc_positive_signals)

  function new(string name = "tc_positive_signals", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction



  task run_phase(uvm_phase phase);

    set_channel_gain(0.00);
    set_channel_pan(0.00);
    set_output_gain(0.00);
    set_channel_data(0.00);

    super.run_phase(phase);
    phase.raise_objection(this);

    wait (mix_vif.fs_strobe === '1);
    `uvm_info(get_name(), "1/3", UVM_LOW)
    set_channel_gain(1.00);
    set_channel_pan(1.00);
    set_output_gain(1.00);
    set_channel_data(2.00);
    clk_delay(2);

    wait (mix_vif.fs_strobe === '1);
    `uvm_info(get_name(), "2/3", UVM_LOW)
    set_channel_gain(1.25);
    set_channel_pan(0.25);
    set_output_gain(0.80);
    clk_delay(2);


    wait (mix_vif.fs_strobe === '1);
    `uvm_info(get_name(), "3/3", UVM_LOW)
    set_channel_gain(0.8);
    set_channel_pan(0.75);
    set_output_gain(1.25);

    clk_delay(10);

    phase.drop_objection(this);

  endtask

endclass
