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
import div_tb_pkg::*;
import div_tc_pkg::*;

module div_tb_top;

  bit clk;
  bit rst_n;

  time clk_period = 10ns;

  // IF
  vip_axi4s_if #(vip_axi4s_cfg) mst0_vif(clk, rst_n);
  vip_axi4s_if #(vip_axi4s_cfg) slv0_vif(clk, rst_n);


  long_division_axi4s_if #(
    .AXI_DATA_WIDTH_P ( vip_axi4s_cfg.AXI_DATA_WIDTH_P ),
    .AXI_ID_WIDTH_P   ( vip_axi4s_cfg.AXI_ID_WIDTH_P   ),
    .N_BITS_P         ( N_BITS_C                       ),
    .Q_BITS_P         ( Q_BITS_C                       )
  ) long_division_axi4s_if_i0 (
    .clk              ( clk                            ),
    .rst_n            ( rst_n                          ),

    .ing_tvalid       ( mst0_vif.tvalid                ),
    .ing_tready       ( mst0_vif.tready                ),
    .ing_tdata        ( mst0_vif.tdata                 ),
    .ing_tlast        ( mst0_vif.tlast                 ),
    .ing_tid          ( mst0_vif.tid                   ),

    .egr_tvalid       ( slv0_vif.tvalid                ),
    .egr_tdata        ( slv0_vif.tdata                 ),
    .egr_tlast        ( slv0_vif.tlast                 ),
    .egr_tid          ( slv0_vif.tid                   ),
    .egr_tuser        ( slv0_vif.tuser                 )
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
