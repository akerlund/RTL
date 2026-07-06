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

class div_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(div_scoreboard)

  uvm_analysis_imp_collected_port_mst0 #(vip_axi4s_item #(VIP_AXI4S_CFG_C), div_scoreboard) collected_port_mst0;
  uvm_analysis_imp_collected_port_slv0 #(vip_axi4s_item #(VIP_AXI4S_CFG_C), div_scoreboard) collected_port_slv0;

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
  int                           overflow;
  logic signed [N_BITS_C-1 : 0] int_dividend;
  logic signed [N_BITS_C-1 : 0] int_divisor;
  logic signed [N_BITS_C-1 : 0] int_quotient;
  logic signed [N_BITS_C-1 : 0] sb_int_quotient;
  real                          real_dividend;
  real                          real_divisor;
  real                          real_quotient;
  real                          sb_real_quotient;
  real                          max_difference = 1.0/(Q_BITS_C+1);

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

    int_dividend = current_master_item.tdata[0];
    int_divisor  = current_master_item.tdata[1];
    int_quotient = current_slave_item.tdata[0];

    overflow = current_slave_item.tuser[0];

    if (overflow) begin
      nr_of_overflows++;
      number_of_passed++;
      number_of_compared++;
      return;
    end

    // Converting values from the Monitors to floats
    real_dividend    = fixed_point_to_float(int_dividend, N_BITS_C-Q_BITS_C, Q_BITS_C);
    real_divisor     = fixed_point_to_float(int_divisor,  N_BITS_C-Q_BITS_C, Q_BITS_C);
    real_quotient    = fixed_point_to_float(int_quotient, N_BITS_C-Q_BITS_C, Q_BITS_C);


    // Scoreboard quotient prediction
    sb_real_quotient = real_dividend/real_divisor;                                         // Predict (too accurately)
    sb_int_quotient  = float_to_fixed_point(sb_real_quotient, Q_BITS_C);                   // Convert to FP in order to lose accuracy
    sb_real_quotient = fixed_point_to_float(sb_int_quotient, N_BITS_C-Q_BITS_C, Q_BITS_C); // Convert back and it should match

    if (real_quotient != sb_real_quotient) begin

      if (abs_real(abs_real(real_quotient) - abs_real(sb_real_quotient)) > max_difference) begin
        `uvm_error(get_name(), $sformatf("Division number (%0d) mismatches: (%f/%f != %f), scoreboard predicts (%f)", number_of_compared, real_dividend, real_divisor, real_quotient, sb_real_quotient))
        number_of_failed++;
      end
      else begin
        number_of_passed++;
      end
    end else begin
      number_of_passed++;
    end
    number_of_compared++;

  endfunction

endclass
