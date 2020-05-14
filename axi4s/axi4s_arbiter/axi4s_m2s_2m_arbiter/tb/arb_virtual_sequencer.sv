class arb_virtual_sequencer extends uvm_virtual_sequencer;

  `uvm_component_utils(arb_virtual_sequencer)

  vip_axi4s_sequencer #(vip_axi4s_cfg) mst0_sequencer;
  vip_axi4s_sequencer #(vip_axi4s_cfg) mst1_sequencer;
  vip_axi4s_sequencer #(vip_axi4s_cfg) slv0_sequencer;

  function new(string name = "virtual_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass