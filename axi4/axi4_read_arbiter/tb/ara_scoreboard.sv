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

`uvm_analysis_imp_decl(_ra_address_port0)
`uvm_analysis_imp_decl(_ra_address_port1)
`uvm_analysis_imp_decl(_ra_address_port2)
`uvm_analysis_imp_decl(_ra_data_port0)
`uvm_analysis_imp_decl(_ra_data_port1)
`uvm_analysis_imp_decl(_ra_data_port2)
`uvm_analysis_imp_decl(_ma_data_port)

class ara_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(ara_scoreboard)

  // Scoreboard ports
  uvm_analysis_imp_ra_address_port0 #(axi4_read_item #(vip_axi4_cfg), ara_scoreboard) ra_address_port0;
  uvm_analysis_imp_ra_address_port1 #(axi4_read_item #(vip_axi4_cfg), ara_scoreboard) ra_address_port1;
  uvm_analysis_imp_ra_address_port2 #(axi4_read_item #(vip_axi4_cfg), ara_scoreboard) ra_address_port2;
  uvm_analysis_imp_ra_data_port0    #(axi4_read_item #(vip_axi4_cfg), ara_scoreboard) ra_data_port0;
  uvm_analysis_imp_ra_data_port1    #(axi4_read_item #(vip_axi4_cfg), ara_scoreboard) ra_data_port1;
  uvm_analysis_imp_ra_data_port2    #(axi4_read_item #(vip_axi4_cfg), ara_scoreboard) ra_data_port2;
  uvm_analysis_imp_ma_data_port     #(axi4_read_item #(vip_axi4_cfg), ara_scoreboard) ma_data_port;

  // Storage for comparison
  axi4_read_item #(vip_axi4_cfg) read_data_items0  [$];
  axi4_read_item #(vip_axi4_cfg) read_data_items1  [$];
  axi4_read_item #(vip_axi4_cfg) read_data_items2  [$];
  axi4_read_item #(vip_axi4_cfg) memory_data_items [$];

  // Debug storage
  axi4_read_item #(vip_axi4_cfg) all_read_address_items [$];
  axi4_read_item #(vip_axi4_cfg) all_read_data_items0   [$];
  axi4_read_item #(vip_axi4_cfg) all_read_data_items1   [$];
  axi4_read_item #(vip_axi4_cfg) all_read_data_items2   [$];
  axi4_read_item #(vip_axi4_cfg) all_memory_data_items  [$];

  int number_of_ma_data_misses;

  uvm_phase current_phase;

  int number_of_read_address_items;
  int number_of_read_data_items;
  int number_of_memory_data_items;

  int number_of_compared;
  int number_of_passed;
  int number_of_failed;

  axi4_read_item #(vip_axi4_cfg) current_master_item;
  axi4_read_item #(vip_axi4_cfg) current_slave_item;


  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction



  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    ra_address_port0 = new("ra_address_port0", this);
    ra_address_port1 = new("ra_address_port1", this);
    ra_address_port2 = new("ra_address_port2", this);
    ra_data_port0    = new("ra_data_port0",    this);
    ra_data_port1    = new("ra_data_port1",    this);
    ra_data_port2    = new("ra_data_port2",    this);
    ma_data_port     = new("ma_data_port",     this);

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


  // ---------------------------------------------------------------------------
  // Agent 0
  // ---------------------------------------------------------------------------
  virtual function void write_ra_address_port0(axi4_read_item #(vip_axi4_cfg) trans);

    number_of_read_address_items++;
    all_read_address_items.push_back(trans);
    current_phase.raise_objection(this);

  endfunction


  virtual function void write_ra_data_port0(axi4_read_item #(vip_axi4_cfg) trans);

    number_of_read_data_items++;
    all_read_data_items0.push_back(trans);
    current_master_item = trans;

    if (compare()) begin
      current_phase.drop_objection(this);
    end

  endfunction


  // ---------------------------------------------------------------------------
  // Agent 1
  // ---------------------------------------------------------------------------
  virtual function void write_ra_address_port1(axi4_read_item #(vip_axi4_cfg) trans);

    number_of_read_address_items++;
    all_read_address_items.push_back(trans);
    current_phase.raise_objection(this);

  endfunction


  virtual function void write_ra_data_port1(axi4_read_item #(vip_axi4_cfg) trans);

    number_of_read_data_items++;
    all_read_data_items1.push_back(trans);
    current_master_item = trans;

    if (compare()) begin
      current_phase.drop_objection(this);
    end

  endfunction


  // ---------------------------------------------------------------------------
  // Agent 2
  // ---------------------------------------------------------------------------
  virtual function void write_ra_address_port2(axi4_read_item #(vip_axi4_cfg) trans);

    number_of_read_address_items++;
    all_read_address_items.push_back(trans);
    current_phase.raise_objection(this);

  endfunction


  virtual function void write_ra_data_port2(axi4_read_item #(vip_axi4_cfg) trans);

    number_of_read_data_items++;
    all_read_data_items2.push_back(trans);
    current_master_item = trans;

    if (compare()) begin
      current_phase.drop_objection(this);
    end

  endfunction


  // ---------------------------------------------------------------------------
  // Memory Agent
  // ---------------------------------------------------------------------------
  virtual function void write_ma_data_port(axi4_read_item #(vip_axi4_cfg) trans);

    number_of_memory_data_items++;
    all_memory_data_items.push_back(trans);
    memory_data_items.push_back(trans);


    if (current_master_item != null) begin
      compare();
      current_phase.drop_objection(this);
    end


  endfunction



  virtual function int compare();

    current_slave_item = memory_data_items.pop_front();

    // There is a chance that this agent's monitor will write after this function call
    if (current_slave_item == null) begin
      number_of_ma_data_misses++;
      return 0;
    end

    number_of_compared++;

    if (!current_master_item.compare(current_slave_item)) begin

      `uvm_error(get_name(), $sformatf("Packet number (%0d) mismatches", number_of_compared))
      number_of_failed++;

    end
    else begin

      number_of_passed++;

    end

    current_master_item = null;
    return 1;

  endfunction

endclass
