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

class tc_osc_frequency_test extends osc_base_test;

  osc_frequency_seq #(vip_apb3_cfg) osc_frequency_seq0;

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

    osc_f             = 5000.0;
    osc_duty_cycle    = 250;
    osc_waveform_type = OSC_SQUARE_E;

    osc_frequency_seq0 = new();
    osc_frequency_seq0.osc_f             = osc_f;
    osc_frequency_seq0.osc_duty_cycle    = osc_duty_cycle;
    osc_frequency_seq0.osc_waveform_type = osc_waveform_type;

    osc_frequency_seq0.start(v_sqr.apb3_sequencer);

    #400us;

    osc_f = 4000.0;
    osc_duty_cycle                    = 200;
    osc_frequency_seq0.osc_f          = osc_f;
    osc_frequency_seq0.osc_duty_cycle = osc_duty_cycle;
    osc_frequency_seq0.start(v_sqr.apb3_sequencer);

    #500us;

    osc_f = 3000.0;
    osc_duty_cycle                    = 100;
    osc_frequency_seq0.osc_f          = osc_f;
    osc_frequency_seq0.osc_duty_cycle = osc_duty_cycle;
    osc_frequency_seq0.start(v_sqr.apb3_sequencer);

    #500us;

    osc_f = 2000.0;
    osc_duty_cycle                    = 750;
    osc_frequency_seq0.osc_f          = osc_f;
    osc_frequency_seq0.osc_duty_cycle = osc_duty_cycle;
    osc_frequency_seq0.start(v_sqr.apb3_sequencer);

    #500us;

    osc_f = 1000.0;
    osc_duty_cycle                    = 800;
    osc_frequency_seq0.osc_f          = osc_f;
    osc_frequency_seq0.osc_duty_cycle = osc_duty_cycle;
    osc_frequency_seq0.start(v_sqr.apb3_sequencer);

    #500us;


    #10ms;


    phase.drop_objection(this);

  endtask

endclass
