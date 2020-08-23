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
import cor_tb_pkg::*;
import cor_tc_pkg::*;

module cor_tb_top;

  bit clk;
  bit rst_n;

  time clk_period = 10ns;

  assign axi4s_vif.tready = '1;

  // IF
  vip_axi4s_if #(vip_axi4s_cfg) axi4s_vif(clk, rst_n);

  cordic_axi4s_if #(
    .AXI_DATA_WIDTH_P    ( vip_axi4s_cfg.AXI_DATA_WIDTH_P ),
    .AXI_ID_WIDTH_P      ( vip_axi4s_cfg.AXI_ID_WIDTH_P   ),
    .NR_OF_STAGES_P      ( 16                             )
  ) cordic_axi4s_if_i0 (
    .clk                 ( clk                            ),
    .rst_n               ( rst_n                          ),
    .ing_tvalid          ( axi4s_vif.tvalid               ),
    .ing_tdata           ( axi4s_vif.tdata                ),
    .ing_tid             ( axi4s_vif.tid                  ),
    .ing_tuser           ( '0                             ),
    .egr_tvalid          (                                ),
    .egr_tdata           (                                ),
    .egr_tid             (                                )
  );


  initial begin

    uvm_config_db #(virtual vip_axi4s_if #(vip_axi4s_cfg))::set(uvm_root::get(), "uvm_test_top.tb_env.vip_axi4s_agent0*", "vif", axi4s_vif);

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
