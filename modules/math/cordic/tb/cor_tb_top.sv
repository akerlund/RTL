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
import cor_tb_pkg::*;
import cor_tc_pkg::*;

module cor_tb_top;

  // IF
  clk_rst_if                      clk_rst_vif();
  vip_axi4s_if #(VIP_AXI4S_CFG_C) mst_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);

  assign mst_vif.tready = '1;

  cordic_axi4s_if #(
    .AXI_DATA_WIDTH_P    ( TDATA_WIDTH_C     ),
    .AXI_ID_WIDTH_P      ( TID_WIDTH_C       ),
    .NR_OF_STAGES_P      ( 16                )
  ) cordic_axi4s_if_i0 (
    .clk                 ( clk_rst_vif.clk   ),
    .rst_n               ( clk_rst_vif.rst_n ),
    .ing_tvalid          ( mst_vif.tvalid    ),
    .ing_tdata           ( mst_vif.tdata     ),
    .ing_tid             ( mst_vif.tid       ),
    .ing_tuser           ( '0                ),
    .egr_tvalid          (                   ),
    .egr_tdata           (                   ),
    .egr_tid             (                   )
  );


  initial begin
    uvm_config_db #(virtual clk_rst_if)::set(uvm_root::get(),                      "uvm_test_top.tb_env*",            "vif", clk_rst_vif);
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
