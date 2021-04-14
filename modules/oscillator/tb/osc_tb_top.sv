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
import osc_tb_pkg::*;
import osc_tc_pkg::*;

module osc_tb_top;

  clk_rst_if                   clk_rst_vif();
  vip_axi4_if #(VIP_REG_CFG_C) reg_vif(clk_rst_vif.clk, clk_rst_vif.rst_n);

  axi4_reg_if  #(
    .AXI4_ID_WIDTH_P   ( VIP_REG_CFG_C.VIP_AXI4_ID_WIDTH_P   ),
    .AXI4_ADDR_WIDTH_P ( VIP_REG_CFG_C.VIP_AXI4_ADDR_WIDTH_P ),
    .AXI4_DATA_WIDTH_P ( VIP_REG_CFG_C.VIP_AXI4_DATA_WIDTH_P ),
    .AXI4_STRB_WIDTH_P ( VIP_REG_CFG_C.VIP_AXI4_STRB_WIDTH_P )
  ) osc_cfg_if (clk_rst_vif.clk, clk_rst_vif.rst_n);

  // Register slave
  assign osc_cfg_if.awaddr  = reg_vif.awaddr;
  assign osc_cfg_if.awvalid = reg_vif.awvalid;
  assign reg_vif.awready    = osc_cfg_if.awready;
  assign osc_cfg_if.wdata   = reg_vif.wdata;
  assign osc_cfg_if.wstrb   = reg_vif.wstrb;
  assign osc_cfg_if.wlast   = reg_vif.wlast;
  assign osc_cfg_if.wvalid  = reg_vif.wvalid;
  assign reg_vif.wready     = osc_cfg_if.wready;
  assign reg_vif.bresp      = osc_cfg_if.bresp;
  assign reg_vif.bvalid     = osc_cfg_if.bvalid;
  assign osc_cfg_if.bready  = reg_vif.bready;
  assign osc_cfg_if.araddr  = reg_vif.araddr;
  assign osc_cfg_if.arlen   = reg_vif.arlen;
  assign osc_cfg_if.arvalid = reg_vif.arvalid;
  assign reg_vif.arready    = osc_cfg_if.arready;
  assign reg_vif.rdata      = osc_cfg_if.rdata;
  assign reg_vif.rresp      = osc_cfg_if.rresp;
  assign reg_vif.rlast      = osc_cfg_if.rlast;
  assign reg_vif.rvalid     = osc_cfg_if.rvalid;
  assign osc_cfg_if.rready  = reg_vif.rready;

  //
  logic                          [31 : 0] counter;
  logic signed       [WAVE_WIDTH_C-1 : 0] waveform;
  logic                                   frequency_enable;
  logic           [COUNTER_WIDTH_C-1 : 0] cr_enable_period;

  // AXI4-S signals betwwen the Oscillator top and the divider
  logic                                   osc_div_tvalid;
  logic                                   osc_div_tready;
  logic          [AXI_DATA_WIDTH_C-1 : 0] osc_div_tdata;
  logic                                   osc_div_tlast;
  logic            [AXI_ID_WIDTH_C-1 : 0] osc_div_tid;
  logic                                   div_osc_tvalid;
  logic                                   div_osc_tready;
  logic          [AXI_DATA_WIDTH_C-1 : 0] div_osc_tdata;
  logic                                   div_osc_tlast;
  logic            [AXI_ID_WIDTH_C-1 : 0] div_osc_tid;
  logic                                   div_osc_tuser;

  // AXI4-S signals betwwen the Oscillator top and the CORDIC
  logic                                   osc_cor_tvalid;
  logic signed   [AXI_DATA_WIDTH_C-1 : 0] osc_cor_tdata;
  logic            [AXI_ID_WIDTH_C-1 : 0] osc_cor_tid;
  logic                                   osc_cor_tuser;
  logic                                   cor_osc_tvalid;
  logic signed [2*AXI_DATA_WIDTH_C-1 : 0] cor_osc_tdata;
  logic            [AXI_ID_WIDTH_C-1 : 0] cor_osc_tid;

  // Mixer
  logic  [NR_OF_CHANNELS_C-1 : 0] [WAVE_WIDTH_C-1 : 0] channel_data;
  logic                                                channel_valid;
  logic                           [WAVE_WIDTH_C-1 : 0] out_left;
  logic                           [WAVE_WIDTH_C-1 : 0] out_right;
  logic                       [NR_OF_CHANNELS_C-1 : 0] sr_mix_channel_clip;
  logic                                                sr_mix_out_clip;
  logic                                                out_valid;
  logic                                                out_ready;
  logic  [NR_OF_CHANNELS_C-1 : 0] [WAVE_WIDTH_C-1 : 0] cr_channel_gain;
  logic  [NR_OF_CHANNELS_C-1 : 0]                      cr_channel_pan;
  logic                           [WAVE_WIDTH_C-1 : 0] cr_output_gain;

  // Register slave
  logic          [1 : 0] cr_osc_waveform_select;
  logic [N_BITS_C-1 : 0] cr_osc_frequency;
  logic [N_BITS_C-1 : 0] cr_osc_duty_cycle;

  assign cr_enable_period   = SYS_CLK_FREQUENCY_C / SAMPLING_FREQUENCY_C;
  assign cr_channel_gain[0] = (1024 <<< Q_BITS_C);
  assign cr_channel_gain[1] = (1024 <<< Q_BITS_C);
  assign cr_channel_pan[0]  = 1'b0;
  assign cr_channel_pan[1]  = 1'b1;
  assign cr_output_gain     = (1 <<< Q_BITS_C);
  assign out_ready          = '1;

  always_ff @(posedge clk_rst_vif.clk or negedge clk_rst_vif.rst_n) begin : mixer_output_p0
    if (!clk_rst_vif.rst_n) begin
      channel_data[0]        <= '0;
      channel_data[1]        <= '0;
      channel_valid          <= '0;
      counter                <= '0;
      cr_osc_waveform_select <= '0;
    end
    else begin

      channel_valid <= '0;
      if (frequency_enable) begin
        counter         <= counter + 1;
        channel_valid   <= '1;
        channel_data[0] <= waveform;
        channel_data[1] <= waveform;
      end

      // Changing the output waveform
      if (counter == 100) begin
        counter                <= '0;
        cr_osc_waveform_select <= cr_osc_waveform_select + 1;
      end

    end
  end

  // ---------------------------------------------------------------------------
  // Generating the sample frequency with a clock enable
  // ---------------------------------------------------------------------------
  clock_enable #(
    .COUNTER_WIDTH_P  ( COUNTER_WIDTH_C    )
  ) clock_enable_i0 (
    .clk              ( clk_rst_vif.clk    ), // input
    .rst_n            ( clk_rst_vif.rst_n  ), // input
    .reset_counter_n  ( '1                 ), // input
    .enable           ( frequency_enable   ), // output
    .cr_enable_period ( cr_enable_period   )  // input
  );

  // ---------------------------------------------------------------------------
  // Mixer for audio
  // ---------------------------------------------------------------------------
  //mixer_top #(
  //  .AUDIO_WIDTH_P       ( WAVE_WIDTH_C        ),
  //  .GAIN_WIDTH_P        ( WAVE_WIDTH_C        ),
  //  .NR_OF_CHANNELS_P    ( NR_OF_CHANNELS_C    ),
  //  .Q_BITS_P            ( Q_BITS_C            )
  //) mixer_top_i0 (
  //  .clk                       ( clk                      ), // input
  //  .rst_n                     ( rst_n                    ), // input
  //  .clip_led                  (                          ), // output
  //  .fs_strobe                 ( fs_strobe                ), // input
  //  .dac_data                  ( cs_dac_data              ), // output
  //  .dac_valid                 ( cs_dac_valid             ), // output
  //  .dac_ready                 ( cs_dac_ready             ), // input
  //  .dac_last                  ( cs_dac_last              ), // output
  //  .channel_data              ( mix_channel_data         ), // input
  //  .cmd_mix_clear_dac_min_max ( '0                       ), // input
  //  .cr_mix_channel_gain       ( cr_mix_channel_gain      ), // input
  //  .cr_mix_channel_pan        ( cr_mix_channel_pan       ), // input
  //  .cr_mix_output_gain        ( cr_mix_output_gain       ), // input
  //  .sr_mix_out_clip           ( sr_mix_out_clip          ), // output
  //  .sr_mix_channel_clip       ( sr_mix_channel_clip      ), // output
  //  .sr_mix_max_dac_amplitude  ( sr_mix_max_dac_amplitude ), // output
  //  .sr_mix_min_dac_amplitude  ( sr_mix_min_dac_amplitude )  // output
  //);

  // ---------------------------------------------------------------------------
  // Oscillator
  // ---------------------------------------------------------------------------
  oscillator_top #(
    .SYS_CLK_FREQUENCY_P  ( SYS_CLK_FREQUENCY_C    ),
    .PRIME_FREQUENCY_P    ( PRIME_FREQUENCY_C      ),
    .WAVE_WIDTH_P         ( WAVE_WIDTH_C           ),
    .DUTY_CYCLE_DIVIDER_P ( DUTY_CYCLE_DIVIDER_C   ),
    .N_BITS_P             ( N_BITS_C               ),
    .Q_BITS_P             ( Q_BITS_C               ),
    .AXI_DATA_WIDTH_P     ( AXI_DATA_WIDTH_C       ),
    .AXI_ID_WIDTH_P       ( AXI_ID_WIDTH_C         ),
    .AXI_ID_P             ( AXI_ID_C               )
  ) oscillator_top_i0 (
    .clk                  ( clk_rst_vif.clk        ), // input
    .rst_n                ( clk_rst_vif.rst_n      ), // input

    // Long division interface
    .waveform             ( waveform               ), // output
    .div_egr_tvalid       ( osc_div_tvalid         ), // output
    .div_egr_tready       ( osc_div_tready         ), // input
    .div_egr_tdata        ( osc_div_tdata          ), // output
    .div_egr_tlast        ( osc_div_tlast          ), // output
    .div_egr_tid          ( osc_div_tid            ), // output
    .div_ing_tvalid       ( div_osc_tvalid         ), // input
    .div_ing_tready       ( div_osc_tready         ), // output
    .div_ing_tdata        ( div_osc_tdata          ), // input
    .div_ing_tlast        ( div_osc_tlast          ), // input
    .div_ing_tid          ( div_osc_tid            ), // input
    .div_ing_tuser        ( div_osc_tuser          ), // input

    // CORDIC interface
    .egr_cor_tvalid       ( osc_cor_tvalid         ), // output
    .egr_cor_tready       ( '1                     ), // input
    .egr_cor_tdata        ( osc_cor_tdata          ), // output
    .egr_cor_tlast        (                        ), // output
    .egr_cor_tid          ( osc_cor_tid            ), // output
    .egr_cor_tuser        ( osc_cor_tuser          ), // output
    .cor_ing_tvalid       ( cor_osc_tvalid         ), // input
    .cor_ing_tready       (                        ), // output
    .cor_ing_tdata        ( cor_osc_tdata          ), // input
    .cor_ing_tlast        ( '1                     ), // input

    // Configuration registers
    .cr_waveform_select   ( cr_osc_waveform_select ), // input
    .cr_frequency         ( cr_osc_frequency       ), // input
    .cr_duty_cycle        ( cr_osc_duty_cycle      )  // input
  );

  // ---------------------------------------------------------------------------
  // Long Division
  // ---------------------------------------------------------------------------
  long_division_axi4s_if #(
    .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_C  ),
    .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_C    ),
    .N_BITS_P         ( AXI_DATA_WIDTH_C  ),
    .Q_BITS_P         ( Q_BITS_C          )
  ) long_division_axi4s_if_i0 (

    .clk              ( clk_rst_vif.clk   ), // input
    .rst_n            ( clk_rst_vif.rst_n ), // input

    .ing_tvalid       ( osc_div_tvalid    ), // input
    .ing_tready       ( osc_div_tready    ), // output
    .ing_tdata        ( osc_div_tdata     ), // input
    .ing_tlast        ( osc_div_tlast     ), // input
    .ing_tid          ( osc_div_tid       ), // input

    .egr_tvalid       ( div_osc_tvalid    ), // output
    .egr_tdata        ( div_osc_tdata     ), // output
    .egr_tlast        ( div_osc_tlast     ), // output
    .egr_tid          ( div_osc_tid       ), // output
    .egr_tuser        ( div_osc_tuser     )  // output
  );

  // ---------------------------------------------------------------------------
  // CORDIC
  // ---------------------------------------------------------------------------
  cordic_axi4s_if #(
    .AXI_DATA_WIDTH_P ( AXI_DATA_WIDTH_C  ),
    .AXI_ID_WIDTH_P   ( AXI_ID_WIDTH_C    ),
    .NR_OF_STAGES_P   ( 16                )
  ) cordic_axi4s_if_i0 (

    .clk              ( clk_rst_vif.clk   ), // input
    .rst_n            ( clk_rst_vif.rst_n ), // input

    .ing_tvalid       ( osc_cor_tvalid    ), // input
    .ing_tdata        ( osc_cor_tdata     ), // input
    .ing_tid          ( osc_cor_tid       ), // input
    .ing_tuser        ( osc_cor_tuser     ), // input

    .egr_tvalid       ( cor_osc_tvalid    ), // output
    .egr_tdata        ( cor_osc_tdata     ), // output
    .egr_tid          ( cor_osc_tid       )  // output
  );

  // ---------------------------------------------------------------------------
  // APB Registers
  // ---------------------------------------------------------------------------
  osc_axi_slave #(
    .AUDIO_WIDTH_C          ( WAVE_WIDTH_C                        ),
    .AXI_ADDR_WIDTH_P       ( VIP_REG_CFG_C.VIP_AXI4_ADDR_WIDTH_P ),
    .AXI_DATA_WIDTH_P       ( VIP_REG_CFG_C.VIP_AXI4_DATA_WIDTH_P ),
    .AXI_ID_P               ( VIP_REG_CFG_C.VIP_AXI4_ID_WIDTH_P   ),
    .GAIN_WIDTH_C           ( N_BITS_C                            ),
    .N_BITS_C               ( N_BITS_C                            ),
    .Q_BITS_C               ( N_BITS_C                            )
  ) osc_axi_slave_i0 (
    .cif                    ( osc_cfg_if                          ), // interface
    .cr_osc_waveform_select ( /*cr_osc_waveform_select*/              ), // output
    .cr_osc_frequency       ( cr_osc_frequency                    ), // output
    .cr_osc_duty_cycle      ( cr_osc_duty_cycle                   ) // output
  );


  initial begin
    uvm_config_db #(virtual clk_rst_if)::set(uvm_root::get(),                   "uvm_test_top.tb_env*",            "vif", clk_rst_vif);
    uvm_config_db #(virtual vip_axi4_if #(VIP_REG_CFG_C))::set(uvm_root::get(), "uvm_test_top.tb_env.reg_agent0*", "vif", reg_vif);
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
