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

class syfi_base_test extends uvm_test;

  `uvm_component_utils(syfi_base_test)

  syfi_env               tb_env;
  syfi_config            tb_cfg;
  syfi_virtual_sequencer v_sqr;

  uvm_table_printer printer;

  //----------------------------------------------------------------------------
  // Slave configurations
  //----------------------------------------------------------------------------

  // Back pressure on 'tready'. Time and period are number of clock periods.
  int tready_back_pressure_enabled = 0;

  // Set how long 'tready' can be asserter for back pressure
  int min_tready_deasserted_time = 1;
  int max_tready_deasserted_time = 10;

  // Set the period of when 'tready' is de-asserted
  int min_tready_deasserted_period = 10;
  int max_tready_deasserted_period = 55;



  function new(string name = "syfi_base_test", uvm_component parent = null);

    super.new(name, parent);

  endfunction



  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    printer = new();
    printer.knobs.depth = 3;

    uvm_config_db #(uvm_verbosity)::set(this, "*", "recording_detail", UVM_FULL);

    tb_env = syfi_env::type_id::create("tb_env", this);
    tb_cfg = syfi_config::type_id::create("tb_cfg", this);

  endfunction



  function void end_of_elaboration_phase(uvm_phase phase);

    `uvm_info(get_type_name(), $sformatf("Topology of the test:\n%s", this.sprint(printer)), UVM_LOW)
    v_sqr = tb_env.virtual_sequencer;

    tb_env.tb_cfg = tb_cfg;

    tb_env.vip_axi4s_config_slv.set_tready_back_pressure_enabled(tready_back_pressure_enabled);
    tb_env.vip_axi4s_config_slv.configure_tready_parameters(
      min_tready_deasserted_time,
      max_tready_deasserted_time,
      min_tready_deasserted_period,
      max_tready_deasserted_period
    );

  endfunction

endclass
