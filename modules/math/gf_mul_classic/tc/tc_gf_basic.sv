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

class tc_gf_basic extends gf_base_test;

  `uvm_component_utils(tc_gf_basic)

  function new(string name = "tc_gf_basic", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction


  task run_phase(uvm_phase phase);

    logic [M_C*2-1 : 0] custom_data [$];
    custom_data.push_back('0);

    `uvm_info(get_name(), "run_phase basic 0", UVM_LOW)
    super.run_phase(phase);
    `uvm_info(get_name(), "run_phase basic 1", UVM_LOW)
    phase.raise_objection(this);
    `uvm_info(get_name(), "run_phase basic 2", UVM_LOW)

    vip_axi4s_seq0.set_data_type(VIP_AXI4S_TDATA_CUSTOM_E);
    vip_axi4s_seq0.set_burst_length(1);
    vip_axi4s_seq0.set_tstrb(VIP_AXI4S_TSTRB_ALL_E);

    // Multiplication
    `uvm_info(get_name(), $sformatf("Multiplication"), UVM_LOW)
    for (int i = 0; i < REF_SIZE_C; i++) begin
      custom_data[0] = ({GF_MUL_C[i][0], GF_MUL_C[i][1]});
      vip_axi4s_seq0.set_custom_data(custom_data);
      vip_axi4s_seq0.start(v_sqr.mst_mul0_sequencer);
    end

    // Division
    `uvm_info(get_name(), $sformatf("Division"), UVM_LOW)
    for (int i = 0; i < REF_SIZE_C; i++) begin
      custom_data[0] = ({GF_DIV_C[i][0], GF_DIV_C[i][1]});
      vip_axi4s_seq0.set_custom_data(custom_data);
      vip_axi4s_seq0.start(v_sqr.mst_div0_sequencer);
      clk_delay(40);
    end

    phase.drop_objection(this);

  endtask

endclass
