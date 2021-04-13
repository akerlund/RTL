////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
// https://github.com/akerlund/RTL
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
