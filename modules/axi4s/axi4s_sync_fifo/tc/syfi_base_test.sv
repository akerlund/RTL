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
  // Agent configurations
  //----------------------------------------------------------------------------

  clk_rst_config   clk_rst_config0;
  vip_axi4s_config vip_axi4s_config_mst;
  vip_axi4s_config vip_axi4s_config_slv;


  // Back pressure on 'tready'. Time and period are number of clock periods.
  int tready_back_pressure_enabled = 0;

  // Set how long 'tready' can be asserter for back pressure
  int min_tready_deasserted_time = 1;
  int max_tready_deasserted_time = 10;

  // Set the period of when 'tready' is de-asserted
  int min_tready_deasserted_period = 10;
  int max_tready_deasserted_period = 55;

  reset_sequence reset_sequence0;

  function new(string name = "syfi_base_test", uvm_component parent = null);

    super.new(name, parent);

  endfunction



  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    printer = new();
    printer.knobs.depth = 3;

    uvm_config_db #(uvm_verbosity)::set(this, "*", "recording_detail", UVM_FULL);

    tb_env = syfi_env::type_id::create("tb_env", this);

    // Configurations
    tb_cfg               = syfi_config::type_id::create("tb_cfg", this);
    clk_rst_config0      = clk_rst_config::type_id::create("clk_rst_config0", this);
    vip_axi4s_config_mst = vip_axi4s_config::type_id::create("vip_axi4s_config_mst", this);
    vip_axi4s_config_slv = vip_axi4s_config::type_id::create("vip_axi4s_config_slv", this);
    vip_axi4s_config_slv.vip_axi4s_agent_type = VIP_AXI4S_SLAVE_AGENT_E;

    uvm_config_db #(clk_rst_config)::set(this,   {"tb_env.clk_rst_agent0",       "*"}, "cfg", clk_rst_config0);
    uvm_config_db #(vip_axi4s_config)::set(this, {"tb_env.vip_axi4s_agent_mst0", "*"}, "cfg", vip_axi4s_config_mst);
    uvm_config_db #(vip_axi4s_config)::set(this, {"tb_env.vip_axi4s_agent_slv0", "*"}, "cfg", vip_axi4s_config_slv);

  endfunction



  function void end_of_elaboration_phase(uvm_phase phase);

    `uvm_info(get_type_name(), $sformatf("Topology of the test:\n%s", this.sprint(printer)), UVM_LOW)
    v_sqr = tb_env.virtual_sequencer;

    tb_env.tb_cfg = tb_cfg;

    `uvm_info(get_name(), {"Clock and Reset Agent:\n", clk_rst_config0.sprint()},      UVM_LOW)
    `uvm_info(get_name(), {"AXI4S Master:\n",          vip_axi4s_config_mst.sprint()}, UVM_LOW)
    `uvm_info(get_name(), {"AXI4S Slave:\n",           vip_axi4s_config_slv.sprint()}, UVM_LOW)

  endfunction



  task run_phase(uvm_phase phase);

    super.run_phase(phase);

    phase.raise_objection(this);

    // Resetting the DUT
    reset_sequence0 = reset_sequence::type_id::create("reset_sequence0");
    reset_sequence0.start(v_sqr.clk_rst_sequencer0);

    phase.drop_objection(this);

  endtask



endclass
