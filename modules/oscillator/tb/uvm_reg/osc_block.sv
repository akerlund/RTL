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
