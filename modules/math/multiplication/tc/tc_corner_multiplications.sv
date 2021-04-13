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

class tc_corner_multiplications extends mul_base_test;

  `uvm_component_utils(tc_corner_multiplications)

  function new(string name = "tc_corner_multiplications", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
  endfunction


  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);

    `uvm_info(get_name(), $sformatf("Multiplicand is zero"), UVM_LOW)
    custom_data.push_back('1);
    custom_data.push_back('0);
    vip_axi4s_seq0.set_custom_data(custom_data);
    vip_axi4s_seq0.start(v_sqr.mst_sequencer);
    custom_data.delete();

    clk_delay(10);

    `uvm_info(get_name(), $sformatf("Multiplier is zero"), UVM_LOW)
    custom_data.push_back('1);
    custom_data.push_back(0);
    vip_axi4s_seq0.set_custom_data(custom_data);
    vip_axi4s_seq0.start(v_sqr.mst_sequencer);
    custom_data.delete();

    clk_delay(10);

    `uvm_info(get_name(), $sformatf("Largest possible values"), UVM_LOW)
    custom_data.push_back(2**(N_BITS_C-Q_BITS_C)-1);
    custom_data.push_back(2**(N_BITS_C-Q_BITS_C)-1);
    vip_axi4s_seq0.set_custom_data(custom_data);
    vip_axi4s_seq0.start(v_sqr.mst_sequencer);
    custom_data.delete();

    clk_delay(10);

    `uvm_info(get_name(), $sformatf("Lowest possible values"), UVM_LOW)
    custom_data.push_back(-2**(N_BITS_C-Q_BITS_C));
    custom_data.push_back(-2**(N_BITS_C-Q_BITS_C));
    vip_axi4s_seq0.set_custom_data(custom_data);
    vip_axi4s_seq0.start(v_sqr.mst_sequencer);
    custom_data.delete();

    clk_delay(10);

    `uvm_info(get_name(), $sformatf("Largest fractional parts"), UVM_LOW)
    custom_data.push_back({'0, {Q_BITS_C{1'b1}}});
    custom_data.push_back({'0, {Q_BITS_C{1'b1}}});
    vip_axi4s_seq0.set_custom_data(custom_data);
    vip_axi4s_seq0.start(v_sqr.mst_sequencer);
    custom_data.delete();

    clk_delay(10);

    `uvm_info(get_name(), $sformatf("Largest fractional part * largest possible value"), UVM_LOW)
    custom_data.push_back({'0, {Q_BITS_C{1'b1}}});
    custom_data.push_back(2**(N_BITS_C-Q_BITS_C)-1);
    vip_axi4s_seq0.set_custom_data(custom_data);
    vip_axi4s_seq0.start(v_sqr.mst_sequencer);
    custom_data.delete();

    clk_delay(10);

    `uvm_info(get_name(), $sformatf("Largest fractional part * lowest possible value"), UVM_LOW)
    custom_data.push_back({'0, {Q_BITS_C{1'b1}}});
    custom_data.push_back(-2**(N_BITS_C-Q_BITS_C));
    vip_axi4s_seq0.set_custom_data(custom_data);
    vip_axi4s_seq0.start(v_sqr.mst_sequencer);
    custom_data.delete();

    clk_delay(10);

    `uvm_info(get_name(), $sformatf("Largest fractional part * lowest fractional part"), UVM_LOW)
    custom_data.push_back({'0, {Q_BITS_C{1'b1}}});
    custom_data.push_back(-2**(N_BITS_C-Q_BITS_C));
    vip_axi4s_seq0.set_custom_data(custom_data);
    vip_axi4s_seq0.start(v_sqr.mst_sequencer);
    custom_data.delete();

    clk_delay(10);

    `uvm_info(get_name(), $sformatf("Lowest fractional parts"), UVM_LOW)
    custom_data.push_back({'0, 1'b1});
    custom_data.push_back({'0, 1'b1});
    vip_axi4s_seq0.set_custom_data(custom_data);
    vip_axi4s_seq0.start(v_sqr.mst_sequencer);
    custom_data.delete();

    clk_delay(10);

    `uvm_info(get_name(), $sformatf("Lowest fractional part * largest possible value"), UVM_LOW)
    custom_data.push_back({'0, 1'b1});
    custom_data.push_back(2**(N_BITS_C-Q_BITS_C)-1);
    vip_axi4s_seq0.set_custom_data(custom_data);
    vip_axi4s_seq0.start(v_sqr.mst_sequencer);
    custom_data.delete();

    clk_delay(10);

    `uvm_info(get_name(), $sformatf("Lowest fractional part * lowest possible value"), UVM_LOW)
    custom_data.push_back({'0, 1'b1});
    custom_data.push_back(-2**(N_BITS_C-Q_BITS_C));
    vip_axi4s_seq0.set_custom_data(custom_data);
    vip_axi4s_seq0.start(v_sqr.mst_sequencer);
    custom_data.delete();

    clk_delay(10);
    phase.drop_objection(this);

  endtask

endclass
