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
  vip_axi4s_if #(VIP_AXI4S_CFG_C) mst_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);
  vip_axi4s_if #(VIP_AXI4S_CFG_C) slv_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);

  logic [M_C-1 : 0] x0;
  logic [M_C-1 : 0] x1;
  logic [M_C-1 : 0] y;

  assign x0 = mst_vif.tdata[M_C-1   : 0];
  assign x1 = mst_vif.tdata[2*M_C-1 : M_C];

  assign mst_vif.tready = '1;
  assign slv_vif.tvalid = mst_vif.tvalid;
  assign slv_vif.tlast  = mst_vif.tlast;
  assign {slv_vif.tstrb, slv_vif.tkeep, slv_vif.tid, slv_vif.tdest} = '0;
  assign slv_vif.tdata = {'0, y};

  gf_mul_classic #(
    .M_P   ( M_C               )
  ) gf_mul_classic_i0 (
    .clk   ( clk_rst_vif.clk   ), // input
    .rst_n ( clk_rst_vif.rst_n ), // input
    .x0    ( x0                ), // input
    .x1    ( x1                ), // input
    .y     ( y                 )  // output
  );


  classic_multiplication classic_multiplication_i0 (
    .a ( x0 ), // input
    .b ( x1 ), // input
    .c (    )  // output
  );


  initial begin
    uvm_config_db #(virtual clk_rst_if)::set(uvm_root::get(),                      "uvm_test_top.tb_env*",            "vif", clk_rst_vif);
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
