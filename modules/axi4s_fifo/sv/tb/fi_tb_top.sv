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
import fi_tb_pkg::*;
import fi_tc_pkg::*;

module axi4s_fifo_top;

  clk_rst_if                      clk_rst_vif();
  vip_axi4s_if #(VIP_AXI4S_CFG_C) mst_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);
  vip_axi4s_if #(VIP_AXI4S_CFG_C) slv_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);

  logic [FIFO_USER_WIDTH_C-1 : 0] ing_tuser;
  logic [FIFO_USER_WIDTH_C-1 : 0] egr_tuser;

  assign ing_tuser = {mst_vif.tlast, mst_vif.tdata};
  assign {slv_vif.tlast, slv_vif.tdata} = egr_tuser;

  assign {slv_vif.tstrb, slv_vif.tkeep, slv_vif.tid, slv_vif.tdest, slv_vif.tuser} = '0;

  axi4s_fifo #(
    .TUSER_WIDTH_P        ( FIFO_USER_WIDTH_C ),
    .ADDR_WIDTH_P         ( FIFO_ADDR_WIDTH_C )
  ) axi4s_fifo_i0 (
    .clk                  ( clk_rst_vif.clk   ), // input
    .rst_n                ( clk_rst_vif.rst_n ), // input
    .ing_tready           ( mst_vif.tready    ), // output
    .ing_tuser            ( ing_tuser         ), // input
    .ing_tvalid           ( mst_vif.tvalid    ), // input
    .egr_tready           ( slv_vif.tready    ), // input
    .egr_tuser            ( egr_tuser         ), // output
    .egr_tvalid           ( slv_vif.tvalid    ), // output
    .sr_fill_level        (                   ), // output
    .sr_max_fill_level    (                   ), // output
    .sr_almost_full       (                   ), // output
    .cr_almost_full_level ( '0                )  // input
  );


  initial begin
    uvm_config_db #(virtual clk_rst_if)::set(uvm_root::get(),                      "uvm_test_top.tb_env*",            "vif", clk_rst_vif);
    uvm_config_db #(virtual vip_axi4s_if #(VIP_AXI4S_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.mst_agent0*", "vif", mst_vif);
    uvm_config_db #(virtual vip_axi4s_if #(VIP_AXI4S_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.slv_agent0*", "vif", slv_vif);
    uvm_root::get().set_timeout(150_000_000, 0);
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
