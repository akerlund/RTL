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

class tc_ara_basic_read extends ara_base_test;

  ara_read_vseq #(vip_axi4_cfg) ara_read;

  `uvm_component_utils(tc_ara_basic_read)



  function new(string name = "tc_ara_basic_read", uvm_component parent = null);

    super.new(name, parent);

    // Memory Agent configuration
    memory_depth      = 16;
    max_read_requests = 16;
    max_ooo_bursts    = 0;

  endfunction



  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

  endfunction



  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);

    ara_read = new();
    ara_read.max_araddr              = 2**memory_depth-1;
    ara_read.max_arid                = NR_OF_MASTERS_C-1;
    ara_read.nr_of_bursts            = 5000;
    ara_read.max_idle_between_bursts = 512;
    ara_read.start(v_sqr);

    phase.drop_objection(this);

  endtask

endclass
