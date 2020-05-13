class vip_axi4s_sequencer #(
  vip_vip_axi4s_cfg_t vip_cfg = '{default: '0}
  ) extends uvm_sequencer #(vip_axi4s_item #(vip_cfg));

  `uvm_component_param_utils(vip_axi4s_sequencer #(vip_cfg));

  vip_axi4s_config cfg;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

endclass
