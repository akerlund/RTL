////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
// https://github.com/akerlund/PYRG
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

