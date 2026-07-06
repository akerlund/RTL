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

`uvm_analysis_imp_decl(_mst_port)
`uvm_analysis_imp_decl(_slv_port)

class fi_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(fi_scoreboard)

  uvm_analysis_imp_mst_port #(vip_axi4s_item #(VIP_AXI4S_CFG_C), fi_scoreboard) mst_port;
  uvm_analysis_imp_slv_port #(vip_axi4s_item #(VIP_AXI4S_CFG_C), fi_scoreboard) slv_port;

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


  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mst_port = new("mst_port", this);
    slv_port = new("slv_port", this);
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
      `uvm_error(get_name(), $sformatf("Test failed! (%0d/%0d) mismatches", number_of_failed, number_of_compared))
    end else begin
      `uvm_info(get_name(), $sformatf("Test passed (%0d/%0d) finished transfers", number_of_passed, number_of_compared), UVM_LOW)
    end
  endfunction

  //----------------------------------------------------------------------------
  // Master Agents
  //----------------------------------------------------------------------------

  virtual function void write_mst_port(vip_axi4s_item #(VIP_AXI4S_CFG_C) trans);
    number_of_master_items++;
    master_items.push_back(trans);
    all_master_items.push_back(trans);
    current_phase.raise_objection(this);
  endfunction


  //----------------------------------------------------------------------------
  // Slave Agent
  //----------------------------------------------------------------------------

  virtual function void write_slv_port(vip_axi4s_item #(VIP_AXI4S_CFG_C) trans);
    number_of_slave_items++;
    slave_items.push_back(trans);
    all_slave_items.push_back(trans);
    compare();
    current_phase.drop_objection(this);
  endfunction


  virtual function void compare();

    vip_axi4s_item #(VIP_AXI4S_CFG_C) current_master_item;
    vip_axi4s_item #(VIP_AXI4S_CFG_C) current_slave_item;

    int compare_ok = 1;

    current_master_item = master_items.pop_front();
    current_slave_item  = slave_items.pop_front();

    foreach (current_master_item.tdata[i]) begin
      if (current_master_item.tdata[i] != current_slave_item.tdata[i]) begin
        `uvm_info(get_name(), $sformatf("mst(%0d) != slv(%0d)", current_master_item.tdata[i], current_slave_item.tdata[i]), UVM_LOW)
        `uvm_error(get_name(), $sformatf("Packet number (%0d) mismatches", number_of_compared))
        compare_ok = 0;
        break;
      end
    end


    if (compare_ok) begin
      number_of_passed++;
    end else begin
      number_of_failed++;
    end

    number_of_compared++;

  endfunction
endclass
