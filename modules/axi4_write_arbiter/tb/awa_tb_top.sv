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
import awa_tb_pkg::*;
import awa_tc_pkg::*;

module awa_tb_top;

  // IF
  clk_rst_if                    clk_rst_vif();
  vip_axi4_if #(VIP_AXI4_CFG_C) mst_vif0(clk_rst_vif.clk, clk_rst_vif.rst_n);
  vip_axi4_if #(VIP_AXI4_CFG_C) mst_vif1(clk_rst_vif.clk, clk_rst_vif.rst_n);
  vip_axi4_if #(VIP_AXI4_CFG_C) mst_vif2(clk_rst_vif.clk, clk_rst_vif.rst_n);
  vip_axi4_if #(VIP_AXI4_CFG_C) mem_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);

  localparam int NR_OF_MASTERS_C = 3;

  // Write Address Channel
  logic [0 : NR_OF_MASTERS_C-1]   [VIP_AXI4_CFG_C.VIP_AXI4_ID_WIDTH_P-1 : 0] mst_awid;
  logic [0 : NR_OF_MASTERS_C-1] [VIP_AXI4_CFG_C.VIP_AXI4_ADDR_WIDTH_P-1 : 0] mst_awaddr;
  logic [0 : NR_OF_MASTERS_C-1]                                      [7 : 0] mst_awlen;
  logic [0 : NR_OF_MASTERS_C-1]                                              mst_awvalid;
  logic [0 : NR_OF_MASTERS_C-1]                                              mst_awready;

  // Write Data Channel
  logic [0 : NR_OF_MASTERS_C-1] [VIP_AXI4_CFG_C.VIP_AXI4_DATA_WIDTH_P-1 : 0] mst_wdata;
  logic [0 : NR_OF_MASTERS_C-1] [VIP_AXI4_CFG_C.VIP_AXI4_STRB_WIDTH_P-1 : 0] mst_wstrb;
  logic [0 : NR_OF_MASTERS_C-1]                                              mst_wlast;
  logic [0 : NR_OF_MASTERS_C-1]                                              mst_wvalid;
  logic [0 : NR_OF_MASTERS_C-1]                                              mst_wready;

  // Master 0
  assign mst_awid[0]      = mst_vif0.awid;
  assign mst_awaddr[0]    = mst_vif0.awaddr;
  assign mst_awlen[0]     = mst_vif0.awlen;
  assign mst_awvalid[0]   = mst_vif0.awvalid;
  assign mst_vif0.awready = mst_awready[0];

  assign mst_wdata[0]     = mst_vif0.wdata;
  assign mst_wstrb[0]     = mst_vif0.wstrb;
  assign mst_wlast[0]     = mst_vif0.wlast;
  assign mst_wvalid[0]    = mst_vif0.wvalid;
  assign mst_vif0.wready  = mst_wready[0];

  // Master 1
  assign mst_awid[1]      = mst_vif1.awid;
  assign mst_awaddr[1]    = mst_vif1.awaddr;
  assign mst_awlen[1]     = mst_vif1.awlen;
  assign mst_awvalid[1]   = mst_vif1.awvalid;
  assign mst_vif1.awready = mst_awready[1];

  assign mst_wdata[1]     = mst_vif1.wdata;
  assign mst_wstrb[1]     = mst_vif1.wstrb;
  assign mst_wlast[1]     = mst_vif1.wlast;
  assign mst_wvalid[1]    = mst_vif1.wvalid;
  assign mst_vif1.wready  = mst_wready[1];

  // Master 2
  assign mst_awid[2]      = mst_vif2.awid;
  assign mst_awaddr[2]    = mst_vif2.awaddr;
  assign mst_awlen[2]     = mst_vif2.awlen;
  assign mst_awvalid[2]   = mst_vif2.awvalid;
  assign mst_vif2.awready = mst_awready[2];

  assign mst_wdata[2]     = mst_vif2.wdata;
  assign mst_wstrb[2]     = mst_vif2.wstrb;
  assign mst_wlast[2]     = mst_vif2.wlast;
  assign mst_wvalid[2]    = mst_vif2.wvalid;
  assign mst_vif2.wready  = mst_wready[2];


  // DUT
  axi4_write_arbiter #(

    .AXI_ID_WIDTH_P   ( VIP_AXI4_CFG_C.VIP_AXI4_ID_WIDTH_P   ),
    .AXI_ADDR_WIDTH_P ( VIP_AXI4_CFG_C.VIP_AXI4_ADDR_WIDTH_P ),
    .AXI_DATA_WIDTH_P ( VIP_AXI4_CFG_C.VIP_AXI4_DATA_WIDTH_P ),
    .AXI_STRB_WIDTH_P ( VIP_AXI4_CFG_C.VIP_AXI4_STRB_WIDTH_P ),
    .NR_OF_MASTERS_P  ( NR_OF_MASTERS_C                      )

  ) axi4_write_arbiter_i0 (

    // Clock and reset
    .clk              ( mem_vif.clk                          ), // input
    .rst_n            ( mem_vif.rst_n                        ), // input

    // -------------------------------------------------------------------------
    // AXI4 Masters
    // -------------------------------------------------------------------------

    // Write Address Channel
    .mst_awid         ( mst_awid                             ), // input
    .mst_awaddr       ( mst_awaddr                           ), // input
    .mst_awlen        ( mst_awlen                            ), // input
    .mst_awvalid      ( mst_awvalid                          ), // input
    .mst_awready      ( mst_awready                          ), // output

    // Write Data Channel
    .mst_wdata        ( mst_wdata                            ), // input
    .mst_wstrb        ( mst_wstrb                            ), // input
    .mst_wlast        ( mst_wlast                            ), // input
    .mst_wvalid       ( mst_wvalid                           ), // input
    .mst_wready       ( mst_wready                           ), // output

    // -------------------------------------------------------------------------
    // AXI4 Slave
    // -------------------------------------------------------------------------

    // Write Address Channel
    .slv_awid         ( mem_vif.awid                         ), // output
    .slv_awaddr       ( mem_vif.awaddr                       ), // output
    .slv_awlen        ( mem_vif.awlen                        ), // output
    .slv_awsize       ( mem_vif.awsize                       ), // output
    .slv_awburst      ( mem_vif.awburst                      ), // output
    .slv_awlock       ( mem_vif.awlock                       ), // output
    .slv_awcache      ( mem_vif.awcache                      ), // output
    .slv_awprot       ( mem_vif.awprot                       ), // output
    .slv_awqos        ( mem_vif.awqos                        ), // output
    .slv_awvalid      ( mem_vif.awvalid                      ), // output
    .slv_awready      ( mem_vif.awready                      ), // input

    // Write Data Channel
    .slv_wdata        ( mem_vif.wdata                        ), // output
    .slv_wstrb        ( mem_vif.wstrb                        ), // output
    .slv_wlast        ( mem_vif.wlast                        ), // output
    .slv_wvalid       ( mem_vif.wvalid                       ), // output
    .slv_wready       ( mem_vif.wready                       ), // input

    // Write Response Channel
    .slv_bid          ( mem_vif.bid                          ), // input
    .slv_bresp        ( mem_vif.bresp                        ), // input
    .slv_bvalid       ( mem_vif.bvalid                       ), // input
    .slv_bready       ( mem_vif.bready                       )  // output
  );

  //---------------------------------------------------------------------------
  // Write Agents Constants (Unused)
  //---------------------------------------------------------------------------

  // Write Response Channels
  assign mst_vif0.bid    = '0;
  assign mst_vif0.bresp  = '0;
  assign mst_vif0.buser  = '0;
  assign mst_vif0.bvalid = '0;

  assign mst_vif1.bid    = '0;
  assign mst_vif1.bresp  = '0;
  assign mst_vif1.buser  = '0;
  assign mst_vif1.bvalid = '0;

  assign mst_vif2.bid    = '0;
  assign mst_vif2.bresp  = '0;
  assign mst_vif2.buser  = '0;
  assign mst_vif2.bvalid = '0;

  //---------------------------------------------------------------------------
  // Memory Agent Constants (Unused)
  //---------------------------------------------------------------------------

  assign mem_vif.awregion = '0;
  assign mem_vif.awuser   = '0;

  // Write Data Channel
  assign mem_vif.wuser    = '0;


  initial begin
    uvm_config_db #(virtual clk_rst_if)::set(uvm_root::get(),                    "uvm_test_top.tb_env*",                "vif", clk_rst_vif);
    uvm_config_db #(virtual clk_rst_if)::set(uvm_root::get(),                    "uvm_test_top.tb_env.clk_rst_agent0*", "vif", clk_rst_vif);
    uvm_config_db #(virtual vip_axi4_if #(VIP_AXI4_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.wr_agent0*",      "vif", mst_vif0);
    uvm_config_db #(virtual vip_axi4_if #(VIP_AXI4_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.wr_agent1*",      "vif", mst_vif1);
    uvm_config_db #(virtual vip_axi4_if #(VIP_AXI4_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.wr_agent2*",      "vif", mst_vif2);
    uvm_config_db #(virtual vip_axi4_if #(VIP_AXI4_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.mem_agent0*",     "vif", mem_vif);
    run_test();
    $stop();

  end


  initial begin
    $timeformat(-9, 0, "", 11);  // units, precision, suffix, min field width
    if ($test$plusargs("RECORD")) begin
      uvm_config_db #(uvm_verbosity)::set(null,"*", "recording_detail", UVM_FULL);
    end
    else begin
      uvm_config_db #(uvm_verbosity)::set(null,"*", "recording_detail", UVM_NONE);
    end
  end

endmodule
