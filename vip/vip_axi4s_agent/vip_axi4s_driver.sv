class vip_axi4s_driver #(
  vip_axi4s_cfg_t vip_cfg = '{default: '0}
  ) extends uvm_driver #(vip_axi4s_item #(vip_cfg));

  protected virtual vip_axi4s_if #(vip_cfg) vif;

  protected int    id;
  vip_axi4s_config cfg;


  `uvm_component_param_utils_begin(vip_axi4s_driver #(vip_cfg))
    `uvm_field_int(id, UVM_DEFAULT)
  `uvm_component_utils_end



  function new (string name, uvm_component parent);
    super.new(name, parent);
  endfunction



  function void build_phase(uvm_phase phase);

    super.build_phase(phase);

    if (!uvm_config_db #(virtual vip_axi4s_if #(vip_cfg))::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", {"Virtual interface must be set for: ", get_full_name(), ".vif"});
    end

  endfunction



  virtual task run_phase(uvm_phase phase);

    fork
      reset_signals();
      if (cfg.vip_axi4s_agent_type == VIP_AXI4S_MASTER_AGENT_E) begin
        master_drive();
      end
      else begin
        slave_drive();
      end
    join

  endtask



  virtual protected task reset_signals();

    forever begin

      @(negedge vif.rst_n);

      if (cfg.vip_axi4s_agent_type == VIP_AXI4S_MASTER_AGENT_E) begin
        vif.tvalid <= '0;
        vif.tdata  <= '0;
        vif.tstrb  <= '0;
        vif.tkeep  <= '0;
        vif.tlast  <= '0;
        vif.tid    <= '0;
        vif.tdest  <= '0;
        vif.tuser  <= '0;
      end
      else begin
        vif.tready <= '0;
      end
    end

  endtask



  virtual protected task master_drive();

    @(negedge vif.rst_n);
    @(posedge vif.rst_n);

    `uvm_info(get_type_name(), $sformatf("Reset asserted"), UVM_HIGH)

    forever begin

      @(posedge vif.clk);

      seq_item_port.try_next_item(req);

      if (req != null) begin

        drive_axi4s_item();
        seq_item_port.item_done();

      end
      else begin

        vif.tvalid <= '0;

      end

    end

  endtask



  virtual protected task slave_drive();

    @(negedge vif.rst_n);
    @(posedge vif.rst_n);

    `uvm_info(get_type_name(), $sformatf("Reset asserted"), UVM_HIGH)

    forever begin

      @(posedge vif.clk);

      vif.tready <= '1;

      @(posedge vif.clk);

      // Wait for handshake
      while(!(vif.tvalid && vif.tlast)) begin
        @(posedge vif.clk);
      end

      vif.tready <= '0;

    end

  endtask



  virtual protected task drive_axi4s_item();

    int transfer_counter = 0;
    int burst_length     = req.tdata.size();

    vif.tvalid <= '1;
    vif.tlast  <= '0;
    vif.tid    <= req.tid;
    vif.tdest  <= req.tdest;

    while (transfer_counter != burst_length) begin

      vif.tdata <= req.tdata[transfer_counter];
      vif.tstrb <= req.tstrb[transfer_counter];
      vif.tkeep <= req.tkeep[transfer_counter];
      vif.tuser <= req.tuser[transfer_counter];

      transfer_counter++;

      if (transfer_counter == burst_length) begin
        vif.tlast  <= '1;
      end

      @(posedge vif.clk);

      // Wait for handshake
      while(!vif.tready) begin
        @(posedge vif.clk);
      end

    end

    vif.tvalid <= '0;
    vif.tlast  <= '0;

    @(posedge vif.clk);

  endtask

endclass
