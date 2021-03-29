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

`uvm_analysis_imp_decl(_ing_araddr_port)
`uvm_analysis_imp_decl(_ing_rdata_port)
`uvm_analysis_imp_decl(_egr_rdata_port)

class ara_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(ara_scoreboard)

  // Scoreboard ports
  uvm_analysis_imp_ing_araddr_port #(vip_axi4_item #(VIP_AXI4_CFG_C), ara_scoreboard) ing_araddr_port;
  uvm_analysis_imp_ing_rdata_port  #(vip_axi4_item #(VIP_AXI4_CFG_C), ara_scoreboard) ing_rdata_port;
  uvm_analysis_imp_egr_rdata_port  #(vip_axi4_item #(VIP_AXI4_CFG_C), ara_scoreboard) egr_rdata_port;

  // Storage for comparison
  vip_axi4_item #(VIP_AXI4_CFG_C) read_data_items0  [$];
  vip_axi4_item #(VIP_AXI4_CFG_C) memory_data_items [$];

  // Debug storage
  vip_axi4_item #(VIP_AXI4_CFG_C) all_read_address_items [$];
  vip_axi4_item #(VIP_AXI4_CFG_C) all_read_data_items0   [$];
  vip_axi4_item #(VIP_AXI4_CFG_C) all_memory_data_items  [$];

  int number_of_ma_data_misses;

  uvm_phase current_phase;

  int number_of_read_address_items;
  int number_of_read_data_items;
  int number_of_memory_data_items;

  int number_of_compared;
  int number_of_passed;
  int number_of_failed;

  vip_axi4_item #(VIP_AXI4_CFG_C) current_master_item;
  vip_axi4_item #(VIP_AXI4_CFG_C) current_slave_item;


  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ing_araddr_port = new("ing_araddr_port", this);
    ing_rdata_port  = new("ing_rdata_port",  this);
    egr_rdata_port    = new("egr_rdata_port",    this);
  endfunction


  function void connect_phase(uvm_phase phase);
    current_phase = phase;
    super.connect_phase(current_phase);
  endfunction


  virtual task run_phase(uvm_phase phase);
    current_phase = phase;
    super.run_phase(current_phase);
  endtask


  function void check_phase(uvm_phase phase);
    current_phase = phase;
    super.check_phase(current_phase);
    if (number_of_failed != 0) begin
      `uvm_error(get_name(), $sformatf("Test failed! (%0d) mismatches", number_of_failed))
    end else begin
      `uvm_info(get_name(), $sformatf("Test passed (%0d)/(%0d) finished transfers", number_of_passed, number_of_compared), UVM_LOW)
    end
  endfunction


  // ---------------------------------------------------------------------------
  // Agent 0
  // ---------------------------------------------------------------------------
  virtual function void write_ing_araddr_port(vip_axi4_item #(VIP_AXI4_CFG_C) trans);
    number_of_read_address_items++;
    all_read_address_items.push_back(trans);
    current_phase.raise_objection(this);
  endfunction


  virtual function void write_ing_rdata_port(vip_axi4_item #(VIP_AXI4_CFG_C) trans);
    number_of_read_data_items++;
    all_read_data_items0.push_back(trans);
    current_master_item = trans;

    if (compare()) begin
      current_phase.drop_objection(this);
    end
  endfunction

  // ---------------------------------------------------------------------------
  // Memory Agent
  // ---------------------------------------------------------------------------
  virtual function void write_egr_rdata_port(vip_axi4_item #(VIP_AXI4_CFG_C) trans);

    number_of_memory_data_items++;
    all_memory_data_items.push_back(trans);
    memory_data_items.push_back(trans);

    if (current_master_item != null) begin
      compare();
      current_phase.drop_objection(this);
    end
  endfunction



  // ---------------------------------------------------------------------------
  //
  // ---------------------------------------------------------------------------
  virtual function bool_t compare();

    current_slave_item = memory_data_items.pop_front();

    // There is a chance that this agent's monitor will write after this function call
    if (current_slave_item == null) begin
      number_of_ma_data_misses++;
      return FALSE;
    end

    number_of_compared++;

    if (!current_master_item.compare(current_slave_item)) begin
      `uvm_error(get_name(), $sformatf("Packet number (%0d) mismatches", number_of_compared))
      number_of_failed++;
    end else begin
      number_of_passed++;
    end

    current_master_item = null;
    return TRUE;
  endfunction

endclass
