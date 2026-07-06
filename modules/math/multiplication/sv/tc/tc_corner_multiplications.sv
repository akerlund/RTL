////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2026 Fredrik Åkerlund
// https://github.com/akerlund/RTL
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
