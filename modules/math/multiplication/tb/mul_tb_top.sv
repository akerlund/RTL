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
import mul_tb_pkg::*;
import mul_tc_pkg::*;

module mul_tb_top;

  // IF
  clk_rst_if                      clk_rst_vif();
  vip_axi4s_if #(VIP_AXI4S_CFG_C) mst_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);
  vip_axi4s_if #(VIP_AXI4S_CFG_C) slv_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);

  `ifndef DSP48

  nq_multiplier_axi4s_if #(
    .AXI_DATA_WIDTH_P ( N_BITS_C          ),
    .AXI_ID_WIDTH_P   ( TID_WIDTH_C       ),
    .N_BITS_P         ( N_BITS_C          ),
    .Q_BITS_P         ( Q_BITS_C          )
  ) nq_multiplier_axi4s_if_i0 (
    .clk              ( clk_rst_vif.clk   ),
    .rst_n            ( clk_rst_vif.rst_n ),

    .ing_tvalid       ( mst_vif.tvalid    ),
    .ing_tready       ( mst_vif.tready    ),
    .ing_tdata        ( mst_vif.tdata     ),
    .ing_tlast        ( mst_vif.tlast     ),
    .ing_tid          ( mst_vif.tid       ),

    .egr_tvalid       ( slv_vif.tvalid    ),
    .egr_tdata        ( slv_vif.tdata     ),
    .egr_tlast        ( slv_vif.tlast     ),
    .egr_tid          ( slv_vif.tid       ),
    .egr_tuser        ( slv_vif.tuser     )
  );

  `else

  dsp48_multiplier_axi4s_if #(
    .AXI_DATA_WIDTH_P ( N_BITS_C          ),
    .AXI_ID_WIDTH_P   ( TID_WIDTH_C       ),
    .N_BITS_P         ( N_BITS_C          ),
    .Q_BITS_P         ( Q_BITS_C          )
  ) dsp48_multiplier_axi4s_if_i0 (
    .clk              ( clk_rst_vif.clk   ),
    .rst_n            ( clk_rst_vif.rst_n ),

    .ing_tvalid       ( mst_vif.tvalid    ),
    .ing_tready       ( mst_vif.tready    ),
    .ing_tdata        ( mst_vif.tdata     ),
    .ing_tlast        ( mst_vif.tlast     ),
    .ing_tid          ( mst_vif.tid       ),

    .egr_tvalid       ( slv_vif.tvalid    ),
    .egr_tdata        ( slv_vif.tdata     ),
    .egr_tlast        ( slv_vif.tlast     ),
    .egr_tid          ( slv_vif.tid       ),
    .egr_tuser        ( slv_vif.tuser     )
  );

  `endif


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
