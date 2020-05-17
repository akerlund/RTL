////////////////////////////////////////////////////////////////////////////////
//
// Copyright 2020 Fredrik Åkerlund
//
// This library is free software; you can redistribute it and/or
// modify it under the terms of the GNU Lesser General Public
// License as published by the Free Software Foundation; either
// version 2.1 of the License, or (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public
// License along with this library; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
//
// Description:
//
////////////////////////////////////////////////////////////////////////////////

import uvm_pkg::*;
import hsl_tb_pkg::*;
import hsl_tc_pkg::*;

module hsl_tb_top;

  bit clk;
  bit rst_n;

  time clk_period = 10ns;

  // IF
  vip_axi4s_if #(vip_axi4s_cfg) mst0_vif(clk, rst_n);
  vip_axi4s_if #(vip_axi4s_cfg) slv0_vif(clk, rst_n);



  axi4s_hsl_if #(
    .AXI_ID_WIDTH_P ( vip_axi4s_cfg.AXI_ID_WIDTH_P )
  ) axi4s_hsl_if_i0 (
    // Clock and reset
    .clk            ( clk                          ), // input
    .rst_n          ( rst_n                        ), // input

    // AXI4-S master side
    .ing_tvalid     ( mst0_vif.tvalid              ), // input
    .ing_tready     ( mst0_vif.tready              ), // output
    .ing_tdata      ( mst0_vif.tdata               ), // input
    .ing_tid        ( mst0_vif.tid                 ), // input

    // AXI4-S slave side
    .egr_tvalid     ( slv0_vif.tvalid              ), // output
    .egr_tready     ( slv0_vif.tready              ), // input
    .egr_tdata      ( slv0_vif.tdata               ), // output
    .egr_tid        ( slv0_vif.tid                 )  // output
  );

  // The "axi4s_hsl_if" has no "tlast" but always outputs only one transaction at the time
  assign slv0_vif.tlast = '1;


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
