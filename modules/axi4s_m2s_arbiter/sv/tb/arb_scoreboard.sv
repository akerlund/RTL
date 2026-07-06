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

`uvm_analysis_imp_decl(_collected_port_mst0)
`uvm_analysis_imp_decl(_collected_port_mst1)
`uvm_analysis_imp_decl(_collected_port_mst2)
`uvm_analysis_imp_decl(_collected_port_slv0)

class arb_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(arb_scoreboard)

  uvm_analysis_imp_collected_port_mst0 #(vip_axi4s_item #(VIP_AXI4S_CFG_C), arb_scoreboard) collected_port_mst0;
  uvm_analysis_imp_collected_port_mst1 #(vip_axi4s_item #(VIP_AXI4S_CFG_C), arb_scoreboard) collected_port_mst1;
  uvm_analysis_imp_collected_port_mst2 #(vip_axi4s_item #(VIP_AXI4S_CFG_C), arb_scoreboard) collected_port_mst2;
  uvm_analysis_imp_collected_port_slv0 #(vip_axi4s_item #(VIP_AXI4S_CFG_C), arb_scoreboard) collected_port_slv0;

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

  int number_of_compared;
  int number_of_passed;
  int number_of_failed;



  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // ---------------------------------------------------------------------------
  //
  // ---------------------------------------------------------------------------
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    collected_port_mst0 = new("collected_port_mst0", this);
    collected_port_mst1 = new("collected_port_mst1", this);
    collected_port_mst2 = new("collected_port_mst2", this);
    collected_port_slv0 = new("collected_port_slv0", this);
  endfunction

  // ---------------------------------------------------------------------------
  //
  // ---------------------------------------------------------------------------
  function void connect_phase(uvm_phase phase);
    current_phase = phase;
    super.connect_phase(current_phase);
  endfunction

  // ---------------------------------------------------------------------------
  //
  // ---------------------------------------------------------------------------
  virtual task run_phase(uvm_phase phase);
    current_phase = phase;
    super.run_phase(current_phase);
  endtask

  // ---------------------------------------------------------------------------
  //
  // ---------------------------------------------------------------------------
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
  virtual function void write_collected_port_mst0(vip_axi4s_item #(VIP_AXI4S_CFG_C) trans);

    number_of_master_items++;
    master_items.push_back(trans);
    all_master_items.push_back(trans);

    current_phase.raise_objection(this);

    if (master_items.size() && slave_items.size()) begin
      compare();
      current_phase.drop_objection(this);
    end
  endfunction

  virtual function void write_collected_port_mst1(vip_axi4s_item #(VIP_AXI4S_CFG_C) trans);

    number_of_master_items++;
    master_items.push_back(trans);
    all_master_items.push_back(trans);

    current_phase.raise_objection(this);

    if (master_items.size() && slave_items.size()) begin
      compare();
      current_phase.drop_objection(this);
    end
  endfunction

  virtual function void write_collected_port_mst2(vip_axi4s_item #(VIP_AXI4S_CFG_C) trans);

    number_of_master_items++;
    master_items.push_back(trans);
    all_master_items.push_back(trans);

    current_phase.raise_objection(this);

    if (master_items.size() && slave_items.size()) begin
      compare();
      current_phase.drop_objection(this);
    end
  endfunction

  //----------------------------------------------------------------------------
  // Slave Agent
  //----------------------------------------------------------------------------
  virtual function void write_collected_port_slv0(vip_axi4s_item #(VIP_AXI4S_CFG_C) trans);

    number_of_slave_items++;
    slave_items.push_back(trans);
    all_slave_items.push_back(trans);

    if (master_items.size() && slave_items.size()) begin
      compare();
      current_phase.drop_objection(this);
    end

  endfunction

  // ---------------------------------------------------------------------------
  //
  // ---------------------------------------------------------------------------
  virtual function void compare();

    vip_axi4s_item #(VIP_AXI4S_CFG_C) current_master_item;
    vip_axi4s_item #(VIP_AXI4S_CFG_C) current_slave_item;

    current_master_item = master_items.pop_front();
    current_slave_item  = slave_items.pop_front();

    if (!current_master_item.compare(current_slave_item)) begin
      `uvm_error(get_name(), $sformatf("Packet number (%0d) mismatches", number_of_compared))
      number_of_failed++;
    end else begin
      number_of_passed++;
    end
    number_of_compared++;

  endfunction
endclass
