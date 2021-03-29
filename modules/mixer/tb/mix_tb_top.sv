////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2020 Fredrik Åkerlund
// https://github.com/akerlund/RTL
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
import mix_tb_pkg::*;
import mix_tc_pkg::*;

module mix_tb_top;

  bit clk;
  bit rst_n;

  time clk_period = 10ns;

  // IF
  vip_axi4s_if #(VIP_AXI4S_CFG_C) mst0_vif(clk, rst_n);
  vip_axi4s_if #(VIP_AXI4S_CFG_C) slv0_vif(clk, rst_n);


  logic [NR_OF_CHANNELS_C-1 : 0] [AUDIO_WIDTH_C-1 : 0] channel_data;
  logic                                                channel_valid;
  logic                          [AUDIO_WIDTH_C-1 : 0] out_left;
  logic                          [AUDIO_WIDTH_C-1 : 0] out_right;
  logic                                                out_clip;
  logic                                                out_valid;
  logic                                                out_ready;
  logic  [NR_OF_CHANNELS_C-1 : 0] [GAIN_WIDTH_C-1 : 0] cr_channel_gain;
  logic  [NR_OF_CHANNELS_C-1 : 0]                      cr_channel_pan;
  logic                           [GAIN_WIDTH_C-1 : 0] cr_output_gain;

  genvar i;
  generate
    for (i = 0; i < NR_OF_CHANNELS_C; i++) begin
      assign channel_data[i]  = mst0_vif.tdata;
      assign cr_channel_gain[i] = (2 << Q_BITS_C);
      assign cr_channel_pan[i]  = i % 2;
    end
  endgenerate


  assign channel_valid    = mst0_vif.tvalid;
  assign out_ready      = '1;
  assign cr_output_gain =  (1 << Q_BITS_C);

  mixer_top #(
    .AUDIO_WIDTH_P             ( AUDIO_WIDTH_C    ),
    .GAIN_WIDTH_P              ( GAIN_WIDTH_C     ),
    .NR_OF_CHANNELS_P          ( NR_OF_CHANNELS_C ),
    .Q_BITS_P                  ( Q_BITS_C         )
  ) mixer_top_i0 (
    .clk                       ( clk              ), // input
    .rst_n                     ( rst_n            ), // input
    .clip_led                  (                  ), // output
    .fs_strobe                 ( channel_valid    ), // input
    .channel_data              ( channel_data     ), // input
    .dac_data                  (                  ), // output
    .dac_valid                 (                  ), // output
    .dac_ready                 ( '1               ), // input
    .dac_last                  (                  ), // output
    .cmd_mix_clear_dac_min_max ( '1               ), // input
    .cr_mix_channel_gain       ( '1               ), // input
    .cr_mix_channel_pan        ( '1               ), // input
    .cr_mix_output_gain        ( '1               ), // input
    .sr_mix_out_clip           (                  ), // output
    .sr_mix_channel_clip       (                  ), // output
    .sr_mix_max_dac_amplitude  (                  ), // output
    .sr_mix_min_dac_amplitude  (                  )  // output
  );


  initial begin

    uvm_config_db #(virtual vip_axi4s_if #(VIP_AXI4S_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.vip_axi4s_agent_mst0*", "vif", mst0_vif);
    uvm_config_db #(virtual vip_axi4s_if #(VIP_AXI4S_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.vip_axi4s_agent_slv0*", "vif", slv0_vif);

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
