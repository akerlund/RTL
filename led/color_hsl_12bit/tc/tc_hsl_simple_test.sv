class tc_hsl_simple_test extends hsl_base_test;

  hsl_12bit_seq #(vip_axi4s_cfg) hsl_12bit_seq0;

  `uvm_component_utils(tc_hsl_simple_test)



  function new(string name = "tc_hsl_simple_test", uvm_component parent = null);

    super.new(name, parent);

  endfunction



  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

  endfunction



  task run_phase(uvm_phase phase);

    super.run_phase(phase);
    phase.raise_objection(this);

    hsl_12bit_seq0 = new();
    hsl_12bit_seq0.nr_of_bursts = 10;
    hsl_12bit_seq0.start(v_sqr.mst0_sequencer);

    phase.drop_objection(this);

  endtask

endclass
