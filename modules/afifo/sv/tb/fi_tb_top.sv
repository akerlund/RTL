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

module fi_tb_top;

  clk_rst_if                      clk_rst_vif0();
  clk_rst_if                      clk_rst_vif1();
  vip_axi4s_if #(VIP_AXI4S_CFG_C) mst_vif(clk_rst_vif0.clk, clk_rst_vif0.rst_n);
  vip_axi4s_if #(VIP_AXI4S_CFG_C) slv_vif(clk_rst_vif1.clk, clk_rst_vif1.rst_n);

  logic [FIFO_DATA_WIDTH_C-1 : 0] ing_tuser;
  logic [FIFO_DATA_WIDTH_C-1 : 0] egr_tuser;
  logic                           wp_fifo_full;
  logic                           rp_fifo_empty;
  logic                           rp_read_en;

  assign ing_tuser = {mst_vif.tlast, mst_vif.tdata};
  assign mst_vif.tready = !wp_fifo_full;
  assign {slv_vif.tlast, slv_vif.tdata} = egr_tuser;
  assign slv_vif.tstrb = '1;
  assign slv_vif.tkeep = '1;
  assign slv_vif.tid   = '0;
  assign slv_vif.tdest = '0;
  assign slv_vif.tuser = '0;

  assign rp_read_en     = slv_vif.tvalid && slv_vif.tready;
  assign slv_vif.tvalid = !rp_fifo_empty;

  afifo #(
    .DATA_WIDTH_P         ( FIFO_DATA_WIDTH_C  ),
    .ADDR_WIDTH_P         ( FIFO_ADDR_WIDTH_C  )
  ) afifo_i0 (
    .clk_wp               ( clk_rst_vif0.clk   ), // input
    .rst_wp_n             ( clk_rst_vif0.rst_n ), // input
    .clk_rp               ( clk_rst_vif1.clk   ), // input
    .rst_rp_n             ( clk_rst_vif1.rst_n ), // input
    .wp_write_en          ( mst_vif.tvalid &&
                            mst_vif.tready     ), // input
    .wp_data_in           ( ing_tuser          ), // input
    .wp_fifo_full         ( wp_fifo_full       ), // output
    .rp_read_en           ( rp_read_en         ), // input
    .rp_data_out          ( egr_tuser          ), // output
    .rp_fifo_empty        ( rp_fifo_empty      ), // output
    .sr_wp_fill_level     (                    ), // output
    .sr_wp_max_fill_level (                    ), // output
    .sr_rp_fill_level     (                    )  // output
  );

  initial begin
    uvm_config_db #(virtual clk_rst_if)::set(uvm_root::get(),                      "uvm_test_top.tb_env",                 "vif", clk_rst_vif0);
    uvm_config_db #(virtual clk_rst_if)::set(uvm_root::get(),                      "uvm_test_top.tb_env.clk_rst_agent0*", "vif", clk_rst_vif0);
    uvm_config_db #(virtual clk_rst_if)::set(uvm_root::get(),                      "uvm_test_top.tb_env.clk_rst_agent1*", "vif", clk_rst_vif1);
    uvm_config_db #(virtual vip_axi4s_if #(VIP_AXI4S_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.mst_agent0*",     "vif", mst_vif);
    uvm_config_db #(virtual vip_axi4s_if #(VIP_AXI4S_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.slv_agent0*",     "vif", slv_vif);
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
