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

`uvm_analysis_imp_decl(_collected_port_mst0)
`uvm_analysis_imp_decl(_collected_port_mst1)
`uvm_analysis_imp_decl(_collected_port_slv0)

class arb_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(arb_scoreboard)

  uvm_analysis_imp_collected_port_mst0 #(vip_axi4s_item #(vip_axi4s_cfg), arb_scoreboard) collected_port_mst0;
  uvm_analysis_imp_collected_port_mst1 #(vip_axi4s_item #(vip_axi4s_cfg), arb_scoreboard) collected_port_mst1;
  uvm_analysis_imp_collected_port_slv0 #(vip_axi4s_item #(vip_axi4s_cfg), arb_scoreboard) collected_port_slv0;

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

  int number_of_compared;
  int number_of_passed;
  int number_of_failed;



  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction



  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    collected_port_mst0 = new("collected_port_mst0", this);
    collected_port_mst1 = new("collected_port_mst1", this);
    collected_port_slv0 = new("collected_port_slv0", this);

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

    if (trans.tid != 0) begin
      `uvm_error(get_name(), $sformatf("Id is not (0), it is (%0d)", trans.tid))
      number_of_failed++;
    end

    if (master_items.size() && slave_items.size()) begin
      compare();
      current_phase.drop_objection(this);
    end

  endfunction


  virtual function void write_collected_port_mst1(vip_axi4s_item #(vip_axi4s_cfg) trans);

    number_of_master_items++;
    master_items.push_back(trans);
    all_master_items.push_back(trans);

    if (trans.tid != 1) begin
      `uvm_error(get_name(), $sformatf("Id is not (1), it is (%0d)", trans.tid))
      number_of_failed++;
    end

    current_phase.raise_objection(this);

    if (master_items.size() && slave_items.size()) begin
      compare();
      current_phase.drop_objection(this);
    end

  endfunction

  //----------------------------------------------------------------------------
  // Slave Agent
  //----------------------------------------------------------------------------

  virtual function void write_collected_port_slv0(vip_axi4s_item #(vip_axi4s_cfg) trans);

    number_of_slave_items++;
    slave_items.push_back(trans);
    all_slave_items.push_back(trans);

    if (master_items.size() && slave_items.size()) begin
      compare();
      current_phase.drop_objection(this);
    end

  endfunction


  virtual function void compare();

    vip_axi4s_item #(vip_axi4s_cfg) current_master_item;
    vip_axi4s_item #(vip_axi4s_cfg) current_slave_item;

    current_master_item = master_items.pop_front();
    current_slave_item  = slave_items.pop_front();

    number_of_compared++;

    if (!current_master_item.compare(current_slave_item)) begin

      `uvm_error(get_name(), $sformatf("Packet number (%0d) mismatches", number_of_compared))
      number_of_failed++;

    end
    else begin

      number_of_passed++;

    end

  endfunction

endclass
