////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//
// Description:
//
////////////////////////////////////////////////////////////////////////////////

import uvm_pkg::*;
import arb_tb_pkg::*;
import arb_tc_pkg::*;

module arb_tb_top;

  bit clk;
  bit rst_n;

  time clk_period = 10ns;

  // IF
  vip_axi4s_if #(vip_axi4s_cfg) mst0_vif(clk, rst_n);
  vip_axi4s_if #(vip_axi4s_cfg) mst1_vif(clk, rst_n);
  vip_axi4s_if #(vip_axi4s_cfg) slv0_vif(clk, rst_n);



  axi4s_s2m_2m_arbiter #(

    .AXI_DATA_WIDTH_P ( vip_axi4s_cfg.AXI_DATA_WIDTH_P ),
    .AXI_STRB_WIDTH_P ( vip_axi4s_cfg.AXI_STRB_WIDTH_P ),
    .AXI_KEEP_WIDTH_P ( vip_axi4s_cfg.AXI_KEEP_WIDTH_P ),
    .AXI_ID_WIDTH_P   ( vip_axi4s_cfg.AXI_ID_WIDTH_P   ),
    .AXI_DEST_WIDTH_P ( vip_axi4s_cfg.AXI_DEST_WIDTH_P ),
    .AXI_USER_WIDTH_P ( vip_axi4s_cfg.AXI_USER_WIDTH_P ),
    .MASTER0_TID_P    ( 0                              ),
    .MASTER1_TID_P    ( 1                              )

  ) axi4s_s2m_2m_arbiter_i0 (

    // Clock and reset
    .clk              ( clk                            ), // input
    .rst_n            ( rst_n                          ), // input

    // Ingress 0
    .slv_tvalid       ( slv0_vif.tvalid                ), // input
    .slv_tready       ( slv0_vif.tready                ), // output
    .slv_tdata        ( slv0_vif.tdata                 ), // input
    .slv_tstrb        ( slv0_vif.tstrb                 ), // input
    .slv_tkeep        ( slv0_vif.tkeep                 ), // input
    .slv_tlast        ( slv0_vif.tlast                 ), // input
    .slv_tid          ( slv0_vif.tid                   ), // input
    .slv_tdest        ( slv0_vif.tdest                 ), // input
    .slv_tuser        ( slv0_vif.tuser                 ), // input

    // Ingress 1
    .mst0_tvalid      ( mst0_vif.tvalid                ), // input
    .mst0_tready      ( mst0_vif.tready                ), // output
    .mst0_tdata       ( mst0_vif.tdata                 ), // input
    .mst0_tstrb       ( mst0_vif.tstrb                 ), // input
    .mst0_tkeep       ( mst0_vif.tkeep                 ), // input
    .mst0_tlast       ( mst0_vif.tlast                 ), // input
    .mst0_tid         ( mst0_vif.tid                   ), // input
    .mst0_tdest       ( mst0_vif.tdest                 ), // input
    .mst0_tuser       ( mst0_vif.tuser                 ), // input

    // Egress
    .mst1_tvalid      ( mst1_vif.tvalid                ), // output
    .mst1_tready      ( mst1_vif.tready                ), // input
    .mst1_tdata       ( mst1_vif.tdata                 ), // output
    .mst1_tstrb       ( mst1_vif.tstrb                 ), // output
    .mst1_tkeep       ( mst1_vif.tkeep                 ), // output
    .mst1_tlast       ( mst1_vif.tlast                 ), // output
    .mst1_tid         ( mst1_vif.tid                   ), // output
    .mst1_tdest       ( mst1_vif.tdest                 ), // output
    .mst1_tuser       ( mst1_vif.tuser                 )  // output
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
