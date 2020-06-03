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
import osc_tb_pkg::*;
import osc_tc_pkg::*;

module osc_tb_top;

  bit clk;
  bit rst_n;

  time clk_period = 4ns;

  // IF
  vip_apb3_if #(vip_apb3_cfg) apb3_vif(clk, rst_n);

  // AXI4-S signals betwwen the Oscillator top and the divider
  logic                          osc_div_tvalid;
  logic                          osc_div_tready;
  logic [AXI_DATA_WIDTH_C-1 : 0] osc_div_tdata;
  logic                          osc_div_tlast;
  logic   [AXI_ID_WIDTH_C-1 : 0] osc_div_tid;
  logic                          div_osc_tvalid;
  logic                          div_osc_tready;
  logic [AXI_DATA_WIDTH_C-1 : 0] div_osc_tdata;
  logic                          div_osc_tlast;
  logic   [AXI_ID_WIDTH_C-1 : 0] div_osc_tid;
  logic                          div_osc_tuser;

  // AXI4-S signals betwwen the Oscillator top and the CORDIC
  logic                                   osc_cor_tvalid;
  logic signed   [AXI_DATA_WIDTH_C-1 : 0] osc_cor_tdata;
  logic            [AXI_ID_WIDTH_C-1 : 0] osc_cor_tid;
  logic                                   osc_cor_tuser;
  logic                                   cor_osc_tvalid;
  logic signed [2*AXI_DATA_WIDTH_C-1 : 0] cor_osc_tdata;
  logic            [AXI_ID_WIDTH_C-1 : 0] cor_osc_tid;


  oscillator_top #(
    .SYS_CLK_FREQUENCY_P  ( SYS_CLK_FREQUENCY_C             ),
    .PRIME_FREQUENCY_P    ( PRIME_FREQUENCY_C               ),
    .WAVE_WIDTH_P         ( WAVE_WIDTH_C                    ),
    .DUTY_CYCLE_DIVIDER_P ( DUTY_CYCLE_DIVIDER_C            ),
    .N_BITS_P             ( N_BITS_C                        ),
    .Q_BITS_P             ( Q_BITS_C                        ),
    .AXI_DATA_WIDTH_P     ( AXI_DATA_WIDTH_C                ),
    .AXI_ID_WIDTH_P       ( AXI_ID_WIDTH_C                  ),
    .AXI_ID_P             ( AXI_ID_C                        ),
    .APB_BASE_ADDR_P      ( OSC_BASE_ADDR_C                 ),
    .APB_ADDR_WIDTH_P     ( vip_apb3_cfg.APB_ADDR_WIDTH_P   ),
    .APB_DATA_WIDTH_P     ( vip_apb3_cfg.APB_DATA_WIDTH_P   )
  ) oscillator_top_i0 (
    .clk                  ( clk                             ), // input
    .rst_n                ( rst_n                           ), // input

    // Long division interface
    .waveform             (                                 ), // output
    .div_egr_tvalid       ( osc_div_tvalid                  ), // output
    .div_egr_tready       ( osc_div_tready                  ), // input
    .div_egr_tdata        ( osc_div_tdata                   ), // output
    .div_egr_tlast        ( osc_div_tlast                   ), // output
    .div_egr_tid          ( osc_div_tid                     ), // output
    .div_ing_tvalid       ( div_osc_tvalid                  ), // input
    .div_ing_tready       ( div_osc_tready                  ), // output
    .div_ing_tdata        ( div_osc_tdata                   ), // input
    .div_ing_tlast        ( div_osc_tlast                   ), // input
    .div_ing_tid          ( div_osc_tid                     ), // input
    .div_ing_tuser        ( div_osc_tuser                   ), // input

    // CORDIC interface
    .egr_cor_tvalid       ( osc_cor_tvalid                  ), // output
    .egr_cor_tready       ( '1                              ), // input
    .egr_cor_tdata        ( osc_cor_tdata                   ), // output
    .egr_cor_tlast        (                                 ), // output
    .egr_cor_tid          ( osc_cor_tid                     ), // output
    .egr_cor_tuser        ( osc_cor_tuser                   ), // output
    .cor_ing_tvalid       ( cor_osc_tvalid                  ), // input
    .cor_ing_tready       (                                 ), // output
    .cor_ing_tdata        ( cor_osc_tdata                   ), // input
    .cor_ing_tlast        ( '1                              ), // input

    // APB interface
    .apb3_paddr           ( apb3_vif.paddr                  ), // input
    .apb3_psel            ( apb3_vif.psel[OSC_PSEL_BIT_C]   ), // output
    .apb3_penable         ( apb3_vif.penable                ), // output
    .apb3_pwrite          ( apb3_vif.pwrite                 ), // input
    .apb3_pwdata          ( apb3_vif.pwdata                 ), // input
    .apb3_pready          ( apb3_vif.pready[OSC_PSEL_BIT_C] ), // input
    .apb3_prdata          ( apb3_vif.prdata[OSC_PSEL_BIT_C] )  // input
  );


  long_division_axi4s_if #(
    .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_C ),
    .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_C   ),
    .N_BITS_P         ( AXI_DATA_WIDTH_C ),
    .Q_BITS_P         ( Q_BITS_C         )
  ) long_division_axi4s_if_i0 (

    .clk              ( clk              ), // input
    .rst_n            ( rst_n            ), // input

    .ing_tvalid       ( osc_div_tvalid   ), // input
    .ing_tready       ( osc_div_tready   ), // output
    .ing_tdata        ( osc_div_tdata    ), // input
    .ing_tlast        ( osc_div_tlast    ), // input
    .ing_tid          ( osc_div_tid      ), // input

    .egr_tvalid       ( div_osc_tvalid   ), // output
    .egr_tdata        ( div_osc_tdata    ), // output
    .egr_tlast        ( div_osc_tlast    ), // output
    .egr_tid          ( div_osc_tid      ), // output
    .egr_tuser        ( div_osc_tuser    )  // output
  );


  cordic_axi4s_if #(
    .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_C ),
    .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_C   ),
    .NR_OF_STAGES_P   ( 16               )
  ) cordic_axi4s_if_i0 (

    .clk              ( clk              ), // input
    .rst_n            ( rst_n            ), // input

    .ing_tvalid       ( osc_cor_tvalid   ), // input
    .ing_tdata        ( osc_cor_tdata    ), // input
    .ing_tid          ( osc_cor_tid      ), // input
    .ing_tuser        ( osc_cor_tuser    ), // input

    .egr_tvalid       ( cor_osc_tvalid   ), // output
    .egr_tdata        ( cor_osc_tdata    ), // output
    .egr_tid          ( cor_osc_tid      )  // output
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
