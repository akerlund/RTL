////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2021 Fredrik Åkerlund
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
import fir_tb_pkg::*;
import fir_tc_pkg::*;

module fir_tb_top;

  clk_rst_if                      clk_rst_vif();
  vip_axi4_if    #(VIP_REG_CFG_C) reg_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);
  vip_axi4_if    #(VIP_MEM_CFG_C) mem_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);
  vip_axi4s_if #(VIP_AXI4S_CFG_C) mst_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);

  axi4_reg_if #(
    .AXI4_ID_WIDTH_P   ( VIP_REG_CFG_C.VIP_AXI4_ID_WIDTH_P   ),
    .AXI4_ADDR_WIDTH_P ( VIP_REG_CFG_C.VIP_AXI4_ADDR_WIDTH_P ),
    .AXI4_DATA_WIDTH_P ( VIP_REG_CFG_C.VIP_AXI4_DATA_WIDTH_P ),
    .AXI4_STRB_WIDTH_P ( VIP_REG_CFG_C.VIP_AXI4_STRB_WIDTH_P )
  ) osc_cfg_if (clk_rst_vif.clk, clk_rst_vif.rst_n);

  axi4_if  #(
    .ID_WIDTH_P   ( 4   ),
    .ADDR_WIDTH_P ( 10  ),
    .DATA_WIDTH_P ( 128 )
  ) fir_axi4_if();


  // Register slave
  assign osc_cfg_if.awaddr  = reg_vif.awaddr;
  assign osc_cfg_if.awvalid = reg_vif.awvalid;
  assign reg_vif.awready    = osc_cfg_if.awready;
  assign osc_cfg_if.wdata   = reg_vif.wdata;
  assign osc_cfg_if.wstrb   = reg_vif.wstrb;
  assign osc_cfg_if.wlast   = reg_vif.wlast;
  assign osc_cfg_if.wvalid  = reg_vif.wvalid;
  assign reg_vif.wready     = osc_cfg_if.wready;
  assign reg_vif.bresp      = osc_cfg_if.bresp;
  assign reg_vif.bvalid     = osc_cfg_if.bvalid;
  assign osc_cfg_if.bready  = reg_vif.bready;
  assign osc_cfg_if.araddr  = reg_vif.araddr;
  assign osc_cfg_if.arlen   = reg_vif.arlen;
  assign osc_cfg_if.arvalid = reg_vif.arvalid;
  assign reg_vif.arready    = osc_cfg_if.arready;
  assign reg_vif.rdata      = osc_cfg_if.rdata;
  assign reg_vif.rresp      = osc_cfg_if.rresp;
  assign reg_vif.rlast      = osc_cfg_if.rlast;
  assign reg_vif.rvalid     = osc_cfg_if.rvalid;
  assign osc_cfg_if.rready  = reg_vif.rready;

  // Memory controller
  assign mem_vif.awid        = fir_axi4_if.awid;
  assign mem_vif.awaddr      = fir_axi4_if.awaddr;
  assign mem_vif.awlen       = fir_axi4_if.awlen;
  assign mem_vif.awsize      = fir_axi4_if.awsize;
  assign mem_vif.awburst     = fir_axi4_if.awburst;
  assign mem_vif.awvalid     = fir_axi4_if.awvalid;
  assign fir_axi4_if.awready = mem_vif.awready;
  assign mem_vif.wdata       = fir_axi4_if.wdata;
  assign mem_vif.wstrb       = fir_axi4_if.wstrb;
  assign mem_vif.wlast       = fir_axi4_if.wlast;
  assign mem_vif.wvalid      = fir_axi4_if.wvalid;
  assign fir_axi4_if.wready  = mem_vif.wready;
  assign fir_axi4_if.bid     = mem_vif.bid;
  assign fir_axi4_if.bresp   = mem_vif.bresp;
  assign fir_axi4_if.bvalid  = mem_vif.bvalid;
  assign mem_vif.bready      = fir_axi4_if.bready;
  assign mem_vif.arid        = fir_axi4_if.arid;
  assign mem_vif.araddr      = fir_axi4_if.araddr;
  assign mem_vif.arlen       = fir_axi4_if.arlen;
  assign mem_vif.arsize      = fir_axi4_if.arsize;
  assign mem_vif.arvalid     = fir_axi4_if.arvalid;
  assign fir_axi4_if.arready = mem_vif.arready;
  assign mem_vif.rid         = fir_axi4_if.rid;
  assign mem_vif.rdata       = fir_axi4_if.rdata;
  assign mem_vif.rresp       = fir_axi4_if.rresp;
  assign mem_vif.rlast       = fir_axi4_if.rlast;
  assign fir_axi4_if.rvalid  = mem_vif.rvalid;
  assign mem_vif.rready      = fir_axi4_if.rready;


  iir_comb_top #(
    .N_BITS_P                ( N_BITS_C                ),
    .Q_BITS_P                ( Q_BITS_C                ),
    .MEM_BASE_ADDR_P         ( MEM_BASE_ADDR_C         ),
    .MEM_HIGH_ADDR_P         ( MEM_HIGH_ADDR_C         ),
    .MEM_ADDR_WIDTH_P        ( MEM_ADDR_WIDTH_C        ),
    .MEM_DATA_WIDTH_P        ( MEM_DATA_WIDTH_C        ),
    .AXI4_ID_P               ( AXI4_ID_C               )
  ) iir_comb_top_i0 (
    // Clock and reset
    .clk                     ( clk_rst_vif.clk         ), // input
    .rst_n                   ( clk_rst_vif.rst_n       ), // input

    // Data
    .x                       ( mst_vif.tdata           ), // input
    .x_valid                 ( mst_vif.tvalid          ), // input
    .y                       (                         ), // output
    .y_valid                 (                         ), // output

    // AXI4 memory
    .mc                      ( fir_axi4_if             ), // interface

    // Configuration
    .cmd_fir_calculate_delay ( cmd_fir_calculate_delay ), // input
    .cr_fir_delay_time       ( cr_fir_delay_time       ), // input
    .cr_fir_delay_gain       ( cr_fir_delay_gain       )  // input
  );


  fir_axi_slave #(
    .AXI_ADDR_WIDTH_P        ( 16                      ),
    .AXI_DATA_WIDTH_P        ( 64                      ),
    .AXI_ID_P                ( 0                       ),
    .N_BITS_C                ( N_BITS_C                )
  ) fir_axi_slave_i0 (
    .cif                     ( osc_cfg_if              ), // interface
    .cmd_fir_calculate_delay ( cmd_fir_calculate_delay ), // output
    .cr_fir_delay_time       ( cr_fir_delay_time       ), // output
    .cr_fir_delay_gain       ( cr_fir_delay_gain       )  // output
  );

  initial begin
    uvm_config_db #(virtual clk_rst_if)::set(uvm_root::get(),                      "uvm_test_top.tb_env*",            "vif", clk_rst_vif);
    uvm_config_db #(virtual vip_axi4_if  #(VIP_REG_CFG_C))::set(uvm_root::get(),   "uvm_test_top.tb_env.reg_agent0*", "vif", reg_vif);
    uvm_config_db #(virtual vip_axi4s_if #(VIP_AXI4S_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.mst_agent0*", "vif", mst_vif);
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
