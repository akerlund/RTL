////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2020 Fredrik Åkerlund
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Description:
//
////////////////////////////////////////////////////////////////////////////////

class tc_cor_360_angles extends cor_base_test;

  cor_360_angles_seq #(vip_axi4s_cfg) cor_360_angles_seq0;

  `uvm_component_utils(tc_cor_360_angles)



  function new(string name = "tc_cor_360_angles", uvm_component parent = null);

    super.new(name, parent);

  endfunction



  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

  endfunction



  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);

    cor_360_angles_seq0 = new();
    cor_360_angles_seq0.start(v_sqr.axi4s_sequencer);

    phase.drop_objection(this);

  endtask

endclass
