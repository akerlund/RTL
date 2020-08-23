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

`uvm_analysis_imp_decl(_address_port0)
`uvm_analysis_imp_decl(_data_port0)
`uvm_analysis_imp_decl(_address_port1)
`uvm_analysis_imp_decl(_data_port1)
`uvm_analysis_imp_decl(_address_port2)
`uvm_analysis_imp_decl(_data_port2)
`uvm_analysis_imp_decl(_mem_port)

class awa_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(awa_scoreboard)

  // Scoreboard ports
  uvm_analysis_imp_address_port0 #(axi4_write_item #(vip_axi4_cfg), awa_scoreboard) address_port0;
  uvm_analysis_imp_data_port0    #(axi4_write_item #(vip_axi4_cfg), awa_scoreboard) data_port0;
  uvm_analysis_imp_address_port1 #(axi4_write_item #(vip_axi4_cfg), awa_scoreboard) address_port1;
  uvm_analysis_imp_data_port1    #(axi4_write_item #(vip_axi4_cfg), awa_scoreboard) data_port1;
  uvm_analysis_imp_address_port2 #(axi4_write_item #(vip_axi4_cfg), awa_scoreboard) address_port2;
  uvm_analysis_imp_data_port2    #(axi4_write_item #(vip_axi4_cfg), awa_scoreboard) data_port2;
  uvm_analysis_imp_mem_port      #(axi4_write_item #(vip_axi4_cfg), awa_scoreboard) mem_port;

  // Storage for comparison
  axi4_write_item #(vip_axi4_cfg) write_address_items [$];
  axi4_write_item #(vip_axi4_cfg) write_data_items    [$];
  axi4_write_item #(vip_axi4_cfg) memory_write_items  [$];


  // Debug storage
  axi4_write_item #(vip_axi4_cfg) all_write_address_items [$];
  axi4_write_item #(vip_axi4_cfg) all_write_data_items    [$];
  axi4_write_item #(vip_axi4_cfg) all_memory_write_items  [$];


  uvm_phase current_phase;

  int number_of_write_address_items;
  int number_of_write_data_items;
  int number_of_memory_write_items;

  int number_of_compared;
  int number_of_passed;
  int number_of_failed;

  axi4_write_item #(vip_axi4_cfg) current_ingress_item;
  axi4_write_item #(vip_axi4_cfg) current_egress_item;


  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction



  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    address_port0 = new("address_port0", this);
    data_port0    = new("data_port0", this);
    address_port1 = new("address_port1", this);
    data_port1    = new("data_port1", this);
    address_port2 = new("address_port2", this);
    data_port2    = new("data_port2", this);
    mem_port      = new("mem_port", this);

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
    end
    else begin
      `uvm_info(get_name(), $sformatf("Test passed (%0d)/(%0d) finished transfers", number_of_passed, number_of_compared), UVM_LOW)
    end

  endfunction


  // Agent 0
  virtual function void write_address_port0(axi4_write_item #(vip_axi4_cfg) trans);

    number_of_write_address_items++;
    all_write_address_items.push_back(trans);
    write_address_items.push_back(trans);
    current_phase.raise_objection(this);

  endfunction


  virtual function void write_data_port0(axi4_write_item #(vip_axi4_cfg) trans);

    number_of_write_data_items++;
    all_write_data_items.push_back(trans);
    write_data_items.push_back(trans);

  endfunction


  // Agent 1
  virtual function void write_address_port1(axi4_write_item #(vip_axi4_cfg) trans);

    number_of_write_address_items++;
    all_write_address_items.push_back(trans);
    write_address_items.push_back(trans);
    current_phase.raise_objection(this);

  endfunction


  virtual function void write_data_port1(axi4_write_item #(vip_axi4_cfg) trans);

    number_of_write_data_items++;
    all_write_data_items.push_back(trans);
    write_data_items.push_back(trans);

  endfunction


  // Agent 2
  virtual function void write_address_port2(axi4_write_item #(vip_axi4_cfg) trans);

    number_of_write_address_items++;
    all_write_address_items.push_back(trans);
    write_address_items.push_back(trans);
    current_phase.raise_objection(this);

  endfunction


  virtual function void write_data_port2(axi4_write_item #(vip_axi4_cfg) trans);

    number_of_write_data_items++;
    all_write_data_items.push_back(trans);
    write_data_items.push_back(trans);

  endfunction


  // Memory Agent
  virtual function void write_mem_port(axi4_write_item #(vip_axi4_cfg) trans);

    number_of_memory_write_items++;
    all_memory_write_items.push_back(trans);
    memory_write_items.push_back(trans);

    compare();

    current_phase.drop_objection(this);

  endfunction



  virtual function void compare();

    current_ingress_item = write_data_items.pop_front();
    current_egress_item  = memory_write_items.pop_front();

    number_of_compared++;

    if (!current_ingress_item.compare(current_egress_item)) begin

      `uvm_error(get_name(), $sformatf("Packet number (%0d) mismatches", number_of_compared))
      number_of_failed++;

    end
    else begin

      number_of_passed++;

    end

  endfunction

endclass
