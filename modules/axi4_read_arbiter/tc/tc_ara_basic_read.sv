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

class tc_ara_basic_read extends ara_base_test;

  `uvm_component_utils(tc_ara_basic_read)

  function new(string name = "tc_ara_basic_read", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction


  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);

    vip_axi4_read_seq0.set_id_type(VIP_AXI4_ID_COUNTER_E);
    vip_axi4_read_seq0.set_cfg_addr(2**VIP_AXI4_CFG_C.VIP_AXI4_ADDR_WIDTH_P-1, 0);
    vip_axi4_read_seq0.set_log_denominator(128);
    vip_axi4_read_seq0.set_cfg_id(0, 0);
    vip_axi4_read_seq0.set_nr_of_requests(4096);
    vip_axi4_read_seq0.set_len(15);

    vip_axi4_read_seq0.start(v_sqr.rd_sequencer0);

    phase.drop_objection(this);

  endtask

endclass
