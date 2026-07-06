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
class osc_block extends uvm_reg_block;

  `uvm_object_utils(osc_block)

  rand osc_waveform_select_reg osc_waveform_select;
  rand osc_frequency_reg osc_frequency;
  rand osc_duty_cycle_reg osc_duty_cycle;


  function new (string name = "osc_block");
    super.new(name, build_coverage(UVM_NO_COVERAGE));
  endfunction


  function void build();

    osc_waveform_select = osc_waveform_select_reg::type_id::create("osc_waveform_select");
    osc_waveform_select.build();
    osc_waveform_select.configure(this);

    osc_frequency = osc_frequency_reg::type_id::create("osc_frequency");
    osc_frequency.build();
    osc_frequency.configure(this);

    osc_duty_cycle = osc_duty_cycle_reg::type_id::create("osc_duty_cycle");
    osc_duty_cycle.build();
    osc_duty_cycle.configure(this);



    default_map = create_map("osc_map", 0, 8, UVM_LITTLE_ENDIAN);

    default_map.add_reg(osc_waveform_select, 0, "RW");
    default_map.add_reg(osc_frequency, 8, "RW");
    default_map.add_reg(osc_duty_cycle, 16, "RW");


    lock_model();

  endfunction

endclass
