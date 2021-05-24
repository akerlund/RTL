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
  vip_axi4s_if #(VIP_AXI4S_CFG_C) mst_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);

  axi4_reg_if  #(
    .AXI4_ID_WIDTH_P   ( VIP_REG_CFG_C.VIP_AXI4_ID_WIDTH_P   ),
    .AXI4_ADDR_WIDTH_P ( VIP_REG_CFG_C.VIP_AXI4_ADDR_WIDTH_P ),
    .AXI4_DATA_WIDTH_P ( VIP_REG_CFG_C.VIP_AXI4_DATA_WIDTH_P ),
    .AXI4_STRB_WIDTH_P ( VIP_REG_CFG_C.VIP_AXI4_STRB_WIDTH_P )
  ) osc_cfg_if (clk_rst_vif.clk, clk_rst_vif.rst_n);


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
