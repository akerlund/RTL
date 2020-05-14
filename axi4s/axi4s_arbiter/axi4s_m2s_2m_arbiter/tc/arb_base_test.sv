class arb_base_test extends uvm_test;

  `uvm_component_utils(arb_base_test)

  arb_env               tb_env;
  arb_config            tb_cfg;

  arb_virtual_sequencer v_sqr;

  uvm_table_printer printer;

  function new(string name = "arb_base_test", uvm_component parent = null);

    super.new(name, parent);

  endfunction



  virtual function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    printer = new();
    printer.knobs.depth = 3;

    uvm_config_db #(uvm_verbosity)::set(this, "*", "recording_detail", UVM_FULL);

    tb_env = arb_env::type_id::create("tb_env", this);

    tb_cfg = arb_config::type_id::create("tb_cfg", this);

  endfunction



  function void end_of_elaboration_phase(uvm_phase phase);

    `uvm_info(get_type_name(), $sformatf("Topology of the test:\n%s", this.sprint(printer)), UVM_LOW)
    v_sqr = tb_env.virtual_sequencer;

    tb_env.tb_cfg = tb_cfg;

  endfunction

endclass
