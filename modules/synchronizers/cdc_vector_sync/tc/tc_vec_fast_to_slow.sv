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

class tc_vec_fast_to_slow extends vec_base_test;

  `uvm_component_utils(tc_vec_fast_to_slow)



  function new(string name = "tc_vec_fast_to_slow", uvm_component parent = null);
    super.new(name, parent);
  endfunction



  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    nr_of_bursts            = 2048;
    max_idle_between_bursts = 0;

    clk_rst_config0.clock_period = 10.0;
    clk_rst_config1.clock_period = 6.0;


  endfunction



  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);

    axi4s_counting_seq0.nr_of_bursts            = nr_of_bursts;
    axi4s_counting_seq0.max_idle_between_bursts = max_idle_between_bursts;
    axi4s_counting_seq0.start(v_sqr.mst0_sequencer);

    phase.drop_objection(this);

  endtask

endclass
