class arb_env extends uvm_env;

  `uvm_component_utils_begin(arb_env)
  `uvm_component_utils_end

  // Agents
  vip_axi4s_agent #(vip_axi4s_cfg) vip_axi4s_agent_mst0;
  vip_axi4s_agent #(vip_axi4s_cfg) vip_axi4s_agent_mst1;
  vip_axi4s_agent #(vip_axi4s_cfg) vip_axi4s_agent_slv0;

  // Agent configurations
  vip_axi4s_config vip_axi4s_config_mst;
  vip_axi4s_config vip_axi4s_config_slv;

  // The block configuration, e.g., clk period, reset time
  arb_config tb_cfg;

  // Scoreboard
  arb_scoreboard scoreboard0;

  // Virtual sequencer, i.e., a collection of agent sequencers
  arb_virtual_sequencer virtual_sequencer;



  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction



  function void build_phase(uvm_phase phase);

    super.build_phase(phase);


    if (tb_cfg == null) begin
      `uvm_info(get_type_name(), "No testbench configuration. Creating a new", UVM_LOW)
      tb_cfg = arb_config::type_id::create("tb_cfg", this);
      void'(uvm_config_db #(arb_config)::get(this, "", "tb_cfg", tb_cfg));
    end

    `uvm_info(get_type_name(), {"Configuration:\n", tb_cfg.sprint()}, UVM_LOW)

    // Configurations
    vip_axi4s_config_mst = vip_axi4s_config::type_id::create("vip_axi4s_config_mst", this);
    vip_axi4s_config_slv = vip_axi4s_config::type_id::create("vip_axi4s_config_slv", this);
    vip_axi4s_config_slv.vip_axi4s_agent_type = VIP_AXI4S_SLAVE_AGENT_E;

    // Create Agents
    vip_axi4s_agent_mst0 = vip_axi4s_agent #(vip_axi4s_cfg)::type_id::create("vip_axi4s_agent_mst0", this);
    vip_axi4s_agent_mst1 = vip_axi4s_agent #(vip_axi4s_cfg)::type_id::create("vip_axi4s_agent_mst1", this);
    vip_axi4s_agent_slv0 = vip_axi4s_agent #(vip_axi4s_cfg)::type_id::create("vip_axi4s_agent_slv0", this);

    uvm_config_db #(int)::set(this, {"vip_axi4s_agent_mst0", "*"}, "id", 0);
    uvm_config_db #(int)::set(this, {"vip_axi4s_agent_mst1", "*"}, "id", 1);
    uvm_config_db #(int)::set(this, {"vip_axi4s_agent_slv0", "*"}, "id", 2);

    uvm_config_db #(vip_axi4s_config)::set(this, {"vip_axi4s_agent_mst0", "*"}, "cfg", vip_axi4s_config_mst);
    uvm_config_db #(vip_axi4s_config)::set(this, {"vip_axi4s_agent_mst1", "*"}, "cfg", vip_axi4s_config_mst);
    uvm_config_db #(vip_axi4s_config)::set(this, {"vip_axi4s_agent_slv0", "*"}, "cfg", vip_axi4s_config_slv);

    // Create Scoreboards
    scoreboard0 = arb_scoreboard::type_id::create("scoreboard0", this);

    // Create Virtual Sequencer
    virtual_sequencer = arb_virtual_sequencer::type_id::create("virtual_sequencer", this);
    uvm_config_db #(arb_virtual_sequencer)::set(this, {"virtual_sequencer", "*"}, "virtual_sequencer", virtual_sequencer);

  endfunction



  function void connect_phase(uvm_phase phase);

    super.connect_phase(phase);

    vip_axi4s_agent_mst0.monitor.collected_port.connect(scoreboard0.collected_port_mst0);
    vip_axi4s_agent_mst1.monitor.collected_port.connect(scoreboard0.collected_port_mst1);
    vip_axi4s_agent_slv0.monitor.collected_port.connect(scoreboard0.collected_port_slv0);

    virtual_sequencer.mst0_sequencer = vip_axi4s_agent_mst0.sequencer;
    virtual_sequencer.mst1_sequencer = vip_axi4s_agent_mst1.sequencer;
    virtual_sequencer.slv0_sequencer = vip_axi4s_agent_slv0.sequencer;

  endfunction

endclass
