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

class tc_positive_signals extends mix_base_test;

  mix_positive_signals_seq #(VIP_AXI4S_CFG_C) mix_positive_signals_seq0;

  `uvm_component_utils(tc_positive_signals)

  int nr_of_signals = 10;


  function new(string name = "tc_positive_signals", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction



  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);

    mix_positive_signals_seq0 = new();
    mix_positive_signals_seq0.nr_of_signals = nr_of_signals;
    mix_positive_signals_seq0.start(v_sqr.mst0_sequencer);

    phase.drop_objection(this);

  endtask

endclass
