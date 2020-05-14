class tc_arb_simple_test extends arb_base_test;

  axi4s_random_seq #(vip_axi4s_cfg) random_seq;

  `uvm_component_utils(tc_arb_simple_test)



  function new(string name = "tc_arb_simple_test", uvm_component parent = null);

    super.new(name, parent);

  endfunction



  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

  endfunction



  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);

    random_seq = new();
    random_seq.start(v_sqr.mst0_sequencer);

    phase.drop_objection(this);

  endtask

endclass
