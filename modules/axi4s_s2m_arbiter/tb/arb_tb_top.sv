////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
// https://github.com/akerlund/RTL
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

  // IF
  clk_rst_if                      clk_rst_vif();
  vip_axi4s_if #(VIP_AXI4S_CFG_C) mst0_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);
  vip_axi4s_if #(VIP_AXI4S_CFG_C) mst1_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);
  vip_axi4s_if #(VIP_AXI4S_CFG_C) mst2_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);
  vip_axi4s_if #(VIP_AXI4S_CFG_C) slv0_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);

  localparam int AXI_DATA_WIDTH_C = VIP_AXI4S_CFG_C.VIP_AXI4S_TDATA_WIDTH_P;
  localparam int AXI_STRB_WIDTH_C = VIP_AXI4S_CFG_C.VIP_AXI4S_TSTRB_WIDTH_P;
  localparam int AXI_KEEP_WIDTH_C = VIP_AXI4S_CFG_C.VIP_AXI4S_TKEEP_WIDTH_P;
  localparam int AXI_ID_WIDTH_C   = VIP_AXI4S_CFG_C.VIP_AXI4S_TID_WIDTH_P;
  localparam int AXI_DEST_WIDTH_C = VIP_AXI4S_CFG_C.VIP_AXI4S_TDEST_WIDTH_P;
  localparam int AXI_USER_WIDTH_C = VIP_AXI4S_CFG_C.VIP_AXI4S_TUSER_WIDTH_P;

  logic [NR_OF_MASTERS_C-1 : 0]                          mst_tvalid;
  logic [NR_OF_MASTERS_C-1 : 0]                          mst_tready;
  logic                         [AXI_DATA_WIDTH_C-1 : 0] mst_tdata;
  logic                         [AXI_STRB_WIDTH_C-1 : 0] mst_tstrb;
  logic                         [AXI_KEEP_WIDTH_C-1 : 0] mst_tkeep;
  logic                                                  mst_tlast;
  logic                           [AXI_ID_WIDTH_C-1 : 0] mst_tid;
  logic                         [AXI_DEST_WIDTH_C-1 : 0] mst_tdest;
  logic                         [AXI_USER_WIDTH_C-1 : 0] mst_tuser;

  assign mst0_vif.tvalid = mst_tvalid[0];
  assign mst_tready[0]   = mst0_vif.tready;
  assign mst0_vif.tdata  = mst_tdata;
  assign mst0_vif.tstrb  = mst_tstrb;
  assign mst0_vif.tkeep  = mst_tkeep;
  assign mst0_vif.tlast  = mst_tlast;
  assign mst0_vif.tid    = mst_tid;
  assign mst0_vif.tdest  = mst_tdest;
  assign mst0_vif.tuser  = mst_tuser;

  assign mst1_vif.tvalid = mst_tvalid[1];
  assign mst_tready[1]   = mst1_vif.tready;
  assign mst1_vif.tdata  = mst_tdata;
  assign mst1_vif.tstrb  = mst_tstrb;
  assign mst1_vif.tkeep  = mst_tkeep;
  assign mst1_vif.tlast  = mst_tlast;
  assign mst1_vif.tid    = mst_tid;
  assign mst1_vif.tdest  = mst_tdest;
  assign mst1_vif.tuser  = mst_tuser;

  assign mst2_vif.tvalid = mst_tvalid[2];
  assign mst_tready[2]   = mst2_vif.tready;
  assign mst2_vif.tdata  = mst_tdata;
  assign mst2_vif.tstrb  = mst_tstrb;
  assign mst2_vif.tkeep  = mst_tkeep;
  assign mst2_vif.tlast  = mst_tlast;
  assign mst2_vif.tid    = mst_tid;
  assign mst2_vif.tdest  = mst_tdest;
  assign mst2_vif.tuser  = mst_tuser;


  axi4s_s2m_arbiter #(
    .NR_OF_MASTERS_P  ( NR_OF_MASTERS_C   ),
    .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_C  ),
    .AXI_STRB_WIDTH_P ( AXI_STRB_WIDTH_C  ),
    .AXI_KEEP_WIDTH_P ( AXI_KEEP_WIDTH_C  ),
    .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_C    ),
    .AXI_DEST_WIDTH_P ( AXI_DEST_WIDTH_C  ),
    .AXI_USER_WIDTH_P ( AXI_USER_WIDTH_C  )
  ) axi4s_s2m_2m_arbiter_i0 (

    // Clock and reset
    .clk              ( clk_rst_vif.clk   ), // input
    .rst_n            ( clk_rst_vif.rst_n ), // input

    // AXI4-S Slave
    .slv_tvalid       ( slv0_vif.tvalid   ), // input
    .slv_tready       ( slv0_vif.tready   ), // output
    .slv_tdata        ( slv0_vif.tdata    ), // input
    .slv_tstrb        ( slv0_vif.tstrb    ), // input
    .slv_tkeep        ( slv0_vif.tkeep    ), // input
    .slv_tlast        ( slv0_vif.tlast    ), // input
    .slv_tid          ( slv0_vif.tid      ), // input
    .slv_tdest        ( slv0_vif.tdest    ), // input
    .slv_tuser        ( slv0_vif.tuser    ), // input

    // AXI4-S Masters
    .mst_tvalid       ( mst_tvalid        ), // output
    .mst_tready       ( mst_tready        ), // input
    .mst_tdata        ( mst_tdata         ), // output
    .mst_tstrb        ( mst_tstrb         ), // output
    .mst_tkeep        ( mst_tkeep         ), // output
    .mst_tlast        ( mst_tlast         ), // output
    .mst_tid          ( mst_tid           ), // output
    .mst_tdest        ( mst_tdest         ), // output
    .mst_tuser        ( mst_tuser         )  // output
  );


  initial begin
    uvm_config_db #(virtual clk_rst_if)::set(uvm_root::get(),                      "uvm_test_top.tb_env*",                "vif", clk_rst_vif);
    uvm_config_db #(virtual clk_rst_if)::set(uvm_root::get(),                      "uvm_test_top.tb_env.clk_rst_agent0*", "vif", clk_rst_vif);
    uvm_config_db #(virtual vip_axi4s_if #(VIP_AXI4S_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.mst_agent0*",     "vif", mst0_vif);
    uvm_config_db #(virtual vip_axi4s_if #(VIP_AXI4S_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.mst_agent1*",     "vif", mst1_vif);
    uvm_config_db #(virtual vip_axi4s_if #(VIP_AXI4S_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.mst_agent2*",     "vif", mst2_vif);
    uvm_config_db #(virtual vip_axi4s_if #(VIP_AXI4S_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.slv_agent0*",     "vif", slv0_vif);
    run_test();
    $stop();
  end


  initial begin
    $timeformat(-9, 0, "", 11);  // units, precision, suffix, min field width
    if ($test$plusargs("RECORD")) begin
      uvm_config_db #(uvm_verbosity)::set(null,"*", "recording_detail", UVM_FULL);
    end else begin
      uvm_config_db #(uvm_verbosity)::set(null,"*", "recording_detail", UVM_NONE);
    end
  end

endmodule
