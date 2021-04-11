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

class tc_positive_radian_spin extends cor_base_test;

  protected logic [TDATA_WIDTH_C-1 : 0] _custom_data  [$];

  `uvm_component_utils(tc_positive_radian_spin)


  function new(string name = "tc_positive_radian_spin", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction


  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);

    for (int i = 0; i < 360; i++) begin
      _custom_data.push_back(pos_radians[i]);
    end
    vip_axi4s_seq0.set_data_type(VIP_AXI4S_TDATA_CUSTOM_E);
    vip_axi4s_seq0.set_custom_data(_custom_data);
    vip_axi4s_seq0.start(v_sqr.mst_sequencer);

    phase.drop_objection(this);
  endtask
endclass
