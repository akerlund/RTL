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
import ara_tb_pkg::*;
import ara_tc_pkg::*;

module ara_tb_top;

  // IF
  clk_rst_if                    clk_rst_vif();
  vip_axi4_if #(VIP_AXI4_CFG_C) mst_vif0(clk_rst_vif.clk, clk_rst_vif.rst_n);
  vip_axi4_if #(VIP_AXI4_CFG_C) mst_vif1(clk_rst_vif.clk, clk_rst_vif.rst_n);
  vip_axi4_if #(VIP_AXI4_CFG_C) mst_vif2(clk_rst_vif.clk, clk_rst_vif.rst_n);
  vip_axi4_if #(VIP_AXI4_CFG_C) mem_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);

  // Read Address Channel
  logic [0 : NR_OF_MASTERS_C-1]   [VIP_AXI4_CFG_C.VIP_AXI4_ID_WIDTH_P-1 : 0] mst_arid;
  logic [0 : NR_OF_MASTERS_C-1] [VIP_AXI4_CFG_C.VIP_AXI4_ADDR_WIDTH_P-1 : 0] mst_araddr;
  logic [0 : NR_OF_MASTERS_C-1]                                      [7 : 0] mst_arlen;
  logic [0 : NR_OF_MASTERS_C-1]                                              mst_arvalid;
  logic [0 : NR_OF_MASTERS_C-1]                                              mst_arready;

  // Read Data Channel
  logic                           [VIP_AXI4_CFG_C.VIP_AXI4_ID_WIDTH_P-1 : 0] mst_rid;
  logic                         [VIP_AXI4_CFG_C.VIP_AXI4_DATA_WIDTH_P-1 : 0] mst_rdata;
  logic                                                                      mst_rlast;
  logic [0 : NR_OF_MASTERS_C-1]                                              mst_rvalid;
  logic [0 : NR_OF_MASTERS_C-1]                                              mst_rready;

  // ---------------------------------------------------------------------------
  // Connecting the Agents to the DUT
  // ---------------------------------------------------------------------------

  // Master 0
  assign mst_arid[0]      = mst_vif0.arid;
  assign mst_araddr[0]    = mst_vif0.araddr;
  assign mst_arlen[0]     = mst_vif0.arlen;
  assign mst_arvalid[0]   = mst_vif0.arvalid;
  assign mst_vif0.arready = mst_arready[0];

  assign mst_vif0.rid     = mst_rid;
  assign mst_vif0.rdata   = mst_rdata;
  assign mst_vif0.rlast   = mst_rlast;
  assign mst_vif0.rvalid  = mst_rvalid[0];
  assign mst_rready[0]    = mst_vif0.rready;

  // Master 1
  assign mst_arid[1]      = mst_vif1.arid;
  assign mst_araddr[1]    = mst_vif1.araddr;
  assign mst_arlen[1]     = mst_vif1.arlen;
  assign mst_arvalid[1]   = mst_vif1.arvalid;
  assign mst_vif1.arready = mst_arready[1];

  assign mst_vif1.rid     = mst_rid;
  assign mst_vif1.rdata   = mst_rdata;
  assign mst_vif1.rlast   = mst_rlast;
  assign mst_vif1.rvalid  = mst_rvalid[1];
  assign mst_rready[1]    = mst_vif1.rready;

  // Master 2
  assign mst_arid[2]      = mst_vif2.arid;
  assign mst_araddr[2]    = mst_vif2.araddr;
  assign mst_arlen[2]     = mst_vif2.arlen;
  assign mst_arvalid[2]   = mst_vif2.arvalid;
  assign mst_vif2.arready = mst_arready[2];

  assign mst_vif2.rid     = mst_rid;
  assign mst_vif2.rdata   = mst_rdata;
  assign mst_vif2.rlast   = mst_rlast;
  assign mst_vif2.rvalid  = mst_rvalid[2];
  assign mst_rready[2]    = mst_vif2.rready;

  // ---------------------------------------------------------------------------
  // Grounding the unused signals of the Agents
  // ---------------------------------------------------------------------------

  assign mst_vif0.rresp   = '0;
  assign mst_vif0.ruser   = '0;

  assign mst_vif1.rresp   = '0;
  assign mst_vif1.ruser   = '0;

  assign mst_vif2.rresp   = '0;
  assign mst_vif2.ruser   = '0;

  assign mem_vif.arregion = '0;
  assign mem_vif.aruser   = '0;
  assign mem_vif.arsize   = 3'b010;
  assign mem_vif.arburst  = 2'b01;

  // DUT
  axi4_read_arbiter #(
    .AXI_ID_WIDTH_P   ( VIP_AXI4_CFG_C.VIP_AXI4_ID_WIDTH_P   ),
    .AXI_ADDR_WIDTH_P ( VIP_AXI4_CFG_C.VIP_AXI4_ADDR_WIDTH_P ),
    .AXI_DATA_WIDTH_P ( VIP_AXI4_CFG_C.VIP_AXI4_DATA_WIDTH_P ),
    .NR_OF_MASTERS_P  ( NR_OF_MASTERS_C                      )
  ) axi4_read_arbiter_i0 (

    // Clock and reset
    .clk              ( clk_rst_vif.clk                      ), // input
    .rst_n            ( clk_rst_vif.rst_n                    ), // input

    // -------------------------------------------------------------------------
    // AXI4 Masters
    // -------------------------------------------------------------------------

    // Read Address Channel
    .mst_arid         ( mst_arid                             ), // input
    .mst_araddr       ( mst_araddr                           ), // input
    .mst_arlen        ( mst_arlen                            ), // input
    .mst_arvalid      ( mst_arvalid                          ), // input
    .mst_arready      ( mst_arready                          ), // output

    // Read Data Channel
    .mst_rid          ( mst_rid                              ), // output
    .mst_rdata        ( mst_rdata                            ), // output
    .mst_rlast        ( mst_rlast                            ), // output
    .mst_rvalid       ( mst_rvalid                           ), // output
    .mst_rready       ( mst_rready                           ), // input

    // -------------------------------------------------------------------------
    // AXI4 Slave
    // -------------------------------------------------------------------------

    // Read Address Channel
    .slv_arid         ( mem_vif.arid                         ), // output
    .slv_araddr       ( mem_vif.araddr                       ), // output
    .slv_arlen        ( mem_vif.arlen                        ), // output
    .slv_arsize       (                                      ), // output
    .slv_arburst      (                                      ), // output
    .slv_arlock       ( mem_vif.arlock                       ), // output
    .slv_arcache      ( mem_vif.arcache                      ), // output
    .slv_arprot       ( mem_vif.arprot                       ), // output
    .slv_arqos        ( mem_vif.arqos                        ), // output
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
    uvm_config_db #(virtual vip_axi4_if #(VIP_AXI4_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.rd_agent0*",      "vif", mst_vif0);
    uvm_config_db #(virtual vip_axi4_if #(VIP_AXI4_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.rd_agent1*",      "vif", mst_vif1);
    uvm_config_db #(virtual vip_axi4_if #(VIP_AXI4_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.rd_agent2*",      "vif", mst_vif2);
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
