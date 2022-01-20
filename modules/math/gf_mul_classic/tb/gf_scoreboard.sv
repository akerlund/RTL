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

`uvm_analysis_imp_decl(_mst_mul0_port)
`uvm_analysis_imp_decl(_slv_mul0_port)
`uvm_analysis_imp_decl(_mst_div0_port)
`uvm_analysis_imp_decl(_slv_div0_port)

class gf_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(gf_scoreboard)

  uvm_analysis_imp_mst_mul0_port #(vip_axi4s_item #(VIP_AXI4S_CFG_C), gf_scoreboard) mst_mul0_port;
  uvm_analysis_imp_slv_mul0_port #(vip_axi4s_item #(VIP_AXI4S_CFG_C), gf_scoreboard) slv_mul0_port;
  uvm_analysis_imp_mst_div0_port #(vip_axi4s_item #(VIP_AXI4S_CFG_C), gf_scoreboard) mst_div0_port;
  uvm_analysis_imp_slv_div0_port #(vip_axi4s_item #(VIP_AXI4S_CFG_C), gf_scoreboard) slv_div0_port;

  // Storage for comparison
  vip_axi4s_item #(VIP_AXI4S_CFG_C) master_items [$];
  vip_axi4s_item #(VIP_AXI4S_CFG_C) slave_items  [$];

  // For raising objections
  uvm_phase current_phase;

  // Statistics
  int number_of_compared;
  int number_of_passed;
  int number_of_failed;

  int ref_mul0_i;
  int ref_div0_i;


  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mst_mul0_port = new("mst_mul0_port", this);
    slv_mul0_port = new("slv_mul0_port", this);
    mst_div0_port = new("mst_div0_port", this);
    slv_div0_port = new("slv_div0_port", this);
    ref_mul0_i    = 0;
    ref_div0_i    = 0;
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

  virtual function void write_mst_mul0_port(vip_axi4s_item #(VIP_AXI4S_CFG_C) trans);
    current_phase.raise_objection(this);
  endfunction

  virtual function void write_mst_div0_port(vip_axi4s_item #(VIP_AXI4S_CFG_C) trans);
    current_phase.raise_objection(this);
  endfunction


  //----------------------------------------------------------------------------
  // Slave Agents
  //----------------------------------------------------------------------------

  virtual function void write_slv_mul0_port(vip_axi4s_item #(VIP_AXI4S_CFG_C) trans);
    compare_mul0(trans);
    current_phase.drop_objection(this);
  endfunction

  virtual function void write_slv_div0_port(vip_axi4s_item #(VIP_AXI4S_CFG_C) trans);
    compare_div0(trans);
    current_phase.drop_objection(this);
  endfunction


  //----------------------------------------------------------------------------
  // Compares
  //----------------------------------------------------------------------------

  virtual function void compare_mul0(vip_axi4s_item #(VIP_AXI4S_CFG_C) trans);

    int compare_ok = 1;
    int gf_ref     = GF_MUL_C[ref_mul0_i++][2];

    if (trans.tdata[0] != gf_ref) begin
      `uvm_info(get_name(), $sformatf("out(%0d) != ref(%0d)", trans.tdata[0], gf_ref), UVM_LOW)
      `uvm_error(get_name(), $sformatf("Packet number (%0d) mismatches", number_of_compared))
      compare_ok = 0;
    end

    if (compare_ok) begin
      number_of_passed++;
    end else begin
      number_of_failed++;
    end

    number_of_compared++;
  endfunction


  virtual function void compare_div0(vip_axi4s_item #(VIP_AXI4S_CFG_C) trans);

    int compare_ok = 1;
    int gf_ref     = GF_DIV_C[ref_div0_i++][2];

    if (trans.tdata[0] != gf_ref) begin
      `uvm_info(get_name(), $sformatf("out(%0d) != ref(%0d)", trans.tdata[0], gf_ref), UVM_LOW)
      `uvm_error(get_name(), $sformatf("Packet number (%0d) mismatches", number_of_compared))
      compare_ok = 0;
    end

    if (compare_ok) begin
      number_of_passed++;
    end else begin
      number_of_failed++;
    end

    number_of_compared++;
  endfunction
endclass
