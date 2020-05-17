import uvm_pkg::*;
import rt_tb_pkg::*;
import rt_tc_pkg::*;

module rt_tb_top;

  bit clk;
  bit rst_n;

  time clk_period = 10ns;

  // IF
  vip_axi4s_if #(vip_axi4s_cfg) mst0_vif(clk, rst_n);
  vip_axi4s_if #(vip_axi4s_cfg) slv0_vif(clk, rst_n);


  axi4s_retime #(

    .AXI_DATA_WIDTH_P ( vip_axi4s_cfg.AXI_DATA_WIDTH_P ),
    .AXI_STRB_WIDTH_P ( vip_axi4s_cfg.AXI_STRB_WIDTH_P ),
    .AXI_KEEP_WIDTH_P ( vip_axi4s_cfg.AXI_KEEP_WIDTH_P ),
    .AXI_ID_WIDTH_P   ( vip_axi4s_cfg.AXI_ID_WIDTH_P   ),
    .AXI_DEST_WIDTH_P ( vip_axi4s_cfg.AXI_DEST_WIDTH_P ),
    .AXI_USER_WIDTH_P ( vip_axi4s_cfg.AXI_USER_WIDTH_P )

  ) axi4s_retime_i0 (

    // Clock and reset
    .clk              ( clk                            ), // input
    .rst_n            ( rst_n                          ), // input

    // Ingress
    .ing_tvalid       ( mst0_vif.tvalid                ), // input
    .ing_tready       ( mst0_vif.tready                ), // output
    .ing_tdata        ( mst0_vif.tdata                 ), // input
    .ing_tstrb        ( mst0_vif.tstrb                 ), // input
    .ing_tkeep        ( mst0_vif.tkeep                 ), // input
    .ing_tlast        ( mst0_vif.tlast                 ), // input
    .ing_tid          ( mst0_vif.tid                   ), // input
    .ing_tdest        ( mst0_vif.tdest                 ), // input
    .ing_tuser        ( mst0_vif.tuser                 ), // input

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
