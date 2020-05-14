class arb_vseq #(
  vip_axi4s_cfg_t vip_cfg = '{default: '0}
  ) extends uvm_sequence #(vip_axi4s_item #(vip_cfg));

  `uvm_object_param_utils(arb_vseq #(vip_cfg))
  `uvm_declare_p_sequencer(arb_virtual_sequencer)

  axi4s_random_seq #(vip_cfg) random_seq0;
  axi4s_random_seq #(vip_cfg) random_seq1;

  int nr_of_bursts            = -1;
  int max_idle_between_bursts = -1;

  function new(string name = "arb_vseq");

    super.new(name);

  endfunction


  virtual task body();

    random_seq0 = axi4s_random_seq #(vip_cfg)::type_id::create("random_seq0");
    random_seq1 = axi4s_random_seq #(vip_cfg)::type_id::create("random_seq1");

    random_seq0.nr_of_bursts = nr_of_bursts;
    random_seq1.nr_of_bursts = nr_of_bursts;

    random_seq0.max_idle_between_bursts = max_idle_between_bursts;
    random_seq1.max_idle_between_bursts = max_idle_between_bursts;

    `uvm_info(get_name(), $sformatf("Starting two sequences"), UVM_LOW);

    fork
      random_seq0.start(p_sequencer.mst0_sequencer);
      random_seq1.start(p_sequencer.mst1_sequencer);
    join

  endtask

endclass
