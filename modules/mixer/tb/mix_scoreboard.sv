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

import vip_fixed_point_pkg::*;
import vip_math_pkg::*;

`uvm_analysis_imp_decl(_collected_port_mst0)
`uvm_analysis_imp_decl(_collected_port_slv0)

class mix_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(mix_scoreboard)

  uvm_analysis_imp_collected_port_mst0 #(vip_axi4s_item #(vip_axi4s_cfg), mix_scoreboard) collected_port_mst0;
  uvm_analysis_imp_collected_port_slv0 #(vip_axi4s_item #(vip_axi4s_cfg), mix_scoreboard) collected_port_slv0;

  // Storage for comparison
  vip_axi4s_item #(vip_axi4s_cfg) master_items [$];
  vip_axi4s_item #(vip_axi4s_cfg) slave_items  [$];

  // Debug storage
  vip_axi4s_item #(vip_axi4s_cfg) all_master_items [$];
  vip_axi4s_item #(vip_axi4s_cfg) all_slave_items  [$];

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
  logic signed [AUDIO_WIDTH_C-1 : 0] ing_nq_multiplicand;
  logic signed [AUDIO_WIDTH_C-1 : 0] ing_nq_multiplier;
  logic signed [AUDIO_WIDTH_C-1 : 0] egr_nq_product;
  int                                egr_nq_overflow;
  real                               max_difference = 1.0/(Q_BITS_C+1);


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

    `uvm_info(get_name(), $sformatf("AUDIO_WIDTH_C: (%0d)", AUDIO_WIDTH_C), UVM_LOW)
    `uvm_info(get_name(), $sformatf("Q_BITS_C:      (%0d)", Q_BITS_C),      UVM_LOW)

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

  virtual function void write_collected_port_mst0(vip_axi4s_item #(vip_axi4s_cfg) trans);

    number_of_master_items++;
    master_items.push_back(trans);
    all_master_items.push_back(trans);

    current_phase.raise_objection(this);

  endfunction


  //----------------------------------------------------------------------------
  // Slave Agent
  //----------------------------------------------------------------------------

  virtual function void write_collected_port_slv0(vip_axi4s_item #(vip_axi4s_cfg) trans);

    number_of_slave_items++;
    slave_items.push_back(trans);
    all_slave_items.push_back(trans);

    compare();

    current_phase.drop_objection(this);

  endfunction


  virtual function void compare();

    vip_axi4s_item #(vip_axi4s_cfg) current_master_item;
    vip_axi4s_item #(vip_axi4s_cfg) current_slave_item;

    current_master_item = master_items.pop_front();
    current_slave_item  = slave_items.pop_front();
    sb_nq_multiplicand  = fixed_point_to_float(current_master_item.tdata[0], AUDIO_WIDTH_C, Q_BITS_C);
    sb_nq_product       = fixed_point_to_float(current_slave_item.tdata[0],  AUDIO_WIDTH_C, Q_BITS_C);
    `uvm_info(get_name(), $sformatf("in = (%f) out = (%f)", sb_nq_multiplicand, sb_nq_product), UVM_LOW)

    number_of_compared++;

  endfunction

endclass
