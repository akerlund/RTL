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
import clk_rst_pkg::*;
import vec_tb_pkg::*;
import vec_tc_pkg::*;

module vec_tb_top;

  // IF
  clk_rst_if                      clk_rst_vif0();
  clk_rst_if                      clk_rst_vif1();
  vip_axi4s_if #(VIP_AXI4S_CFG_C) mst0_vif(clk_rst_vif0.clk, clk_rst_vif0.rst_n);
  vip_axi4s_if #(VIP_AXI4S_CFG_C) slv0_vif(clk_rst_vif0.clk, clk_rst_vif0.rst_n);

  logic [CDC_DATA_WIDTH_C : 0] cdc0_src_vector;
  logic                        cdc0_src_valid;
  logic                        cdc0_src_ready;
  logic [CDC_DATA_WIDTH_C : 0] cdc0_dst_vector;
  logic                        cdc0_dst_valid;

  assign cdc0_src_vector = {mst0_vif.tlast, mst0_vif.tdata};
  assign cdc0_src_valid  = mst0_vif.tvalid;
  assign mst0_vif.tready = cdc0_src_ready;

  logic [CDC_DATA_WIDTH_C : 0] cdc1_src_vector;
  logic                        cdc1_src_valid;
  logic                        cdc1_src_ready;
  logic [CDC_DATA_WIDTH_C : 0] cdc1_dst_vector;
  logic                        cdc1_dst_valid;

  assign cdc1_src_vector = cdc0_dst_vector;
  assign cdc1_src_valid  = cdc0_dst_valid;
  assign {slv0_vif.tlast, slv0_vif.tdata} = cdc1_dst_vector;
  assign slv0_vif.tvalid = cdc1_dst_valid;


  cdc_vector_sync #(
    .DATA_WIDTH_P ( CDC_DATA_WIDTH_C   )
  ) cdc_vector_sync_i0 (
    // Clock and reset (Source)
    .clk_src      ( clk_rst_vif0.clk   ), // input
    .rst_src_n    ( clk_rst_vif0.rst_n ), // input

    // Clock and reset (Destination)
    .clk_dst      ( clk_rst_vif1.clk   ), // input
    .rst_dst_n    ( clk_rst_vif1.rst_n ), // input

    // Data (Source)
    .ing_vector   ( cdc0_src_vector    ), // input
    .ing_valid    ( cdc0_src_valid     ), // input
    .ing_ready    ( cdc0_src_ready     ), // output

    // Data (Destination)
    .egr_vector   ( cdc0_dst_vector    ), // output
    .egr_valid    ( cdc0_dst_valid     ), // output
    .egr_ready    ( cdc1_src_ready     )  // input
  );


  cdc_vector_sync #(
    .DATA_WIDTH_P ( CDC_DATA_WIDTH_C   )
  ) cdc_vector_sync_i1 (
    // Clock and reset (Source)
    .clk_src      ( clk_rst_vif1.clk   ), // input
    .rst_src_n    ( clk_rst_vif1.rst_n ), // input

    // Clock and reset (Destination)
    .clk_dst      ( clk_rst_vif0.clk   ), // input
    .rst_dst_n    ( clk_rst_vif0.rst_n ), // input

    // Data (Source)
    .ing_vector   ( cdc1_src_vector    ), // input
    .ing_valid    ( cdc1_src_valid     ), // input
    .ing_ready    ( cdc1_src_ready     ), // output

    // Data (Destination)
    .egr_vector   ( cdc1_dst_vector    ), // output
    .egr_valid    ( cdc1_dst_valid     ), // output
    .egr_ready    ( slv0_vif.tready    )  // input
  );


  initial begin
    uvm_config_db #(virtual clk_rst_if)::set(uvm_root::get(),                      "uvm_test_top.tb_env.clk_rst_agent0*",       "vif", clk_rst_vif0);
    uvm_config_db #(virtual clk_rst_if)::set(uvm_root::get(),                      "uvm_test_top.tb_env.clk_rst_agent1*",       "vif", clk_rst_vif1);
    uvm_config_db #(virtual vip_axi4s_if #(VIP_AXI4S_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.vip_axi4s_agent_mst0*", "vif", mst0_vif);
    uvm_config_db #(virtual vip_axi4s_if #(VIP_AXI4S_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.vip_axi4s_agent_slv0*", "vif", slv0_vif);
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
