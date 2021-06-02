////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2021 Fredrik Åkerlund
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

`uvm_analysis_imp_decl(_x_port)
`uvm_analysis_imp_decl(_y_port)

class fir_scoreboard extends uvm_scoreboard;

  `uvm_component_utils(fir_scoreboard)

  uvm_analysis_imp_x_port #(vip_axi4s_item #(VIP_AXI4S_CFG_C), fir_scoreboard) x_port;
  uvm_analysis_imp_y_port #(vip_axi4s_item #(VIP_AXI4S_CFG_C), fir_scoreboard) y_port;

  // The testbench configuration
  fir_config tb_cfg;

  // For raising objections
  uvm_phase current_phase;

  // Statistics
  int number_of_compared;
  int number_of_passed;
  int number_of_failed;


  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction


  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    x_port = new("x_port", this);
    y_port = new("y_port", this);
  endfunction


  virtual task run_phase(uvm_phase phase);
    current_phase = phase;
    super.run_phase(current_phase);

    if (!uvm_config_db #(fir_config)::get(null, "*", "tb_cfg", tb_cfg)) begin
      `uvm_fatal("NOCFG", "No config in the factory")
    end
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

  //----------------------------------------------------------------------------
  // Filter input data
  //----------------------------------------------------------------------------
  virtual function void write_x_port(vip_axi4s_item #(VIP_AXI4S_CFG_C) trans);

  endfunction

  //----------------------------------------------------------------------------
  // Filter output data
  //----------------------------------------------------------------------------
  virtual function void write_y_port(vip_axi4s_item #(VIP_AXI4S_CFG_C) trans);

  endfunction

endclass
