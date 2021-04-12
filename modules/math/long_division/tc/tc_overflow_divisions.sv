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

class tc_overflow_divisions extends div_base_test;

  `uvm_component_utils(tc_overflow_divisions)

  function new(string name = "tc_overflow_divisions", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    nr_of_divisions = 100;
  endfunction


  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);

    for (int i = 0; i < nr_of_divisions; i++) begin
      dividend = $urandom();
      divisor  = 1; // Small divisior guarantees overflow
      custom_data.push_back(dividend);
      custom_data.push_back(divisor);
      vip_axi4s_seq0.set_custom_data(custom_data);
      vip_axi4s_seq0.start(v_sqr.mst_sequencer);
      custom_data.delete();
    end

    phase.drop_objection(this);
  endtask

endclass
