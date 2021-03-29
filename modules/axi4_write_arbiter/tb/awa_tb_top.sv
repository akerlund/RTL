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
// Four arbiters of type "axi4_write_arbiter_mst_2_slvs" are instantiated with
// connections to four slaves each, a total of 4 masters and 16 slaves.
// There are four Write Agents to drive those arbiters. The 16 slaves are also
// connected to an arbiter of the type "axi4_write_arbiter_msts_2_slv", thus
// they are now considered masters and must compete for access.
// The final slave is a Memory Agent.
//
// -----------------------------------------------------------------------------
//
//    One Master (x4) to Four Slaves:
//    "axi4_write_arbiter_mst_2_slvs"
//
//   +-------+   +-----+         +-----+
//   |       |   |     |    4    |     |
//   | Agent +-->+  0  +-------->+     |
//   |       |   |     |         |     |
//   +-------+   +-----+         |     |
//                               |     |
//   +-------+   +-----+         |     |
//   |       |   |     |    4    |     |
//   | Agent +-->+  1  +-------->+     |
//   |       |   |     |         |     |    +-------+
//   +-------+   +-----+         |     |    |       |
//                               |  0  +--->+ Agent |
//   +-------+   +-----+         |     |    |       |
//   |       |   |     |    4    |     |    +-------+
//   | Agent +-->+  2  +-------->+     |
//   |       |   |     |         |     |
//   +-------+   +-----+         |     |
//                               |     |
//   +-------+   +-----+         |     |
//   |       |   |     |    4    |     |
//   | Agent +-->+  3  +-------->+     |
//   |       |   |     |         |     |
//   +-------+   +-----+         +-----+
//
//                       4x4 Masters to One Slave
//                       "axi4_write_arbiter_msts_2_slv"
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
  vip_axi4_if #(VIP_AXI4_CFG_C) mst_vif3(clk_rst_vif.clk, clk_rst_vif.rst_n);
  vip_axi4_if #(VIP_AXI4_CFG_C) mem_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);

  mst_vif0.sink_read_channel();
  mst_vif1.sink_read_channel();
  mst_vif2.sink_read_channel();
  mst_vif3.sink_read_channel();
  mem_vif.sink_read_channel();

  // -------------------------------------------------------------------------
  // Connection between the arbiters:
  // (Master to Slaves) to (Slaves to Master)
  // -------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // Arbiter 4: Assigned with concatenations of the other four arbiters
  // ---------------------------------------------------------------------------

  // Write Address Channel
  logic [NR_OF_MASTERS_C-1 : 0]   [VIP_AXI4_CFG_C.VIP_AXI4_ID_WIDTH_P-1 : 0] slvs_awid;
  logic [NR_OF_MASTERS_C-1 : 0] [VIP_AXI4_CFG_C.VIP_AXI4_ADDR_WIDTH_P-1 : 0] slvs_awaddr;
  logic [NR_OF_MASTERS_C-1 : 0]                                 [7 : 0] slvs_awlen;
  logic [NR_OF_MASTERS_C-1 : 0]                                 [2 : 0] slvs_awsize;
  logic [NR_OF_MASTERS_C-1 : 0]                                 [1 : 0] slvs_awburst;
  logic [NR_OF_MASTERS_C-1 : 0]                                 [3 : 0] slvs_awregion;
  logic                                         [NR_OF_MASTERS_C-1 : 0] slvs_awvalid;
  logic                                         [NR_OF_MASTERS_C-1 : 0] slvs_awready;

  // Write Data Channel
  logic [NR_OF_MASTERS_C-1 : 0] [VIP_AXI4_CFG_C.VIP_AXI4_DATA_WIDTH_P-1 : 0] slvs_wdata;
  logic [NR_OF_MASTERS_C-1 : 0] [VIP_AXI4_CFG_C.VIP_AXI4_STRB_WIDTH_P-1 : 0] slvs_wstrb;
  logic [NR_OF_MASTERS_C-1 : 0]                                         slvs_wlast;
  logic                                         [NR_OF_MASTERS_C-1 : 0] slvs_wvalid;
  logic                                         [NR_OF_MASTERS_C-1 : 0] slvs_wready;

  // Write Response Channel
  logic                            [VIP_AXI4_CFG_C.VIP_AXI4_ID_WIDTH_P-1 : 0] slvs_bid;
  logic                                                          [1 : 0] slvs_bresp;
  logic                                          [NR_OF_MASTERS_C-1 : 0] slvs_bvalid;
  logic                                          [NR_OF_MASTERS_C-1 : 0] slvs_bready;

  // ---------------------------------------------------------------------------
  // Arbiter 0
  // ---------------------------------------------------------------------------

  logic                            [VIP_AXI4_CFG_C.VIP_AXI4_ID_WIDTH_P-1 : 0] slvs_awid0;
  logic                          [VIP_AXI4_CFG_C.VIP_AXI4_ADDR_WIDTH_P-1 : 0] slvs_awaddr0;
  logic                                                          [7 : 0] slvs_awlen0;
  logic                                                          [2 : 0] slvs_awsize0;
  logic                                                          [1 : 0] slvs_awburst0;
  logic                                                          [3 : 0] slvs_awregion0;
  logic                                           [NR_OF_SLAVES_C-1 : 0] slvs_awready0;
  logic                                           [NR_OF_SLAVES_C-1 : 0] slvs_awvalid0;

  logic                          [VIP_AXI4_CFG_C.VIP_AXI4_DATA_WIDTH_P-1 : 0] slvs_wdata0;
  logic                          [VIP_AXI4_CFG_C.VIP_AXI4_STRB_WIDTH_P-1 : 0] slvs_wstrb0;
  logic                                                                  slvs_wlast0;
  logic                                           [NR_OF_SLAVES_C-1 : 0] slvs_wready0;
  logic                                           [NR_OF_SLAVES_C-1 : 0] slvs_wvalid0;

  logic [NR_OF_SLAVES_C-1 : 0]     [VIP_AXI4_CFG_C.VIP_AXI4_ID_WIDTH_P-1 : 0] slvs_bid0;
  logic [NR_OF_SLAVES_C-1 : 0]                                   [1 : 0] slvs_bresp0;
  logic                                           [NR_OF_SLAVES_C-1 : 0] slvs_bvalid0;
  logic                                           [NR_OF_SLAVES_C-1 : 0] slvs_bready0;


  // ---------------------------------------------------------------------------
  // Arbiter 1
  // ---------------------------------------------------------------------------

  logic                            [VIP_AXI4_CFG_C.VIP_AXI4_ID_WIDTH_P-1 : 0] slvs_awid1;
  logic                          [VIP_AXI4_CFG_C.VIP_AXI4_ADDR_WIDTH_P-1 : 0] slvs_awaddr1;
  logic                                                          [7 : 0] slvs_awlen1;
  logic                                                          [2 : 0] slvs_awsize1;
  logic                                                          [1 : 0] slvs_awburst1;
  logic                                                          [3 : 0] slvs_awregion1;
  logic                                           [NR_OF_SLAVES_C-1 : 0] slvs_awready1;
  logic                                           [NR_OF_SLAVES_C-1 : 0] slvs_awvalid1;

  logic                          [VIP_AXI4_CFG_C.VIP_AXI4_DATA_WIDTH_P-1 : 0] slvs_wdata1;
  logic                          [VIP_AXI4_CFG_C.VIP_AXI4_STRB_WIDTH_P-1 : 0] slvs_wstrb1;
  logic                                                                  slvs_wlast1;
  logic                                           [NR_OF_SLAVES_C-1 : 0] slvs_wready1;
  logic                                           [NR_OF_SLAVES_C-1 : 0] slvs_wvalid1;

  logic [NR_OF_SLAVES_C-1 : 0]     [VIP_AXI4_CFG_C.VIP_AXI4_ID_WIDTH_P-1 : 0] slvs_bid1;
  logic [NR_OF_SLAVES_C-1 : 0]                                   [1 : 0] slvs_bresp1;
  logic                                           [NR_OF_SLAVES_C-1 : 0] slvs_bvalid1;
  logic                                           [NR_OF_SLAVES_C-1 : 0] slvs_bready1;


  // ---------------------------------------------------------------------------
  // Arbiter 2
  // ---------------------------------------------------------------------------

  logic                            [VIP_AXI4_CFG_C.VIP_AXI4_ID_WIDTH_P-1 : 0] slvs_awid2;
  logic                          [VIP_AXI4_CFG_C.VIP_AXI4_ADDR_WIDTH_P-1 : 0] slvs_awaddr2;
  logic                                                          [7 : 0] slvs_awlen2;
  logic                                                          [2 : 0] slvs_awsize2;
  logic                                                          [1 : 0] slvs_awburst2;
  logic                                                          [3 : 0] slvs_awregion2;
  logic                                           [NR_OF_SLAVES_C-1 : 0] slvs_awready2;
  logic                                           [NR_OF_SLAVES_C-1 : 0] slvs_awvalid2;

  logic                          [VIP_AXI4_CFG_C.VIP_AXI4_DATA_WIDTH_P-1 : 0] slvs_wdata2;
  logic                          [VIP_AXI4_CFG_C.VIP_AXI4_STRB_WIDTH_P-1 : 0] slvs_wstrb2;
  logic                                                                  slvs_wlast2;
  logic                                           [NR_OF_SLAVES_C-1 : 0] slvs_wready2;
  logic                                           [NR_OF_SLAVES_C-1 : 0] slvs_wvalid2;

  logic [NR_OF_SLAVES_C-1 : 0]     [VIP_AXI4_CFG_C.VIP_AXI4_ID_WIDTH_P-1 : 0] slvs_bid2;
  logic [NR_OF_SLAVES_C-1 : 0]                                   [1 : 0] slvs_bresp2;
  logic                                           [NR_OF_SLAVES_C-1 : 0] slvs_bvalid2;
  logic                                           [NR_OF_SLAVES_C-1 : 0] slvs_bready2;


  // ---------------------------------------------------------------------------
  // Arbiter 3
  // ---------------------------------------------------------------------------

  logic                            [VIP_AXI4_CFG_C.VIP_AXI4_ID_WIDTH_P-1 : 0] slvs_awid3;
  logic                          [VIP_AXI4_CFG_C.VIP_AXI4_ADDR_WIDTH_P-1 : 0] slvs_awaddr3;
  logic                                                          [7 : 0] slvs_awlen3;
  logic                                                          [2 : 0] slvs_awsize3;
  logic                                                          [1 : 0] slvs_awburst3;
  logic                                                          [3 : 0] slvs_awregion3;
  logic                                           [NR_OF_SLAVES_C-1 : 0] slvs_awready3;
  logic                                           [NR_OF_SLAVES_C-1 : 0] slvs_awvalid3;

  logic                          [VIP_AXI4_CFG_C.VIP_AXI4_DATA_WIDTH_P-1 : 0] slvs_wdata3;
  logic                          [VIP_AXI4_CFG_C.VIP_AXI4_STRB_WIDTH_P-1 : 0] slvs_wstrb3;
  logic                                                                  slvs_wlast3;
  logic                                           [NR_OF_SLAVES_C-1 : 0] slvs_wready3;
  logic                                           [NR_OF_SLAVES_C-1 : 0] slvs_wvalid3;

  logic [NR_OF_SLAVES_C-1 : 0]     [VIP_AXI4_CFG_C.VIP_AXI4_ID_WIDTH_P-1 : 0] slvs_bid3;
  logic [NR_OF_SLAVES_C-1 : 0]                                   [1 : 0] slvs_bresp3;
  logic                                           [NR_OF_SLAVES_C-1 : 0] slvs_bvalid3;
  logic                                           [NR_OF_SLAVES_C-1 : 0] slvs_bready3;


  // ---------------------------------------------------------------------------
  // Input assignment of the msts_2_slv arbiters
  // ---------------------------------------------------------------------------

  // Write Address Channel
  assign slvs_awid     = { {NR_OF_SLAVES_C{slvs_awid3}},     {NR_OF_SLAVES_C{slvs_awid2}},     {NR_OF_SLAVES_C{slvs_awid1}},     {NR_OF_SLAVES_C{slvs_awid0}}     };
  assign slvs_awaddr   = { {NR_OF_SLAVES_C{slvs_awaddr3}},   {NR_OF_SLAVES_C{slvs_awaddr2}},   {NR_OF_SLAVES_C{slvs_awaddr1}},   {NR_OF_SLAVES_C{slvs_awaddr0}}   };
  assign slvs_awlen    = { {NR_OF_SLAVES_C{slvs_awlen3}},    {NR_OF_SLAVES_C{slvs_awlen2}},    {NR_OF_SLAVES_C{slvs_awlen1}},    {NR_OF_SLAVES_C{slvs_awlen0}}    };
  assign slvs_awsize   = { {NR_OF_SLAVES_C{slvs_awsize3}},   {NR_OF_SLAVES_C{slvs_awsize2}},   {NR_OF_SLAVES_C{slvs_awsize1}},   {NR_OF_SLAVES_C{slvs_awsize0}}   };
  assign slvs_awburst  = { {NR_OF_SLAVES_C{slvs_awburst3}},  {NR_OF_SLAVES_C{slvs_awburst2}},  {NR_OF_SLAVES_C{slvs_awburst1}},  {NR_OF_SLAVES_C{slvs_awburst0}}  };
  assign slvs_awregion = { {NR_OF_SLAVES_C{slvs_awregion3}}, {NR_OF_SLAVES_C{slvs_awregion2}}, {NR_OF_SLAVES_C{slvs_awregion1}}, {NR_OF_SLAVES_C{slvs_awregion0}} };
  assign slvs_awvalid  = { slvs_awvalid3, slvs_awvalid2, slvs_awvalid1, slvs_awvalid0 };

  assign {slvs_awready3, slvs_awready2, slvs_awready1, slvs_awready0} = slvs_awready;

  // Write Data Channel
  assign slvs_wdata  = { {NR_OF_SLAVES_C{slvs_wdata3}},  {NR_OF_SLAVES_C{slvs_wdata2}},  {NR_OF_SLAVES_C{slvs_wdata1}},  {NR_OF_SLAVES_C{slvs_wdata0}}  };
  assign slvs_wstrb  = { {NR_OF_SLAVES_C{slvs_wstrb3}},  {NR_OF_SLAVES_C{slvs_wstrb2}},  {NR_OF_SLAVES_C{slvs_wstrb1}},  {NR_OF_SLAVES_C{slvs_wstrb0}}  };
  assign slvs_wlast  = { {NR_OF_SLAVES_C{slvs_wlast3}},  {NR_OF_SLAVES_C{slvs_wlast2}},  {NR_OF_SLAVES_C{slvs_wlast1}},  {NR_OF_SLAVES_C{slvs_wlast0}}  };
  assign slvs_wvalid = { slvs_wvalid3, slvs_wvalid2, slvs_wvalid1, slvs_wvalid0 };

  assign {slvs_wready3, slvs_wready2, slvs_wready1, slvs_wready0} = slvs_wready;

  // Write Response Channel
  assign {slvs_bid3,    slvs_bid2,    slvs_bid1,    slvs_bid0}    = {NR_OF_MASTERS_C{slvs_bid}};
  assign {slvs_bresp3,  slvs_bresp2,  slvs_bresp1,  slvs_bresp0}  = {NR_OF_MASTERS_C{slvs_bresp}};
  assign {slvs_bvalid3, slvs_bvalid2, slvs_bvalid1, slvs_bvalid0} = {NR_OF_MASTERS_C{slvs_bvalid}};

  assign slvs_bready = {slvs_bready3, slvs_bready2, slvs_bready1, slvs_bready0};



  // ---------------------------------------------------------------------------
  // DUT0: One Master to (NR_OF_SLAVES_C) Slaves
  // ---------------------------------------------------------------------------
  axi4_write_arbiter #(

    .AXI_ID_WIDTH_P   ( VIP_AXI4_CFG_C.VIP_AXI4_ID_WIDTH_P   ),
    .AXI_ADDR_WIDTH_P ( VIP_AXI4_CFG_C.VIP_AXI4_ADDR_WIDTH_P ),
    .AXI_DATA_WIDTH_P ( VIP_AXI4_CFG_C.VIP_AXI4_DATA_WIDTH_P ),
    .AXI_STRB_WIDTH_P ( VIP_AXI4_CFG_C.VIP_AXI4_STRB_WIDTH_P ),
    .NR_OF_MASTERS_P  ( 1                                    ),
    .NR_OF_SLAVES_P   ( NR_OF_SLAVES_C                       )

  ) axi4_write_arbiter_i0 (

    // Clock and reset
    .clk              ( clk_rst_vif.clk                      ), // input
    .rst_n            ( clk_rst_vif.rst_n                    ), // input

    // -------------------------------------------------------------------------
    // AXI4 Master
    // -------------------------------------------------------------------------

    // Write Address Channel
    .mst_awid         ( mst_vif0.awid                        ), // input
    .mst_awaddr       ( mst_vif0.awaddr                      ), // input
    .mst_awlen        ( mst_vif0.awlen                       ), // input
    .mst_awsize       ( mst_vif0.awsize                      ), // input
    .mst_awburst      ( mst_vif0.awburst                     ), // input
    .mst_awregion     ( mst_vif0.awregion                    ), // input
    .mst_awvalid      ( mst_vif0.awvalid                     ), // input
    .mst_awready      ( mst_vif0.awready                     ), // output

    // Write Data Channel
    .mst_wdata        ( mst_vif0.wdata                       ), // input
    .mst_wstrb        ( mst_vif0.wstrb                       ), // input
    .mst_wlast        ( mst_vif0.wlast                       ), // input
    .mst_wvalid       ( mst_vif0.wvalid                      ), // input
    .mst_wready       ( mst_vif0.wready                      ), // output

    // Write Response Channel
    .mst_bid          ( mst_vif0.bid                         ), // output
    .mst_bresp        ( mst_vif0.bresp                       ), // output
    .mst_bvalid       ( mst_vif0.bvalid                      ), // output
    .mst_bready       ( mst_vif0.bready                      ), // input

    // -------------------------------------------------------------------------
    // AXI4 Slaves
    // -------------------------------------------------------------------------

    // Write Address Channel
    .slv_awid         ( slvs_awid0                           ), // output
    .slv_awaddr       ( slvs_awaddr0                         ), // output
    .slv_awlen        ( slvs_awlen0                          ), // output
    .slv_awsize       ( slvs_awsize0                         ), // output
    .slv_awburst      ( slvs_awburst0                        ), // output
    .slv_awregion     ( slvs_awregion0                       ), // output
    .slv_awvalid      ( slvs_awvalid0                        ), // output
    .slv_awready      ( slvs_awready0                        ), // input

    // Write Data Channel
    .slv_wdata        ( slvs_wdata0                          ), // output
    .slv_wstrb        ( slvs_wstrb0                          ), // output
    .slv_wlast        ( slvs_wlast0                          ), // output
    .slv_wvalid       ( slvs_wvalid0                         ), // output
    .slv_wready       ( slvs_wready0                         ), // input

    // Write Response Channel
    .slv_bid          ( slvs_bid0                            ), // input
    .slv_bresp        ( slvs_bresp0                          ), // input
    .slv_bvalid       ( slvs_bvalid0                         ), // input
    .slv_bready       ( slvs_bready0                         )  // output
  );


  // ---------------------------------------------------------------------------
  // DUT1: One Master to (NR_OF_SLAVES_C) Slaves
  // ---------------------------------------------------------------------------
  axi4_write_arbiter #(

    .AXI_ID_WIDTH_P   ( VIP_AXI4_CFG_C.VIP_AXI4_ID_WIDTH_P   ),
    .AXI_ADDR_WIDTH_P ( VIP_AXI4_CFG_C.VIP_AXI4_ADDR_WIDTH_P ),
    .AXI_DATA_WIDTH_P ( VIP_AXI4_CFG_C.VIP_AXI4_DATA_WIDTH_P ),
    .AXI_STRB_WIDTH_P ( VIP_AXI4_CFG_C.VIP_AXI4_STRB_WIDTH_P ),
    .NR_OF_MASTERS_P  ( 1                                    ),
    .NR_OF_SLAVES_P   ( NR_OF_SLAVES_C                       )

  ) axi4_write_arbiter_i1 (

    // Clock and reset
    .clk              ( clk_rst_vif.clk                      ), // input
    .rst_n            ( clk_rst_vif.rst_n                    ), // input

    // -------------------------------------------------------------------------
    // AXI4 Master
    // -------------------------------------------------------------------------

    // Write Address Channel
    .mst_awid         ( mst_vif1.awid                        ), // input
    .mst_awaddr       ( mst_vif1.awaddr                      ), // input
    .mst_awlen        ( mst_vif1.awlen                       ), // input
    .mst_awsize       ( mst_vif1.awsize                      ), // input
    .mst_awburst      ( mst_vif1.awburst                     ), // input
    .mst_awregion     ( mst_vif1.awregion                    ), // input
    .mst_awvalid      ( mst_vif1.awvalid                     ), // input
    .mst_awready      ( mst_vif1.awready                     ), // output

    // Write Data Channel
    .mst_wdata        ( mst_vif1.wdata                       ), // input
    .mst_wstrb        ( mst_vif1.wstrb                       ), // input
    .mst_wlast        ( mst_vif1.wlast                       ), // input
    .mst_wvalid       ( mst_vif1.wvalid                      ), // input
    .mst_wready       ( mst_vif1.wready                      ), // output

    // Write Response Channel
    .mst_bid          ( mst_vif1.bid                         ), // output
    .mst_bresp        ( mst_vif1.bresp                       ), // output
    .mst_bvalid       ( mst_vif1.bvalid                      ), // output
    .mst_bready       ( mst_vif1.bready                      ), // input

    // -------------------------------------------------------------------------
    // AXI4 Slaves
    // -------------------------------------------------------------------------

    // Write Address Channel
    .slv_awid         ( slvs_awid1                           ), // output
    .slv_awaddr       ( slvs_awaddr1                         ), // output
    .slv_awlen        ( slvs_awlen1                          ), // output
    .slv_awsize       ( slvs_awsize1                         ), // output
    .slv_awburst      ( slvs_awburst1                        ), // output
    .slv_awregion     ( slvs_awregion1                       ), // output
    .slv_awvalid      ( slvs_awvalid1                        ), // output
    .slv_awready      ( slvs_awready1                        ), // input

    // Write Data Channel
    .slv_wdata        ( slvs_wdata1                          ), // output
    .slv_wstrb        ( slvs_wstrb1                          ), // output
    .slv_wlast        ( slvs_wlast1                          ), // output
    .slv_wvalid       ( slvs_wvalid1                         ), // output
    .slv_wready       ( slvs_wready1                         ), // input

    // Write Response Channel
    .slv_bid          ( slvs_bid1                            ), // input
    .slv_bresp        ( slvs_bresp1                          ), // input
    .slv_bvalid       ( slvs_bvalid1                         ), // input
    .slv_bready       ( slvs_bready1                         )  // output
  );


  // ---------------------------------------------------------------------------
  // DUT2: One Master to (NR_OF_SLAVES_C) Slaves
  // ---------------------------------------------------------------------------
  axi4_write_arbiter #(

    .AXI_ID_WIDTH_P   ( VIP_AXI4_CFG_C.VIP_AXI4_ID_WIDTH_P   ),
    .AXI_ADDR_WIDTH_P ( VIP_AXI4_CFG_C.VIP_AXI4_ADDR_WIDTH_P ),
    .AXI_DATA_WIDTH_P ( VIP_AXI4_CFG_C.VIP_AXI4_DATA_WIDTH_P ),
    .AXI_STRB_WIDTH_P ( VIP_AXI4_CFG_C.VIP_AXI4_STRB_WIDTH_P ),
    .NR_OF_MASTERS_P  ( 1                                    ),
    .NR_OF_SLAVES_P   ( NR_OF_SLAVES_C                       )

  ) axi4_write_arbiter_i2 (

    // Clock and reset
    .clk              ( clk_rst_vif.clk                      ), // input
    .rst_n            ( clk_rst_vif.rst_n                    ), // input

    // -------------------------------------------------------------------------
    // AXI4 Master
    // -------------------------------------------------------------------------

    // Write Address Channel
    .mst_awid         ( mst_vif2.awid                        ), // input
    .mst_awaddr       ( mst_vif2.awaddr                      ), // input
    .mst_awlen        ( mst_vif2.awlen                       ), // input
    .mst_awsize       ( mst_vif2.awsize                      ), // input
    .mst_awburst      ( mst_vif2.awburst                     ), // input
    .mst_awregion     ( mst_vif2.awregion                    ), // input
    .mst_awvalid      ( mst_vif2.awvalid                     ), // input
    .mst_awready      ( mst_vif2.awready                     ), // output

    // Write Data Channel
    .mst_wdata        ( mst_vif2.wdata                       ), // input
    .mst_wstrb        ( mst_vif2.wstrb                       ), // input
    .mst_wlast        ( mst_vif2.wlast                       ), // input
    .mst_wvalid       ( mst_vif2.wvalid                      ), // input
    .mst_wready       ( mst_vif2.wready                      ), // output

    // Write Response Channel
    .mst_bid          ( mst_vif2.bid                         ), // output
    .mst_bresp        ( mst_vif2.bresp                       ), // output
    .mst_bvalid       ( mst_vif2.bvalid                      ), // output
    .mst_bready       ( mst_vif2.bready                      ), // input

    // -------------------------------------------------------------------------
    // AXI4 Slaves
    // -------------------------------------------------------------------------

    // Write Address Channel
    .slv_awid         ( slvs_awid2                           ), // output
    .slv_awaddr       ( slvs_awaddr2                         ), // output
    .slv_awlen        ( slvs_awlen2                          ), // output
    .slv_awsize       ( slvs_awsize2                         ), // output
    .slv_awburst      ( slvs_awburst2                        ), // output
    .slv_awregion     ( slvs_awregion2                       ), // output
    .slv_awvalid      ( slvs_awvalid2                        ), // output
    .slv_awready      ( slvs_awready2                        ), // input

    // Write Data Channel
    .slv_wdata        ( slvs_wdata2                          ), // output
    .slv_wstrb        ( slvs_wstrb2                          ), // output
    .slv_wlast        ( slvs_wlast2                          ), // output
    .slv_wvalid       ( slvs_wvalid2                         ), // output
    .slv_wready       ( slvs_wready2                         ), // input

    // Write Response Channel
    .slv_bid          ( slvs_bid2                            ), // input
    .slv_bresp        ( slvs_bresp2                          ), // input
    .slv_bvalid       ( slvs_bvalid2                         ), // input
    .slv_bready       ( slvs_bready2                         )  // output
  );


  // ---------------------------------------------------------------------------
  // DUT3: One Master to (NR_OF_SLAVES_C) Slaves
  // ---------------------------------------------------------------------------
  axi4_write_arbiter #(

    .AXI_ID_WIDTH_P   ( VIP_AXI4_CFG_C.VIP_AXI4_ID_WIDTH_P   ),
    .AXI_ADDR_WIDTH_P ( VIP_AXI4_CFG_C.VIP_AXI4_ADDR_WIDTH_P ),
    .AXI_DATA_WIDTH_P ( VIP_AXI4_CFG_C.VIP_AXI4_DATA_WIDTH_P ),
    .AXI_STRB_WIDTH_P ( VIP_AXI4_CFG_C.VIP_AXI4_STRB_WIDTH_P ),
    .NR_OF_MASTERS_P  ( 1                                    ),
    .NR_OF_SLAVES_P   ( NR_OF_SLAVES_C                       )

  ) axi4_write_arbiter_i3 (

    // Clock and reset
    .clk              ( clk_rst_vif.clk                      ), // input
    .rst_n            ( clk_rst_vif.rst_n                    ), // input

    // -------------------------------------------------------------------------
    // AXI4 Master
    // -------------------------------------------------------------------------

    // Write Address Channel
    .mst_awid         ( mst_vif3.awid                        ), // input
    .mst_awaddr       ( mst_vif3.awaddr                      ), // input
    .mst_awlen        ( mst_vif3.awlen                       ), // input
    .mst_awsize       ( mst_vif3.awsize                      ), // input
    .mst_awburst      ( mst_vif3.awburst                     ), // input
    .mst_awregion     ( mst_vif3.awregion                    ), // input
    .mst_awvalid      ( mst_vif3.awvalid                     ), // input
    .mst_awready      ( mst_vif3.awready                     ), // output

    // Write Data Channel
    .mst_wdata        ( mst_vif3.wdata                       ), // input
    .mst_wstrb        ( mst_vif3.wstrb                       ), // input
    .mst_wlast        ( mst_vif3.wlast                       ), // input
    .mst_wvalid       ( mst_vif3.wvalid                      ), // input
    .mst_wready       ( mst_vif3.wready                      ), // output

    // Write Response Channel
    .mst_bid          ( mst_vif3.bid                         ), // output
    .mst_bresp        ( mst_vif3.bresp                       ), // output
    .mst_bvalid       ( mst_vif3.bvalid                      ), // output
    .mst_bready       ( mst_vif3.bready                      ), // input

    // -------------------------------------------------------------------------
    // AXI4 Slaves
    // -------------------------------------------------------------------------

    // Write Address Channel
    .slv_awid         ( slvs_awid3                           ), // output
    .slv_awaddr       ( slvs_awaddr3                         ), // output
    .slv_awlen        ( slvs_awlen3                          ), // output
    .slv_awsize       ( slvs_awsize3                         ), // output
    .slv_awburst      ( slvs_awburst3                        ), // output
    .slv_awregion     ( slvs_awregion3                       ), // output
    .slv_awvalid      ( slvs_awvalid3                        ), // output
    .slv_awready      ( slvs_awready3                        ), // input

    // Write Data Channel
    .slv_wdata        ( slvs_wdata3                          ), // output
    .slv_wstrb        ( slvs_wstrb3                          ), // output
    .slv_wlast        ( slvs_wlast3                          ), // output
    .slv_wvalid       ( slvs_wvalid3                         ), // output
    .slv_wready       ( slvs_wready3                         ), // input

    // Write Response Channel
    .slv_bid          ( slvs_bid3                            ), // input
    .slv_bresp        ( slvs_bresp3                          ), // input
    .slv_bvalid       ( slvs_bvalid3                         ), // input
    .slv_bready       ( slvs_bready3                         )  // output
  );




  // ---------------------------------------------------------------------------
  // DUT4: (NR_OF_MASTERS_C) Master to 1 Slave
  // ---------------------------------------------------------------------------
  axi4_write_arbiter #(

    .AXI_ID_WIDTH_P   ( VIP_AXI4_CFG_C.VIP_AXI4_ID_WIDTH_P   ),
    .AXI_ADDR_WIDTH_P ( VIP_AXI4_CFG_C.VIP_AXI4_ADDR_WIDTH_P ),
    .AXI_DATA_WIDTH_P ( VIP_AXI4_CFG_C.VIP_AXI4_DATA_WIDTH_P ),
    .AXI_STRB_WIDTH_P ( VIP_AXI4_CFG_C.VIP_AXI4_STRB_WIDTH_P ),
    .NR_OF_MASTERS_P  ( NR_OF_MASTERS_C                      ),
    .NR_OF_SLAVES_P   ( 1                                    )

  ) axi4_write_arbiter_i4 (

    // Clock and reset
    .clk              ( clk_rst_vif.clk                      ), // input
    .rst_n            ( clk_rst_vif.rst_n                    ), // input

    // -------------------------------------------------------------------------
    // AXI4 Masters
    // -------------------------------------------------------------------------

    // Write Address Channel
    .mst_awid         ( slvs_awid                            ), // input
    .mst_awaddr       ( slvs_awaddr                          ), // input
    .mst_awlen        ( slvs_awlen                           ), // input
    .mst_awsize       ( slvs_awsize                          ), // input
    .mst_awburst      ( slvs_awburst                         ), // input
    .mst_awregion     ( slvs_awregion                        ), // input
    .mst_awvalid      ( slvs_awvalid                         ), // input
    .mst_awready      ( slvs_awready                         ), // output

    // Write Data Channel
    .mst_wdata        ( slvs_wdata                           ), // input
    .mst_wstrb        ( slvs_wstrb                           ), // input
    .mst_wlast        ( slvs_wlast                           ), // input
    .mst_wvalid       ( slvs_wvalid                          ), // input
    .mst_wready       ( slvs_wready                          ), // output

    // Write Response Channel
    .mst_bid          ( slvs_bid                             ), // output
    .mst_bresp        ( slvs_bresp                           ), // output
    .mst_bvalid       ( slvs_bvalid                          ), // output
    .mst_bready       ( slvs_bready                          ), // input

    // -------------------------------------------------------------------------
    // AXI4 Slave
    // -------------------------------------------------------------------------

    // Write Address Channel
    .slv_awid         ( mem_vif.awid                         ), // output
    .slv_awaddr       ( mem_vif.awaddr                       ), // output
    .slv_awlen        ( mem_vif.awlen                        ), // output
    .slv_awsize       ( mem_vif.awsize                       ), // output
    .slv_awburst      ( mem_vif.awburst                      ), // output
    .slv_awregion     ( mem_vif.awregion                     ), // output
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


  initial begin
    $timeformat(-9, 0, "", 11);  // $timeformat(units_number, precision_number, suffix_string, minimum_field_width);
    uvm_config_db #(virtual clk_rst_if)::set(uvm_root::get(),                    "uvm_test_top.tb_env.clk_rst_agent0*", "vif", clk_rst_vif);
    uvm_config_db #(virtual vip_axi4_if #(VIP_AXI4_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.wr_agent0*",      "vif", mst_vif0);
    uvm_config_db #(virtual vip_axi4_if #(VIP_AXI4_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.wr_agent1*",      "vif", mst_vif1);
    uvm_config_db #(virtual vip_axi4_if #(VIP_AXI4_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.wr_agent2*",      "vif", mst_vif2);
    uvm_config_db #(virtual vip_axi4_if #(VIP_AXI4_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.wr_agent3*",      "vif", mst_vif3);
    uvm_config_db #(virtual vip_axi4_if #(VIP_AXI4_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.mem_agent0*",     "vif", mem_vif);
    run_test();
    $stop();
  end


  initial begin
    if ($test$plusargs("RECORD")) begin
      uvm_config_db #(uvm_verbosity)::set(null,"*", "recording_detail", UVM_FULL);
    end else begin
      uvm_config_db #(uvm_verbosity)::set(null,"*", "recording_detail", UVM_NONE);
    end
  end

endmodule
