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

class awa_base_test extends uvm_test;

  `uvm_component_utils(awa_base_test)

  // ---------------------------------------------------------------------------
  // UVM variables
  // ---------------------------------------------------------------------------

  uvm_table_printer uvm_table_printer0;
  report_server     report_server0;

  // ---------------------------------------------------------------------------
  // Testbench variables
  // ---------------------------------------------------------------------------

  awa_env               tb_env;
  awa_virtual_sequencer v_sqr;

  // ---------------------------------------------------------------------------
  // VIP Agent configurations
  // ---------------------------------------------------------------------------

  clk_rst_config  clk_rst_config0;
  vip_axi4_config axi4_mem_cfg0;
  vip_axi4_config axi4_wr_cfg0;
  vip_axi4_config axi4_wr_cfg1;
  vip_axi4_config axi4_wr_cfg2;

  // ---------------------------------------------------------------------------
  // Sequences
  // ---------------------------------------------------------------------------

  reset_sequence     reset_seq0;
  vip_axi4_write_seq vip_axi4_write_seq0;
  vip_axi4_write_seq vip_axi4_write_seq1;
  vip_axi4_write_seq vip_axi4_write_seq2;

  function new(string name = "awa_base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction


  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    // UVM
    uvm_config_db #(uvm_verbosity)::set(this, "*", "recording_detail", UVM_FULL);

    report_server0 = new("report_server0");
    uvm_report_server::set_server(report_server0);

    uvm_table_printer0                     = new();
    uvm_table_printer0.knobs.depth         = 3;
    uvm_table_printer0.knobs.default_radix = UVM_DEC;

    // Environment
    tb_env = awa_env::type_id::create("tb_env", this);

    // Configurations
    clk_rst_config0 = clk_rst_config::type_id::create("clk_rst_config0", this);
    axi4_mem_cfg0   = vip_axi4_config::type_id::create("axi4_mem_cfg0",  this);
    axi4_wr_cfg0    = vip_axi4_config::type_id::create("axi4_wr_cfg0",   this);
    axi4_wr_cfg1    = vip_axi4_config::type_id::create("axi4_wr_cfg1",   this);
    axi4_wr_cfg2    = vip_axi4_config::type_id::create("axi4_wr_cfg2",   this);

    axi4_mem_cfg0.vip_axi4_agent_type     = VIP_AXI4_SLAVE_AGENT_E;
    axi4_mem_cfg0.mem_slave               = TRUE;
    axi4_mem_cfg0.mem_addr_width          = VIP_AXI4_CFG_C.VIP_AXI4_ADDR_WIDTH_P;
    axi4_mem_cfg0.min_wready_delay_period = 10;
    axi4_mem_cfg0.max_wready_delay_period = 256;

    axi4_wr_cfg0.min_wvalid_delay_period = 10;
    axi4_wr_cfg0.max_wvalid_delay_period = 10;
    axi4_wr_cfg1.min_wvalid_delay_period = 10;
    axi4_wr_cfg1.max_wvalid_delay_period = 10;
    axi4_wr_cfg2.min_wvalid_delay_period = 10;
    axi4_wr_cfg2.max_wvalid_delay_period = 10;

    uvm_config_db #(clk_rst_config)::set(this,  {"tb_env.clk_rst_agent0", "*"}, "cfg", clk_rst_config0);
    uvm_config_db #(vip_axi4_config)::set(this, {"tb_env.mem_agent0",     "*"}, "cfg", axi4_mem_cfg0);
    uvm_config_db #(vip_axi4_config)::set(this, {"tb_env.wr_agent0",      "*"}, "cfg", axi4_wr_cfg0);
    uvm_config_db #(vip_axi4_config)::set(this, {"tb_env.wr_agent1",      "*"}, "cfg", axi4_wr_cfg1);
    uvm_config_db #(vip_axi4_config)::set(this, {"tb_env.wr_agent2",      "*"}, "cfg", axi4_wr_cfg2);

  endfunction


  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    v_sqr = tb_env.virtual_sequencer;
    `uvm_info(get_name(), {"VIP AXI4 Agent (Write0):\n",  axi4_wr_cfg0.sprint()}, UVM_LOW)
    `uvm_info(get_name(), {"VIP AXI4 Agent (Memory):\n", axi4_mem_cfg0.sprint()}, UVM_LOW)
  endfunction


  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    reset_seq0          = reset_sequence::type_id::create("reset_seq0");
    vip_axi4_write_seq0 = vip_axi4_write_seq::type_id::create("vip_axi4_write_seq0");
    vip_axi4_write_seq1 = vip_axi4_write_seq::type_id::create("vip_axi4_write_seq1");
    vip_axi4_write_seq2 = vip_axi4_write_seq::type_id::create("vip_axi4_write_seq2");
  endfunction


  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    phase.raise_objection(this);
    clk_delay(8);
    reset_seq0.start(v_sqr.clk_rst_sequencer0);
    phase.drop_objection(this);
  endtask


  task clk_delay(int delay);
    #(delay*clk_rst_config0.clock_period);
  endtask

endclass
