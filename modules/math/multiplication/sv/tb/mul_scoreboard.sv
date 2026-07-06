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

import vip_fixed_point_pkg::*;
import vip_math_pkg::*;

`uvm_analysis_imp_decl(_collected_port_mst0)
`uvm_analysis_imp_decl(_collected_port_slv0)

class mul_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(mul_scoreboard)

  uvm_analysis_imp_collected_port_mst0 #(vip_axi4s_item #(VIP_AXI4S_CFG_C), mul_scoreboard) collected_port_mst0;
  uvm_analysis_imp_collected_port_slv0 #(vip_axi4s_item #(VIP_AXI4S_CFG_C), mul_scoreboard) collected_port_slv0;

  // Storage for comparison
  vip_axi4s_item #(VIP_AXI4S_CFG_C) master_items [$];
  vip_axi4s_item #(VIP_AXI4S_CFG_C) slave_items  [$];

  // Debug storage
  vip_axi4s_item #(VIP_AXI4S_CFG_C) all_master_items [$];
  vip_axi4s_item #(VIP_AXI4S_CFG_C) all_slave_items  [$];

  // For raising objections
  uvm_phase current_phase;

  int number_of_master_items;
  int number_of_slave_items;

  // Statistics
  int number_of_compared;
  int number_of_passed;
  int number_of_failed;

  int nr_of_overflows;


  // For calculating the prediction and comparing
  logic signed [N_BITS_C-1 : 0] ing_nq_multiplicand;
  logic signed [N_BITS_C-1 : 0] ing_nq_multiplier;
  logic signed [N_BITS_C-1 : 0] egr_nq_product;
  int                           egr_nq_overflow;
  real                          max_difference = 1.0/(Q_BITS_C+1);


  real sb_nq_multiplicand;
  real sb_nq_multiplier;
  real sb_nq_product;
  real sb_prediction;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction



  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    collected_port_mst0 = new("collected_port_mst0", this);
    collected_port_slv0 = new("collected_port_slv0", this);

  endfunction



  function void connect_phase(uvm_phase phase);

    current_phase = phase;
    super.connect_phase(current_phase);

  endfunction



  virtual task run_phase(uvm_phase phase);

    current_phase = phase;
    super.run_phase(current_phase);

    `uvm_info(get_name(), $sformatf("N_BITS_C: (%0d)", N_BITS_C), UVM_LOW)
    `uvm_info(get_name(), $sformatf("Q_BITS_C: (%0d)", Q_BITS_C), UVM_LOW)

  endtask



  function void check_phase(uvm_phase phase);

    current_phase = phase;
    super.check_phase(current_phase);

    if (master_items.size() > 0) begin
      `uvm_error(get_name(), $sformatf("There are still items in the Master queue"))
    end

    if (slave_items.size() > 0) begin
      `uvm_error(get_name(), $sformatf("There are still items in the Slave queue"))
    end

    if (number_of_failed != 0) begin
      `uvm_error(get_name(), $sformatf("Test failed! (%0d) mismatches", number_of_failed))
    end
    else begin
      `uvm_info(get_name(), $sformatf("Test passed (%0d)/(%0d) finished transfers", number_of_passed, number_of_compared), UVM_LOW)
      `uvm_info(get_name(), $sformatf("Overflows: (%0d)", nr_of_overflows), UVM_LOW)
    end

  endfunction

  //----------------------------------------------------------------------------
  // Master Agents
  //----------------------------------------------------------------------------

  virtual function void write_collected_port_mst0(vip_axi4s_item #(VIP_AXI4S_CFG_C) trans);

    number_of_master_items++;
    master_items.push_back(trans);
    all_master_items.push_back(trans);
    current_phase.raise_objection(this);

  endfunction


  //----------------------------------------------------------------------------
  // Slave Agent
  //----------------------------------------------------------------------------

  virtual function void write_collected_port_slv0(vip_axi4s_item #(VIP_AXI4S_CFG_C) trans);

    number_of_slave_items++;
    slave_items.push_back(trans);
    all_slave_items.push_back(trans);

    compare();

    current_phase.drop_objection(this);

  endfunction


  virtual function void compare();

    vip_axi4s_item #(VIP_AXI4S_CFG_C) current_master_item;
    vip_axi4s_item #(VIP_AXI4S_CFG_C) current_slave_item;

    current_master_item = master_items.pop_front();
    current_slave_item  = slave_items.pop_front();

    ing_nq_multiplicand = current_master_item.tdata[0];
    ing_nq_multiplier   = current_master_item.tdata[1];
    egr_nq_product      = current_slave_item.tdata[0];
    egr_nq_overflow     = current_slave_item.tuser[0];

    if (egr_nq_overflow) begin
      nr_of_overflows++;
      number_of_passed++;
      number_of_compared++;
      return;
    end
    else begin

      sb_nq_multiplicand = fixed_point_to_float(ing_nq_multiplicand, N_BITS_C-Q_BITS_C, Q_BITS_C);
      sb_nq_multiplier   = fixed_point_to_float(ing_nq_multiplier,   N_BITS_C-Q_BITS_C, Q_BITS_C);
      sb_nq_product      = fixed_point_to_float(egr_nq_product,      N_BITS_C-Q_BITS_C, Q_BITS_C);
      sb_prediction      = fixed_point_to_float(float_to_fixed_point(sb_nq_multiplicand * sb_nq_multiplier, Q_BITS_C), N_BITS_C-Q_BITS_C, Q_BITS_C);

      if (abs_real(abs_real(sb_nq_product) - abs_real(sb_prediction)) > max_difference) begin
        `uvm_error(get_name(), $sformatf("Multiplication number (%0d) mismatches: (%f*%f != %f), scoreboard predicts (%f)",
                                          number_of_compared, sb_nq_multiplicand, sb_nq_multiplier, sb_nq_product, sb_prediction))
        number_of_failed++;
      end
      else begin
        number_of_passed++;
      end

    end

    number_of_compared++;

  endfunction

endclass
