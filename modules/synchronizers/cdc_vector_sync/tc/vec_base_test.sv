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

class vec_base_test extends uvm_test;

  `uvm_component_utils(vec_base_test)

  // ---------------------------------------------------------------------------
  // UVM variables
  // ---------------------------------------------------------------------------

  uvm_table_printer printer;

  // ---------------------------------------------------------------------------
  // Testbench variables
  // ---------------------------------------------------------------------------

  vec_env               tb_env;
  vec_virtual_sequencer v_sqr;

  // ---------------------------------------------------------------------------
  // VIP Agent configurations
  // ---------------------------------------------------------------------------

  clk_rst_config   clk_rst_config0;
  clk_rst_config   clk_rst_config1;
  vip_axi4s_config vip_axi4s_config_mst;
  vip_axi4s_config vip_axi4s_config_slv;

  // ---------------------------------------------------------------------------
  // Sequences
  // ---------------------------------------------------------------------------
  reset_sequence              reset_sequence0;
  reset_sequence              reset_sequence1;
  vip_axi4s_seq  #(VIP_AXI4S_CFG_C) vip_axi4s_seq0;

  // ---------------------------------------------------------------------------
  // Variables for sequences
  // ---------------------------------------------------------------------------

  int nr_of_bursts;


  function new(string name = "vec_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    // UVM
    printer = new();
    printer.knobs.depth = 3;

    // Environment
    tb_env = vec_env::type_id::create("tb_env", this);

    // Configurations
    clk_rst_config0      = clk_rst_config::type_id::create("clk_rst_config0", this);
    clk_rst_config1      = clk_rst_config::type_id::create("clk_rst_config1", this);
    vip_axi4s_config_mst = vip_axi4s_config::type_id::create("vip_axi4s_config_mst", this);
    vip_axi4s_config_slv = vip_axi4s_config::type_id::create("vip_axi4s_config_slv", this);

    vip_axi4s_config_slv.vip_axi4s_agent_type = VIP_AXI4S_SLAVE_AGENT_E;

    uvm_config_db #(clk_rst_config)::set(this,   {"tb_env.clk_rst_agent0",       "*"}, "cfg", clk_rst_config0);
    uvm_config_db #(clk_rst_config)::set(this,   {"tb_env.clk_rst_agent1",       "*"}, "cfg", clk_rst_config1);
    uvm_config_db #(vip_axi4s_config)::set(this, {"tb_env.vip_axi4s_agent_mst0", "*"}, "cfg", vip_axi4s_config_mst);
    uvm_config_db #(vip_axi4s_config)::set(this, {"tb_env.vip_axi4s_agent_slv0", "*"}, "cfg", vip_axi4s_config_slv);

  endfunction



  function void end_of_elaboration_phase(uvm_phase phase);

    super.end_of_elaboration_phase(phase);

    v_sqr = tb_env.virtual_sequencer;

    `uvm_info(get_name(), $sformatf("Topology of the test:\n%s", this.sprint(printer)), UVM_LOW)

    `uvm_info(get_name(), {"Clock and Reset Agent 0:\n", clk_rst_config0.sprint()},      UVM_LOW)
    `uvm_info(get_name(), {"Clock and Reset Agent 1:\n", clk_rst_config1.sprint()},      UVM_LOW)
    `uvm_info(get_name(), {"VIP Master Agent:\n",        vip_axi4s_config_mst.sprint()}, UVM_LOW)
    `uvm_info(get_name(), {"VIP Slave Agent:\n",         vip_axi4s_config_slv.sprint()}, UVM_LOW)
  endfunction


  function void start_of_simulation_phase(uvm_phase phase);

    super.start_of_simulation_phase(phase);

    reset_sequence0 = reset_sequence::type_id::create("reset_sequence0");
    reset_sequence1 = reset_sequence::type_id::create("reset_sequence1");
    vip_axi4s_seq0  = vip_axi4s_seq #(VIP_AXI4S_CFG_C)::type_id::create("vip_axi4s_seq0");
  endfunction


  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);

    fork
      reset_sequence0.start(v_sqr.clk_rst_sequencer0);
      reset_sequence1.start(v_sqr.clk_rst_sequencer1);
    join

    phase.drop_objection(this);
  endtask

endclass
