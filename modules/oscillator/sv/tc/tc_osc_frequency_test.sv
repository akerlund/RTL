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

class tc_osc_frequency_test extends osc_base_test;

  `uvm_component_utils(tc_osc_frequency_test)

  function new(string name = "tc_osc_frequency_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction


  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);

    `uvm_info(get_name(), $sformatf("f = %0d, duty = %0d", 500, 250), UVM_NONE)
    reg_model.osc.osc_frequency.write(uvm_status, 500<<Q_BITS_C);
    reg_model.osc.osc_duty_cycle.write(uvm_status, 250);
    clk_delay(500000);

    `uvm_info(get_name(), $sformatf("f = %0d, duty = %0d", 4000, 200), UVM_NONE)
    reg_model.osc.osc_frequency.write(uvm_status, 4000<<Q_BITS_C);
    reg_model.osc.osc_duty_cycle.write(uvm_status, 200);
    clk_delay(500000);

    `uvm_info(get_name(), $sformatf("f = %0d, duty = %0d", 3000, 100), UVM_NONE)
    reg_model.osc.osc_frequency.write(uvm_status, 3000<<Q_BITS_C);
    reg_model.osc.osc_duty_cycle.write(uvm_status, 100);
    clk_delay(500000);

    `uvm_info(get_name(), $sformatf("f = %0d, duty = %0d", 2000, 750), UVM_NONE)
    reg_model.osc.osc_frequency.write(uvm_status, 2000<<Q_BITS_C);
    reg_model.osc.osc_duty_cycle.write(uvm_status, 750);
    clk_delay(500000);

    `uvm_info(get_name(), $sformatf("f = %0d, duty = %0d", 1000, 800), UVM_NONE)
    reg_model.osc.osc_frequency.write(uvm_status, 1000<<Q_BITS_C);
    reg_model.osc.osc_duty_cycle.write(uvm_status, 800);
    clk_delay(500000);

    phase.drop_objection(this);

  endtask

endclass
