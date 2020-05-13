class vip_axi4s_config extends uvm_object;

  uvm_active_passive_enum is_active = UVM_ACTIVE;


  //----------------------------------------------------------------------------
  // Slave configurations
  //----------------------------------------------------------------------------

  // Back pressure on 'tready'. Time and period are number of clock periods.
  int tready_back_pressure_enabled = 0;

  // Set how long 'tready' can be asserter for back pressure
  int min_tready_deasserted_time = 1;
  int max_tready_deasserted_time = 10;

  // Set the period of when 'tready' is de-asserted
  int min_tready_deasserted_period = 10;
  int max_tready_deasserted_period = AXI4_MAX_BURST_LENGTH_C;



  `uvm_object_utils_begin(vip_axi4s_config);
    `uvm_field_int(tready_back_pressure_enabled, UVM_DEFAULT)
    `uvm_field_int(min_tready_deasserted_time,   UVM_DEFAULT)
    `uvm_field_int(max_tready_deasserted_time,   UVM_DEFAULT)
    `uvm_field_int(min_tready_deasserted_period, UVM_DEFAULT)
    `uvm_field_int(max_tready_deasserted_period, UVM_DEFAULT)
  `uvm_object_utils_end;



  function new(string name = "vip_axi4s_config");
    super.new(name);
  endfunction


  // Enable backpressure on Write Data Channel
  function void set_tready_back_pressure_enabled(int enabled);
    this.tready_back_pressure_enabled = enabled;
  endfunction


  // Parameters for stimulating 'tready'
  function void configure_tready_parameters(
    int min_tready_deasserted_time,
    int max_tready_deasserted_time,
    int min_tready_deasserted_period,
    int max_tready_deasserted_period);

    this.min_tready_deasserted_time   = min_tready_deasserted_time;
    this.max_tready_deasserted_time   = max_tready_deasserted_time;
    this.min_tready_deasserted_period = min_tready_deasserted_period;
    this.max_tready_deasserted_period = max_tready_deasserted_period;
  endfunction


endclass
