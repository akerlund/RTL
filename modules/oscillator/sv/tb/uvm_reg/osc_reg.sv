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
// -----------------------------------------------------------------------------
// Sets the waveform output
// -----------------------------------------------------------------------------
class osc_waveform_select_reg extends uvm_reg;

  `uvm_object_utils(osc_waveform_select_reg)

  rand uvm_reg_field cr_osc_waveform_select;


  function new (string name = "osc_waveform_select_reg");
    super.new(name, 2, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // Sets the waveform output
    // -----------------------------------------------------------------------------
    cr_osc_waveform_select = uvm_reg_field::type_id::create("cr_osc_waveform_select");
    cr_osc_waveform_select.configure(
      .parent(this),
      .size(2),
      .lsb_pos(0),
      .access("RW"),
      .volatile(0),
      .reset(0),
      .has_reset(1),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("cr_osc_waveform_select", 0, 2);

  endfunction

endclass

// -----------------------------------------------------------------------------
// Sets the frequency
// -----------------------------------------------------------------------------
class osc_frequency_reg extends uvm_reg;

  `uvm_object_utils(osc_frequency_reg)

  rand uvm_reg_field cr_osc_frequency;


  function new (string name = "osc_frequency_reg");
    super.new(name, N_BITS_C, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // Sets the frequency
    // -----------------------------------------------------------------------------
    cr_osc_frequency = uvm_reg_field::type_id::create("cr_osc_frequency");
    cr_osc_frequency.configure(
      .parent(this),
      .size(N_BITS_C),
      .lsb_pos(0),
      .access("RW"),
      .volatile(0),
      .reset(500<<Q_BITS_C),
      .has_reset(1),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("cr_osc_frequency", 0, N_BITS_C);

  endfunction

endclass

// -----------------------------------------------------------------------------
// Sets the duty cycle of the square wave
// -----------------------------------------------------------------------------
class osc_duty_cycle_reg extends uvm_reg;

  `uvm_object_utils(osc_duty_cycle_reg)

  rand uvm_reg_field cr_osc_duty_cycle;


  function new (string name = "osc_duty_cycle_reg");
    super.new(name, N_BITS_C, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // Sets the duty cycle of the square wave
    // -----------------------------------------------------------------------------
    cr_osc_duty_cycle = uvm_reg_field::type_id::create("cr_osc_duty_cycle");
    cr_osc_duty_cycle.configure(
      .parent(this),
      .size(N_BITS_C),
      .lsb_pos(0),
      .access("RW"),
      .volatile(0),
      .reset(500),
      .has_reset(1),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("cr_osc_duty_cycle", 0, N_BITS_C);

  endfunction

endclass

