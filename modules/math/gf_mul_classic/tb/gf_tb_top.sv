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
import gf_tb_pkg::*;
import gf_tc_pkg::*;
import gf_ref_pkg::*;

module gf_tb_top;

  clk_rst_if                      clk_rst_vif();
  vip_axi4s_if #(VIP_AXI4S_CFG_C) mst_mul0_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);
  vip_axi4s_if #(VIP_AXI4S_CFG_C) slv_mul0_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);
  vip_axi4s_if #(VIP_AXI4S_CFG_C) mst_div0_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);
  vip_axi4s_if #(VIP_AXI4S_CFG_C) slv_div0_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);

  // ---------------------------------------------------------------------------
  //
  // ---------------------------------------------------------------------------

  logic [M_C-1 : 0] x0_mul0;
  logic [M_C-1 : 0] x1_mul0;
  logic [M_C-1 : 0] y_mul0;

  assign x0_mul0 = mst_mul0_vif.tdata[M_C-1   : 0];
  assign x1_mul0 = mst_mul0_vif.tdata[2*M_C-1 : M_C];

  assign mst_mul0_vif.tready = '1;
  assign slv_mul0_vif.tvalid = mst_mul0_vif.tvalid;
  assign slv_mul0_vif.tlast  = mst_mul0_vif.tlast;
  assign slv_mul0_vif.tdata = {'0, y_mul0};
  assign {slv_mul0_vif.tstrb, slv_mul0_vif.tkeep, slv_mul0_vif.tid, slv_mul0_vif.tdest} = '0;

  gf_mul_classic #(
    .M_P   ( M_C               )
  ) gf_mul_classic_i0 (
    .clk   ( clk_rst_vif.clk   ), // input
    .rst_n ( clk_rst_vif.rst_n ), // input
    .x0    ( x0_mul0           ), // input
    .x1    ( x1_mul0           ), // input
    .y     ( y_mul0            )  // output
  );

  classic_multiplication classic_multiplication_i0 (
    .a ( x0_mul0 ), // input
    .b ( x1_mul0 ), // input
    .c (         )  // output
  );

  // ---------------------------------------------------------------------------
  //
  // ---------------------------------------------------------------------------

  logic [M_C-1 : 0] x0_div0;
  logic [M_C-1 : 0] x1_div0;
  logic [M_C-1 : 0] y_div0;
  logic             y_valid_div0;

  assign x0_div0 = mst_div0_vif.tdata[M_C-1   : 0];
  assign x1_div0 = mst_div0_vif.tdata[2*M_C-1 : M_C];

  assign mst_div0_vif.tready = '1;
  assign slv_div0_vif.tvalid = mst_div0_vif.tvalid;
  assign slv_div0_vif.tlast  = mst_div0_vif.tlast;
  assign slv_div0_vif.tdata = {'0, y_div0};
  assign {slv_div0_vif.tstrb, slv_div0_vif.tkeep, slv_div0_vif.tid, slv_div0_vif.tdest} = '0;

  gf_div_bin_alg gf_div_bin_alg_i0 (
    .clk     ( clk_rst_vif.clk    ), // input
    .rst_n   ( clk_rst_vif.rst_n  ), // input
    .x0      ( x0_div0            ), // input
    .x1      ( x0_div1            ), // input
    .x_valid (mst_div0_vif.tvalid ), // input
    .y       ( y_div0             ), // output
    .y_valid ( y_valid_div0       )  // output
  );

  initial begin
    uvm_config_db #(virtual clk_rst_if)::set(uvm_root::get(),                      "uvm_test_top.tb_env*",                 "vif", clk_rst_vif);
    uvm_config_db #(virtual vip_axi4s_if #(VIP_AXI4S_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.mst_mul0_agent0*", "vif", mst_mul0_vif);
    uvm_config_db #(virtual vip_axi4s_if #(VIP_AXI4S_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.slv_mul0_agent0*", "vif", slv_mul0_vif);
    uvm_config_db #(virtual vip_axi4s_if #(VIP_AXI4S_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.mst_div0_agent0*", "vif", mst_div0_vif);
    uvm_config_db #(virtual vip_axi4s_if #(VIP_AXI4S_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.slv_div0_agent0*", "vif", slv_div0_vif);
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
