module arb_tb_top;

  import uvm_pkg::*;

  import arb_tb_pkg::*;
  import arb_tc_pkg::*;

  bit clk;
  bit rst_n;

  time clk_period = 10ns;

  // IF
  vip_axi4s_if #(vip_axi4s_cfg) mst0_vif(clk, rst_n);
  vip_axi4s_if #(vip_axi4s_cfg) mst1_vif(clk, rst_n);
  vip_axi4s_if #(vip_axi4s_cfg) slv0_vif(clk, rst_n);

  axi4s_m2s_2m_arbiter #(

    .AXI_DATA_WIDTH_P ( vip_axi4s_cfg.AXI_DATA_WIDTH_P ),
    .AXI_STRB_WIDTH_P ( vip_axi4s_cfg.AXI_STRB_WIDTH_P ),
    .AXI_KEEP_WIDTH_P ( vip_axi4s_cfg.AXI_KEEP_WIDTH_P ),
    .AXI_ID_WIDTH_P   ( vip_axi4s_cfg.AXI_ID_WIDTH_P   ),
    .AXI_DEST_WIDTH_P ( vip_axi4s_cfg.AXI_DEST_WIDTH_P ),
    .AXI_USER_WIDTH_P ( vip_axi4s_cfg.AXI_USER_WIDTH_P )

  ) axi4s_m2s_2m_arbiter_i0 (

    // Clock and reset
    .clk              ( clk                            ), // input
    .rst_n            ( rst_n                          ), // input

    // Ingress 0
    .ing0_tvalid      ( mst0_vif.tvalid                ), // input
    .ing0_tready      ( mst0_vif.tready                ), // output
    .ing0_tdata       ( mst0_vif.tdata                 ), // input
    .ing0_tstrb       ( mst0_vif.tstrb                 ), // input
    .ing0_tkeep       ( mst0_vif.tkeep                 ), // input
    .ing0_tlast       ( mst0_vif.tlast                 ), // input
    .ing0_tid         ( mst0_vif.tid                   ), // input
    .ing0_tdest       ( mst0_vif.tdest                 ), // input
    .ing0_tuser       ( mst0_vif.tuser                 ), // input

    // Ingress 1
    .ing1_tvalid      ( mst1_vif.tvalid                ), // input
    .ing1_tready      ( mst1_vif.tready                ), // output
    .ing1_tdata       ( mst1_vif.tdata                 ), // input
    .ing1_tstrb       ( mst1_vif.tstrb                 ), // input
    .ing1_tkeep       ( mst1_vif.tkeep                 ), // input
    .ing1_tlast       ( mst1_vif.tlast                 ), // input
    .ing1_tid         ( mst1_vif.tid                   ), // input
    .ing1_tdest       ( mst1_vif.tdest                 ), // input
    .ing1_tuser       ( mst1_vif.tuser                 ), // input

    // Egress
    .egr_tvalid       ( slv0_vif.tvalid                ), // output
    .egr_tready       ( slv0_vif.tready                ), // input
    .egr_tdata        ( slv0_vif.tdata                 ), // output
    .egr_tstrb        ( slv0_vif.tstrb                 ), // output
    .egr_tkeep        ( slv0_vif.tkeep                 ), // output
    .egr_tlast        ( slv0_vif.tlast                 ), // output
    .egr_tid          ( slv0_vif.tid                   ), // output
    .egr_tdest        ( slv0_vif.tdest                 ), // output
    .egr_tuser        ( slv0_vif.tuser                 )  // output
  );

  initial begin

    uvm_config_db #(virtual vip_axi4s_if #(vip_axi4s_cfg))::set(uvm_root::get(), "uvm_test_top.tb_env.vip_axi4s_agent_mst0*", "vif", mst0_vif);
    uvm_config_db #(virtual vip_axi4s_if #(vip_axi4s_cfg))::set(uvm_root::get(), "uvm_test_top.tb_env.vip_axi4s_agent_mst1*", "vif", mst1_vif);
    uvm_config_db #(virtual vip_axi4s_if #(vip_axi4s_cfg))::set(uvm_root::get(), "uvm_test_top.tb_env.vip_axi4s_agent_slv0*", "vif", slv0_vif);

    run_test();
    $stop();

  end



  initial begin

    // With recording detail you can switch on/off transaction recording.
    if ($test$plusargs("RECORD")) begin
      uvm_config_db #(uvm_verbosity)::set(null,"*", "recording_detail", UVM_FULL);
    end
    else begin
      uvm_config_db #(uvm_verbosity)::set(null,"*", "recording_detail", UVM_NONE);
    end
  end


  // Generate reset
  initial begin

    rst_n = 1'b1;

    #(clk_period*5)

    rst_n = 1'b0;

    #(clk_period*5)

    @(posedge clk);

    rst_n = 1'b1;

  end

  // Generate clock
  always begin
    #(clk_period/2)
    clk = ~clk;
  end

endmodule
