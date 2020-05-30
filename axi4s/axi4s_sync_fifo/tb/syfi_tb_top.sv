////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
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
import syfi_tb_pkg::*;
import syfi_tc_pkg::*;

module syfi_tb_top;

  bit clk;
  bit rst_n;

  time clk_period = 10ns;

  // IF
  vip_axi4s_if #(vip_axi4s_cfg) mst0_vif(clk, rst_n);
  vip_axi4s_if #(vip_axi4s_cfg) slv0_vif(clk, rst_n);

  logic [FIFO_USER_WIDTH_C-1 : 0] ing_tuser;
  logic [FIFO_USER_WIDTH_C-1 : 0] egr_tuser;

  assign ing_tuser = {mst0_vif.tlast, mst0_vif.tdata};
  assign {slv0_vif.tlast, slv0_vif.tdata} = egr_tuser;


  axi4s_sync_fifo #(
    .TUSER_WIDTH_P        ( FIFO_USER_WIDTH_C ),
    .ADDRESS_WIDTH_P      ( FIFO_ADDR_WIDTH_C )
  ) axi4s_sync_fifo_i0 (
    .clk                  ( clk               ), // input
    .rst_n                ( rst_n             ), // input
    .ing_tready           ( mst0_vif.tready   ), // output
    .ing_tuser            ( ing_tuser         ), // input
    .ing_tvalid           ( mst0_vif.tvalid   ), // input
    .egr_tready           ( slv0_vif.tready   ), // input
    .egr_tuser            ( egr_tuser         ), // output
    .egr_tvalid           ( slv0_vif.tvalid   ), // output
    .sr_fill_level        (                   ), // output
    .sr_max_fill_level    (                   ), // output
    .cr_almost_full_level ( '0                )  // input
  );



  initial begin

    uvm_config_db #(virtual vip_axi4s_if #(vip_axi4s_cfg))::set(uvm_root::get(), "uvm_test_top.tb_env.vip_axi4s_agent_mst0*", "vif", mst0_vif);
    uvm_config_db #(virtual vip_axi4s_if #(vip_axi4s_cfg))::set(uvm_root::get(), "uvm_test_top.tb_env.vip_axi4s_agent_slv0*", "vif", slv0_vif);

    run_test();
    $stop();

  end



  initial begin

    // With recording detail you can switch on/off transaction recording.
    if ($test$plusargs("RECORD")) begin
      uvm_config_db #(uvm_verbosity)::set(null,"*", "recording_detail", UVM_FULL);
    end
    else begin
      uvm_config_db #(uvm_verbosity)::set(null,"*", "recording_detail", UVM_NONE);
    end
  end


  // Generate reset
  initial begin

    rst_n = 1'b1;

    #(clk_period*5)

    rst_n = 1'b0;

    #(clk_period*5)

    @(posedge clk);

    rst_n = 1'b1;

  end

  // Generate clock
  always begin
    #(clk_period/2)
    clk = ~clk;
  end

endmodule
