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

`uvm_analysis_imp_decl(_awaddr_port0)
`uvm_analysis_imp_decl(_wdata_port0)
`uvm_analysis_imp_decl(_awaddr_port1)
`uvm_analysis_imp_decl(_wdata_port1)
`uvm_analysis_imp_decl(_awaddr_port2)
`uvm_analysis_imp_decl(_wdata_port2)
`uvm_analysis_imp_decl(_awaddr_port3)
`uvm_analysis_imp_decl(_wdata_port3)
`uvm_analysis_imp_decl(_mem_port)

class awa_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(awa_scoreboard)

  // Scoreboard ports
  uvm_analysis_imp_awaddr_port0 #(vip_axi4_item #(VIP_AXI4_CFG_C), awa_scoreboard) awaddr_port0;
  uvm_analysis_imp_wdata_port0  #(vip_axi4_item #(VIP_AXI4_CFG_C), awa_scoreboard) wdata_port0;
  uvm_analysis_imp_awaddr_port1 #(vip_axi4_item #(VIP_AXI4_CFG_C), awa_scoreboard) awaddr_port1;
  uvm_analysis_imp_wdata_port1  #(vip_axi4_item #(VIP_AXI4_CFG_C), awa_scoreboard) wdata_port1;
  uvm_analysis_imp_awaddr_port2 #(vip_axi4_item #(VIP_AXI4_CFG_C), awa_scoreboard) awaddr_port2;
  uvm_analysis_imp_wdata_port2  #(vip_axi4_item #(VIP_AXI4_CFG_C), awa_scoreboard) wdata_port2;
  uvm_analysis_imp_awaddr_port3 #(vip_axi4_item #(VIP_AXI4_CFG_C), awa_scoreboard) awaddr_port3;
  uvm_analysis_imp_wdata_port3  #(vip_axi4_item #(VIP_AXI4_CFG_C), awa_scoreboard) wdata_port3;
  uvm_analysis_imp_mem_port     #(vip_axi4_item #(VIP_AXI4_CFG_C), awa_scoreboard) mem_port;

  // Storage for comparison
  vip_axi4_item #(VIP_AXI4_CFG_C) write_address_items [$];
  vip_axi4_item #(VIP_AXI4_CFG_C) write_data_items    [$];
  vip_axi4_item #(VIP_AXI4_CFG_C) memory_write_items  [$];


  // Debug storage
  vip_axi4_item #(VIP_AXI4_CFG_C) all_write_address_items [$];
  vip_axi4_item #(VIP_AXI4_CFG_C) all_write_data_items    [$];
  vip_axi4_item #(VIP_AXI4_CFG_C) all_memory_write_items  [$];


  uvm_phase current_phase;

  int number_of_write_address_items;
  int number_of_write_data_items;
  int number_of_memory_write_items;

  int number_of_compared;
  int number_of_passed;
  int number_of_failed;

  vip_axi4_item #(VIP_AXI4_CFG_C) current_ingress_item;
  vip_axi4_item #(VIP_AXI4_CFG_C) current_egress_item;


  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    awaddr_port0 = new("awaddr_port0", this);
    wdata_port0  = new("wdata_port0",  this);
    awaddr_port1 = new("awaddr_port1", this);
    wdata_port1  = new("wdata_port1",  this);
    awaddr_port2 = new("awaddr_port2", this);
    wdata_port2  = new("wdata_port2",  this);
    awaddr_port3 = new("awaddr_port3", this);
    wdata_port3  = new("wdata_port3",  this);
    mem_port     = new("mem_port",     this);
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


  // Agent 0
  virtual function void write_awaddr_port0(vip_axi4_item #(VIP_AXI4_CFG_C) trans);

    number_of_write_address_items++;
    all_write_address_items.push_back(trans);
    write_address_items.push_back(trans);
    current_phase.raise_objection(this);
  endfunction


  virtual function void write_wdata_port0(vip_axi4_item #(VIP_AXI4_CFG_C) trans);

    number_of_write_data_items++;
    all_write_data_items.push_back(trans);
    write_data_items.push_back(trans);
  endfunction

  // Agent 1
  virtual function void write_awaddr_port1(vip_axi4_item #(VIP_AXI4_CFG_C) trans);

    number_of_write_address_items++;
    all_write_address_items.push_back(trans);
    write_address_items.push_back(trans);
    current_phase.raise_objection(this);
  endfunction


  virtual function void write_wdata_port1(vip_axi4_item #(VIP_AXI4_CFG_C) trans);

    number_of_write_data_items++;
    all_write_data_items.push_back(trans);
    write_data_items.push_back(trans);
  endfunction

  // Agent 2
  virtual function void write_awaddr_port2(vip_axi4_item #(VIP_AXI4_CFG_C) trans);

    number_of_write_address_items++;
    all_write_address_items.push_back(trans);
    write_address_items.push_back(trans);
    current_phase.raise_objection(this);
  endfunction


  virtual function void write_wdata_port2(vip_axi4_item #(VIP_AXI4_CFG_C) trans);

    number_of_write_data_items++;
    all_write_data_items.push_back(trans);
    write_data_items.push_back(trans);
  endfunction

  // Agent 3
  virtual function void write_awaddr_port3(vip_axi4_item #(VIP_AXI4_CFG_C) trans);

    number_of_write_address_items++;
    all_write_address_items.push_back(trans);
    write_address_items.push_back(trans);
    current_phase.raise_objection(this);
  endfunction


  virtual function void write_wdata_port3(vip_axi4_item #(VIP_AXI4_CFG_C) trans);

    number_of_write_data_items++;
    all_write_data_items.push_back(trans);
    write_data_items.push_back(trans);
  endfunction

  // Memory Agent
  virtual function void write_mem_port(vip_axi4_item #(VIP_AXI4_CFG_C) trans);

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
    end else begin
      number_of_passed++;
    end
  endfunction
endclass
