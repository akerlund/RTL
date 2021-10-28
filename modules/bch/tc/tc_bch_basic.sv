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

class tc_bch_basic extends bch_base_test;

  `uvm_component_utils(tc_bch_basic)

  function new(string name = "tc_bch_basic", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction


  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);
    clk_delay(512);
    phase.drop_objection(this);

    /*
    vip_axi4s_seq0.set_data_type(VIP_AXI4S_TDATA_COUNTER_E);
    vip_axi4s_seq0.set_cfg_burst_length(128, 1);
    vip_axi4s_seq0.set_nr_of_bursts(2**16);
    vip_axi4s_seq0.set_tstrb(VIP_AXI4S_TSTRB_ALL_E);
    vip_axi4s_seq0.set_log_denominator(64);
    vip_axi4s_seq0.start(v_sqr.mst_sequencer);

*/
  endtask

endclass
