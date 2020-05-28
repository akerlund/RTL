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
import vip_dsp_pkg::*;

`uvm_analysis_imp_decl(_apb_write_port)
`uvm_analysis_imp_decl(_apb_read_port)

class iir_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(iir_scoreboard)

  uvm_analysis_imp_apb_write_port #(vip_apb3_item #(vip_apb3_cfg), iir_scoreboard) apb_write_port;
  uvm_analysis_imp_apb_read_port  #(vip_apb3_item #(vip_apb3_cfg), iir_scoreboard) apb_read_port;

  // Storage for comparison
  vip_apb3_item #(vip_apb3_cfg) apb_write_items [$];
  vip_apb3_item #(vip_apb3_cfg) apb_read_items  [$];

  // Debug storage
  vip_apb3_item #(vip_apb3_cfg) all_apb_write_items [$];
  vip_apb3_item #(vip_apb3_cfg) all_apb_read_items  [$];

  // For raising objections
  uvm_phase current_phase;

  int number_of_apb_write_items;
  int number_of_apb_read_items;

  // Statistics
  int number_of_compared;
  int number_of_passed;
  int number_of_failed;


  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction


  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);
    apb_write_port = new("apb_write_port", this);
    apb_read_port  = new("apb_read_port", this);

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

    // if (apb_write_items.size() > 0) begin
    //   `uvm_error(get_name(), $sformatf("There are still items in the Master queue"))
    // end

    // if (apb_read_items.size() > 0) begin
    //   `uvm_error(get_name(), $sformatf("There are still items in the Slave queue"))
    // end

    if (number_of_failed != 0) begin
      `uvm_error(get_name(), $sformatf("Test failed! (%0d) mismatches", number_of_failed))
    end
    else begin
      `uvm_info(get_name(), $sformatf("Test passed (%0d)/(%0d) finished transfers", number_of_passed, number_of_compared), UVM_LOW)
    end
  endfunction

  //----------------------------------------------------------------------------
  // APB writes
  //----------------------------------------------------------------------------

  virtual function void write_apb_write_port(vip_apb3_item #(vip_apb3_cfg) trans);

    number_of_apb_write_items++;
    apb_write_items.push_back(trans);
    all_apb_write_items.push_back(trans);

    //current_phase.raise_objection(this);

  endfunction

  //----------------------------------------------------------------------------
  // APB reads
  //----------------------------------------------------------------------------

  virtual function void write_apb_read_port(vip_apb3_item #(vip_apb3_cfg) trans);

    number_of_apb_read_items++;
    apb_read_items.push_back(trans);
    all_apb_read_items.push_back(trans);

    `uvm_info(get_type_name(), $sformatf("Collected transfer:\n%s", trans.sprint()), UVM_LOW)

  endfunction

endclass
