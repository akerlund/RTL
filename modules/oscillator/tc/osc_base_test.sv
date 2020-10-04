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

class osc_base_test extends uvm_test;

  `uvm_component_utils(osc_base_test)

  osc_env               tb_env;
  osc_config            tb_cfg;
  osc_virtual_sequencer v_sqr;
  uvm_table_printer     printer;

  // Oscillator parameters
  real                osc_f;
  real                osc_duty_cycle;
  osc_waveform_type_t osc_waveform_type;


  function new(string name = "osc_base_test", uvm_component parent = null);

    super.new(name, parent);

  endfunction



  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    printer = new();
    printer.knobs.depth = 3;

    uvm_config_db #(uvm_verbosity)::set(this, "*", "recording_detail", UVM_FULL);

    tb_env = osc_env::type_id::create("tb_env", this);

    tb_cfg = osc_config::type_id::create("tb_cfg", this);

  endfunction



  function void end_of_elaboration_phase(uvm_phase phase);

    `uvm_info(get_type_name(), $sformatf("Topology of the test:\n%s", this.sprint(printer)), UVM_LOW)
    v_sqr = tb_env.virtual_sequencer;

    tb_env.tb_cfg = tb_cfg;

  endfunction

endclass