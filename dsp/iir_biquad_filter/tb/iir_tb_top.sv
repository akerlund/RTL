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
import iir_tb_pkg::*;
import iir_tc_pkg::*;

module iir_tb_top;

  bit clk;
  bit rst_n;

  time clk_period = 5000ps;

  // IF
  vip_apb3_if #(vip_apb3_cfg) apb3_vif(clk, rst_n);

  logic [WAVE_WIDTH_C-1 : 0] filtered_waveform;



  iir_dut_biquad_system #(
    // Oscillator
    .WAVE_WIDTH_P       ( WAVE_WIDTH_C                    ),
    .COUNTER_WIDTH_P    ( COUNTER_WIDTH_C                 ),
    // Divider and ...
    .N_BITS_P           ( N_BITS_C                        ),
    .Q_BITS_P           ( Q_BITS_C                        ),
    // Interconnections
    .AXI_DATA_WIDTH_P   ( AXI_DATA_WIDTH_C                ),
    .AXI_ID_WIDTH_P     ( AXI_ID_WIDTH_C                  ),
    // APB3
    .APB_ADDR_WIDTH_P   ( vip_apb3_cfg.APB_ADDR_WIDTH_P   ),
    .APB_DATA_WIDTH_P   ( vip_apb3_cfg.APB_DATA_WIDTH_P   ),
    .APB_NR_OF_SLAVES_P ( vip_apb3_cfg.APB_NR_OF_SLAVES_P )

  ) iir_dut_biquad_system_i0 (
    .clk                ( clk                             ),
    .rst_n              ( rst_n                           ),
    .filtered_waveform  ( filtered_waveform               ),
    .apb3_paddr         ( apb3_vif.paddr                  ),
    .apb3_psel          ( apb3_vif.psel                   ),
    .apb3_penable       ( apb3_vif.penable                ),
    .apb3_pwrite        ( apb3_vif.pwrite                 ),
    .apb3_pwdata        ( apb3_vif.pwdata                 ),
    .apb3_pready        ( apb3_vif.pready                 ),
    .apb3_prdata        ( apb3_vif.prdata                 )
  );

  initial begin

    uvm_config_db #(virtual vip_apb3_if #(vip_apb3_cfg))::set(uvm_root::get(), "uvm_test_top.tb_env.vip_apb3_agent0*", "vif", apb3_vif);

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
