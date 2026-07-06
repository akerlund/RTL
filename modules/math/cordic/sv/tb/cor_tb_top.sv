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
