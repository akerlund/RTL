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
import iir_tb_pkg::*;
import iir_tc_pkg::*;

module iir_tb_top;

  clk_rst_if                      clk_rst_vif();
  vip_axi4_if    #(VIP_REG_CFG_C) reg_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);
  vip_axi4s_if #(VIP_AXI4S_CFG_C) mst_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);
  vip_axi4s_if #(VIP_AXI4S_CFG_C) slv_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);

  logic [FIFO_USER_WIDTH_C-1 : 0] ing_tuser;
  logic [FIFO_USER_WIDTH_C-1 : 0] egr_tuser;

  assign ing_tuser = {mst_vif.tlast, mst_vif.tdata};
  assign {slv_vif.tlast, slv_vif.tdata} = egr_tuser;

  assign {slv_vif.tstrb, slv_vif.tkeep, slv_vif.tid, slv_vif.tdest} = '0;


  initial begin
    uvm_config_db #(virtual clk_rst_if)::set(uvm_root::get(),                      "uvm_test_top.tb_env*",            "vif", clk_rst_vif);
    uvm_config_db #(virtual vip_axi4_if  #(VIP_REG_CFG_C))::set(uvm_root::get(),   "uvm_test_top.tb_env.reg_agent0*", "vif", reg_vif);
    uvm_config_db #(virtual vip_axi4s_if #(VIP_AXI4S_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.mst_agent0*", "vif", mst_vif);
    uvm_config_db #(virtual vip_axi4s_if #(VIP_AXI4S_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.slv_agent0*", "vif", slv_vif);
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
