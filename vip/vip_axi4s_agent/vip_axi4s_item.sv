class vip_axi4s_item #(
  vip_axi4s_cfg_t cfg = '{default: '0}
  ) extends uvm_sequence_item;

  // ---------------------------------------------------------------------------
  // AXI4-S signals
  // ---------------------------------------------------------------------------

  rand logic [cfg.AXI_DATA_WIDTH_P-1 : 0] tdata [];
       logic [cfg.AXI_STRB_WIDTH_P-1 : 0] tstrb [];
       logic [cfg.AXI_KEEP_WIDTH_P-1 : 0] tkeep [];
  rand logic   [cfg.AXI_ID_WIDTH_P-1 : 0] tid       = '0;
  rand logic [cfg.AXI_DEST_WIDTH_P-1 : 0] tdest     = '0;
       logic [cfg.AXI_USER_WIDTH_P-1 : 0] tuser [];

  // ---------------------------------------------------------------------------
  // Constraints
  // ---------------------------------------------------------------------------

  //constraint con_name {}


  `uvm_object_param_utils_begin(vip_axi4s_item #(cfg))
    `uvm_field_int(tid,          UVM_DEFAULT)
    `uvm_field_int(tdest,        UVM_DEFAULT)
    `uvm_field_sarray_int(tdata, UVM_DEFAULT)
    `uvm_field_sarray_int(tstrb, UVM_DEFAULT)
    `uvm_field_sarray_int(tkeep, UVM_DEFAULT)
    `uvm_field_sarray_int(tuser, UVM_DEFAULT)
  `uvm_object_utils_end


  function new(string name = "vip_axi4s_item");

    super.new(name);

  endfunction


  function void pre_randomize();

    int burst_size = $urandom_range(1, AXI4S_MAX_BURST_LENGTH_C);

    tdata = new[burst_size];
    tstrb = new[burst_size];
    tkeep = new[burst_size];
    tuser = new[burst_size];

    foreach (tstrb[i]) begin
      tkeep[i] = '1;
    end

    foreach (tuser[i]) begin
      tuser[i] = '0;
    end

  endfunction

endclass
