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
// Sets the delay time and command bit for calculating it
// -----------------------------------------------------------------------------
class fir_delay_time_reg extends uvm_reg;

  `uvm_object_utils(fir_delay_time_reg)

  rand uvm_reg_field cmd_fir_calculate_delay;
  rand uvm_reg_field cr_fir_delay_time;


  function new (string name = "fir_delay_time_reg");
    super.new(name, 1+32, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // Calculate the time
    // -----------------------------------------------------------------------------
    cmd_fir_calculate_delay = uvm_reg_field::type_id::create("cmd_fir_calculate_delay");
    cmd_fir_calculate_delay.configure(
      .parent(this),
      .size(1),
      .lsb_pos(0),
      .access("WO"),
      .volatile(0),
      .reset(0),
      .has_reset(0),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("cmd_fir_calculate_delay", 0, 1);

    // -----------------------------------------------------------------------------
    // Sets the time
    // -----------------------------------------------------------------------------
    cr_fir_delay_time = uvm_reg_field::type_id::create("cr_fir_delay_time");
    cr_fir_delay_time.configure(
      .parent(this),
      .size(32),
      .lsb_pos(8),
      .access("WO"),
      .volatile(0),
      .reset(0),
      .has_reset(1),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("cr_fir_delay_time", 0, 32);

  endfunction

endclass

// -----------------------------------------------------------------------------
// Sampling frequency
// -----------------------------------------------------------------------------
class fir_delay_gain_reg extends uvm_reg;

  `uvm_object_utils(fir_delay_gain_reg)

  rand uvm_reg_field cr_fir_delay_gain;


  function new (string name = "fir_delay_gain_reg");
    super.new(name, 32, UVM_NO_COVERAGE);
  endfunction


  function void build();


    // -----------------------------------------------------------------------------
    // The delay gain
    // -----------------------------------------------------------------------------
    cr_fir_delay_gain = uvm_reg_field::type_id::create("cr_fir_delay_gain");
    cr_fir_delay_gain.configure(
      .parent(this),
      .size(32),
      .lsb_pos(0),
      .access("WO"),
      .volatile(0),
      .reset(0),
      .has_reset(1),
      .is_rand(0),
      .individually_accessible(0)
    );
    add_hdl_path_slice("cr_fir_delay_gain", 0, 32);

  endfunction

endclass

