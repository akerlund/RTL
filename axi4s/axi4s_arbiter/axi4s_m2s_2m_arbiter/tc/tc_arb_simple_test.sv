class tc_arb_simple_test extends arb_base_test;

  //axi4s_random_seq #(vip_axi4s_cfg) random_seq;

  arb_vseq #(vip_axi4s_cfg) arb_vseq0;

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

    arb_vseq0 = new();
    arb_vseq0.nr_of_bursts            = 10;
    arb_vseq0.max_idle_between_bursts = 10;
    arb_vseq0.start(v_sqr);

    phase.drop_objection(this);

  endtask

endclass
