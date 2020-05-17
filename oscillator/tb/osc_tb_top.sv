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
import osc_tb_pkg::*;
import osc_tc_pkg::*;

module osc_tb_top;

  bit clk;
  bit rst_n;

  time clk_period = 10ns;

  // IF
  vip_apb3_if #(vip_apb3_cfg) apb3_vif(clk, rst_n);

  logic [WAVE_WIDTH_C-1 : 0] waveform;



  oscillator_top #(

    .WAVE_WIDTH_P      ( WAVE_WIDTH_C     ), // Resolution of the waves
    .COUNTER_WIDTH_P   ( COUNTER_WIDTH_C  ), // Resolution of the counters
    .APB3_BASE_ADDR_P  ( '0               ),
    .APB3_ADDR_WIDTH_P ( vip_apb3_cfg     ),
    .APB3_DATA_WIDTH_P ( vip_apb3_cfg     )

  ) oscillator_top_i0 (

    // Clock and reset
    .clk               ( clk              ),
    .rst_n             ( rst_n            ),

    // Waveform output
    .waveform          ( waveform         ),

    // APB interface
    .apb3_paddr        ( apb3_vif.paddr   ),
    .apb3_psel         ( apb3_vif.psel    ),
    .apb3_penable      ( apb3_vif.penable ),
    .apb3_pwrite       ( apb3_vif.pwrite  ),
    .apb3_pwdata       ( apb3_vif.pwdata  ),
    .apb3_pready       ( apb3_vif.pready  ),
    .apb3_prdata       ( apb3_vif.prdata  )
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
