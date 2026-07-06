////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2026 Fredrik Åkerlund
// https://github.com/akerlund/RTL
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//
////////////////////////////////////////////////////////////////////////////////

import uvm_pkg::*;
import ara_tb_pkg::*;
import ara_tc_pkg::*;

module ara_tb_top;

  // IF
  clk_rst_if                    clk_rst_vif();
  vip_axi4_if #(VIP_AXI4_CFG_C, VIP_AXI4_ROLE_MANAGER_E) mst_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);
  vip_axi4_if #(VIP_AXI4_CFG_C, VIP_AXI4_ROLE_SUBORDINATE_E) mem_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);

  // ---------------------------------------------------------------------------
  // DUT0
  // ---------------------------------------------------------------------------

  // Read Address Channel
  logic                          [VIP_AXI4_CFG_C.ARID_WIDTH_P-1 : 0] slvs_arid0;
  logic                        [VIP_AXI4_CFG_C.ADDR_WIDTH_P-1 : 0] slvs_araddr0;
  logic                                                             [7 : 0] slvs_arlen0;
  logic                                                             [2 : 0] slvs_arsize0;
  logic                                                             [1 : 0] slvs_arburst0;
  logic                                                             [3 : 0] slvs_arregion0;
  logic [NR_OF_SLAVES_C-1 : 0]                                              slvs_arvalid0;
  logic [NR_OF_SLAVES_C-1 : 0]                                              slvs_arready0;

  // Data Channel
  logic [NR_OF_SLAVES_C-1 : 0]   [VIP_AXI4_CFG_C.ARID_WIDTH_P-1 : 0] slvs_rid0;
  logic [NR_OF_SLAVES_C-1 : 0]                                      [1 : 0] slvs_rresp0;
  logic [NR_OF_SLAVES_C-1 : 0] [(8 * VIP_AXI4_CFG_C.RDATA_BYTES_P)-1 : 0] slvs_rdata0;
  logic [NR_OF_SLAVES_C-1 : 0]                                              slvs_rlast0;
  logic [NR_OF_SLAVES_C-1 : 0]                                              slvs_rvalid0;
  logic [NR_OF_SLAVES_C-1 : 0]                                              slvs_rready0;

  // ---------------------------------------------------------------------------
  // DUT1
  // ---------------------------------------------------------------------------

  // Read Address Channel
  logic [NR_OF_SLAVES_C-1 : 0]   [VIP_AXI4_CFG_C.ARID_WIDTH_P-1 : 0] slvs_arid;
  logic [NR_OF_SLAVES_C-1 : 0] [VIP_AXI4_CFG_C.ADDR_WIDTH_P-1 : 0] slvs_araddr;
  logic [NR_OF_SLAVES_C-1 : 0]                                      [7 : 0] slvs_arlen;
  logic [NR_OF_SLAVES_C-1 : 0]                                      [2 : 0] slvs_arsize;
  logic [NR_OF_SLAVES_C-1 : 0]                                      [1 : 0] slvs_arburst;
  logic [NR_OF_SLAVES_C-1 : 0]                                      [3 : 0] slvs_arregion;
  logic [NR_OF_SLAVES_C-1 : 0]                                              slvs_arvalid;
  logic [NR_OF_SLAVES_C-1 : 0]                                              slvs_arready;

  // Data Channel
  logic                          [VIP_AXI4_CFG_C.ARID_WIDTH_P-1 : 0] slvs_rid;
  logic                                                             [1 : 0] slvs_rresp;
  logic                        [(8 * VIP_AXI4_CFG_C.RDATA_BYTES_P)-1 : 0] slvs_rdata;
  logic                                                                     slvs_rlast;
  logic [NR_OF_SLAVES_C-1 : 0]                                              slvs_rvalid;
  logic [NR_OF_SLAVES_C-1 : 0]                                              slvs_rready;



  assign slvs_arid     = { NR_OF_SLAVES_C{slvs_arid0}     };
  assign slvs_araddr   = { NR_OF_SLAVES_C{slvs_araddr0}   };
  assign slvs_arlen    = { NR_OF_SLAVES_C{slvs_arlen0}    };
  assign slvs_arsize   = { NR_OF_SLAVES_C{slvs_arsize0}   };
  assign slvs_arburst  = { NR_OF_SLAVES_C{slvs_arburst0}  };
  assign slvs_arregion = { NR_OF_SLAVES_C{slvs_arregion0} };

  assign slvs_arvalid  = slvs_arvalid0;
  assign slvs_arready0 = slvs_arready;

  assign slvs_rid0     = { NR_OF_SLAVES_C{slvs_rid}   };
  assign slvs_rresp0   = { NR_OF_SLAVES_C{slvs_rresp} };
  assign slvs_rdata0   = { NR_OF_SLAVES_C{slvs_rdata} };
  assign slvs_rlast0   = { NR_OF_SLAVES_C{slvs_rlast} };

  assign slvs_rvalid0  = slvs_rvalid;
  assign slvs_rready   = slvs_rready0;

  // ---------------------------------------------------------------------------
  // DUT0: One Master to (NR_OF_SLAVES_C) Slaves
  // ---------------------------------------------------------------------------
  axi4_read_arbiter #(
    .AXI_ID_WIDTH_P   ( VIP_AXI4_CFG_C.ARID_WIDTH_P   ),
    .AXI_ADDR_WIDTH_P ( VIP_AXI4_CFG_C.ADDR_WIDTH_P ),
    .AXI_DATA_WIDTH_P ( (8 * VIP_AXI4_CFG_C.RDATA_BYTES_P) ),
    .NR_OF_MASTERS_P  ( 1                                    ),
    .NR_OF_SLAVES_P   ( NR_OF_SLAVES_C                       )
  ) axi4_read_arbiter_i0 (

    // Clock and reset
    .clk              ( clk_rst_vif.clk                      ), // input
    .rst_n            ( clk_rst_vif.rst_n                    ), // input

    // -------------------------------------------------------------------------
    // AXI4 Masters
    // -------------------------------------------------------------------------

    // Read Address Channel
    .mst_arid         ( mst_vif.arid                         ), // input
    .mst_araddr       ( mst_vif.araddr                       ), // input
    .mst_arlen        ( mst_vif.arlen                        ), // input
    .mst_arvalid      ( mst_vif.arvalid                      ), // input
    .mst_arsize       ( mst_vif.arsize                       ), // input
    .mst_arburst      ( mst_vif.arburst                      ), // input
    .mst_arregion     ( mst_vif.arregion                     ), // input
    .mst_arready      ( mst_vif.arready                      ), // output

    // Read Data Channel
    .mst_rid          ( mst_vif.rid                          ), // output
    .mst_rresp        ( mst_vif.rresp                        ), // output
    .mst_rdata        ( mst_vif.rdata                        ), // output
    .mst_rlast        ( mst_vif.rlast                        ), // output
    .mst_rvalid       ( mst_vif.rvalid                       ), // output
    .mst_rready       ( mst_vif.rready                       ), // input

    // -------------------------------------------------------------------------
    // AXI4 Slave
    // -------------------------------------------------------------------------

    // Read Address Channel
    .slv_arid         ( slvs_arid0                           ), // output
    .slv_araddr       ( slvs_araddr0                         ), // output
    .slv_arlen        ( slvs_arlen0                          ), // output
    .slv_arsize       ( slvs_arsize0                         ), // output
    .slv_arburst      ( slvs_arburst0                        ), // output
    .slv_arregion     ( slvs_arregion0                       ), // output
    .slv_arvalid      ( slvs_arvalid0                        ), // output
    .slv_arready      ( slvs_arready0                        ), // input

    // Read Data Channel
    .slv_rid          ( slvs_rid0                            ), // input
    .slv_rresp        ( slvs_rresp0                          ), // input
    .slv_rdata        ( slvs_rdata0                          ), // input
    .slv_rlast        ( slvs_rlast0                          ), // input
    .slv_rvalid       ( slvs_rvalid0                         ), // input
    .slv_rready       ( slvs_rready0                         )  // output
  );

  // ---------------------------------------------------------------------------
  // DUT1: (NR_OF_SLAVES_C) Masters to one slave
  // ---------------------------------------------------------------------------
  axi4_read_arbiter #(
    .AXI_ID_WIDTH_P   ( VIP_AXI4_CFG_C.ARID_WIDTH_P   ),
    .AXI_ADDR_WIDTH_P ( VIP_AXI4_CFG_C.ADDR_WIDTH_P ),
    .AXI_DATA_WIDTH_P ( (8 * VIP_AXI4_CFG_C.RDATA_BYTES_P) ),
    .NR_OF_MASTERS_P  ( NR_OF_SLAVES_C                       ),
    .NR_OF_SLAVES_P   ( 1                                    )
  ) axi4_read_arbiter_i1 (

    // Clock and reset
    .clk              ( clk_rst_vif.clk                      ), // input
    .rst_n            ( clk_rst_vif.rst_n                    ), // input

    // -------------------------------------------------------------------------
    // AXI4 Masters
    // -------------------------------------------------------------------------

    // Read Address Channel
    .mst_arid         ( slvs_arid                            ), // input
    .mst_araddr       ( slvs_araddr                          ), // input
    .mst_arlen        ( slvs_arlen                           ), // input
    .mst_arsize       ( slvs_arsize                          ), // input
    .mst_arburst      ( slvs_arburst                         ), // input
    .mst_arregion     ( slvs_arregion                        ), // input
    .mst_arvalid      ( slvs_arvalid                         ), // input
    .mst_arready      ( slvs_arready                         ), // output

    // Read Data Channel
    .mst_rid          ( slvs_rid                             ), // output
    .mst_rresp        ( slvs_rresp                           ), // output
    .mst_rdata        ( slvs_rdata                           ), // output
    .mst_rlast        ( slvs_rlast                           ), // output
    .mst_rvalid       ( slvs_rvalid                          ), // output
    .mst_rready       ( slvs_rready                          ), // input

    // -------------------------------------------------------------------------
    // AXI4 Slave
    // -------------------------------------------------------------------------

    // Read Address Channel
    .slv_arid         ( mem_vif.arid                         ), // output
    .slv_araddr       ( mem_vif.araddr                       ), // output
    .slv_arlen        ( mem_vif.arlen                        ), // output
    .slv_arsize       ( mem_vif.arsize                       ), // output
    .slv_arburst      ( mem_vif.arburst                      ), // output
    .slv_arregion     ( mem_vif.arregion                     ), // output
    .slv_arvalid      ( mem_vif.arvalid                      ), // output
    .slv_arready      ( mem_vif.arready                      ), // input

    // Read Data Channel
    .slv_rid          ( mem_vif.rid                          ), // input
    .slv_rresp        ( mem_vif.rresp                        ), // input
    .slv_rdata        ( mem_vif.rdata                        ), // input
    .slv_rlast        ( mem_vif.rlast                        ), // input
    .slv_rvalid       ( mem_vif.rvalid                       ), // input
    .slv_rready       ( mem_vif.rready                       )  // output
  );


  initial begin
    uvm_config_db #(virtual clk_rst_if)::set(uvm_root::get(),                    "uvm_test_top.tb_env*",                "vif", clk_rst_vif);
    uvm_config_db #(virtual clk_rst_if)::set(uvm_root::get(),                    "uvm_test_top.tb_env.clk_rst_agent0*", "vif", clk_rst_vif);
    uvm_config_db #(virtual vip_axi4_if #(VIP_AXI4_CFG_C, VIP_AXI4_ROLE_MANAGER_E))::set(uvm_root::get(), "uvm_test_top.tb_env.rd_agent0*",      "vif", mst_vif);
    uvm_config_db #(virtual vip_axi4_if #(VIP_AXI4_CFG_C, VIP_AXI4_ROLE_SUBORDINATE_E))::set(uvm_root::get(), "uvm_test_top.tb_env.mem_agent0*",     "vif", mem_vif);
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
