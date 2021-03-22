////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2021 Fredrik Åkerlund
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

`default_nettype none

module mixer_top #(
    parameter int AUDIO_WIDTH_P    = -1,
    parameter int GAIN_WIDTH_P     = -1,
    parameter int NR_OF_CHANNELS_P = -1,
    parameter int Q_BITS_P         = -1
  )(
    // Clock and reset
    input  wire                                                       clk,
    input  wire                                                       rst_n,

    // ADC
    input  wire                                              [23 : 0] adc_data,
    input  wire                                                       adc_valid,
    output logic                                                      adc_ready,
    input  wire                                                       adc_last,

    // DAC
    output logic                                             [23 : 0] dac_data,
    output logic                                                      dac_valid,
    input  wire                                                       dac_ready,
    output logic                                                      dac_last,

    logic signed       [NR_OF_CHANNELS_C-1 : 0] [AUDIO_WIDTH_C-1 : 0] channel_data,

    // Registers
    output logic                             [NR_OF_CHANNELS_P-1 : 0] sr_mix_channel_clip,
    output logic                                                      sr_mix_out_clip,
    input  wire         [NR_OF_CHANNELS_P-1 : 0] [GAIN_WIDTH_P-1 : 0] cr_mix_channel_gain,
    input  wire                              [NR_OF_CHANNELS_P-1 : 0] cr_mix_channel_pan,
    input  wire                                  [GAIN_WIDTH_P-1 : 0] cr_mix_output_gain,

    output logic                                [AUDIO_WIDTH_C-1 : 0] sr_cir_max_adc_amplitude,
    output logic                                [AUDIO_WIDTH_C-1 : 0] sr_cir_min_adc_amplitude,
    output logic                                [AUDIO_WIDTH_C-1 : 0] sr_cir_max_dac_amplitude,
    output logic                                [AUDIO_WIDTH_C-1 : 0] sr_cir_min_dac_amplitude,
    input  wire                                                       cmd_cir_clear_max
  );

  typedef enum {
    MIX_WAIT_VALID,
    MIX_SEND_FIRST,
    MIX_SEND_LAST
  } mix_egr_state_t;

  mix_egr_state_t mix_egr_state;


  logic signed [NR_OF_CHANNELS_C-1 : 0] [AUDIO_WIDTH_C-1 : 0] channel_data;
  logic                                                       channel_valid;
  logic signed                          [AUDIO_WIDTH_C-1 : 0] out_left;
  logic signed                          [AUDIO_WIDTH_C-1 : 0] out_right;
  logic                                                       out_valid;
  logic                                                       out_ready;
  logic signed                          [AUDIO_WIDTH_C-1 : 0] out_right_r0;

  logic                              [NR_OF_CHANNELS_C-1 : 0] sr_mix_channel_clip;
  logic                                                       sr_mix_out_clip;
  logic         [NR_OF_CHANNELS_C-1 : 0] [GAIN_WIDTH_C-1 : 0] cr_mix_channel_gain;
  logic                              [NR_OF_CHANNELS_C-1 : 0] cr_mix_channel_pan;
  logic                                  [GAIN_WIDTH_C-1 : 0] cr_mix_output_gain;

  logic                                                       clip_detected;
  logic                                              [31 : 0] clip_counter;


  // Mixer Clip LED
  always_ff @(posedge clk or negedge rst_n) begin : mixer_clip_p0
    if (!rst_n) begin
      led_1         <= '0;
      clip_detected <= '0;
      clip_counter  <= '0;
    end
    else begin

      led_1 <= clip_counter[25]; // 2**25 = 67108864/2

      if ((|sr_mix_channel_clip) || sr_mix_out_clip) begin
        clip_detected <= '1;
      end

      if (clip_detected) begin
        if (clip_counter == 125000000 * 5) begin
          clip_detected <= '0;
          clip_counter  <= '0;
        end else begin
          clip_counter <= clip_counter + 1;
        end
      end
    end
  end



  // Mixer Ingress
  always_ff @(posedge clk or negedge rst_n) begin : mixer_ingress_p0
    if (!rst_n) begin
      channel_data[0]          <= '0;
      channel_data[1]          <= '0;
      channel_valid            <= '0;
      cr_mix_channel_pan[0]    <= '0;
      cr_mix_channel_pan[1]    <= '1;
      cr_mix_channel_pan[2]    <= '1;
      adc_ready                <= '1;
      sr_cir_min_adc_amplitude <= '0;
      sr_cir_max_adc_amplitude <= '0;
      sr_cir_min_dac_amplitude <= '0;
      sr_cir_max_dac_amplitude <= '0;
    end
    else begin

      channel_valid <= '0;

      if (adc_valid && !adc_last) begin
        channel_data[0] <= adc_data;
      end

      if (adc_valid && adc_last) begin
        channel_data[1] <= adc_data;
        channel_valid   <= '1;
      end

      if (cmd_cir_clear_max) begin
        sr_cir_min_adc_amplitude <= '0;
        sr_cir_max_adc_amplitude <= '0;
        sr_cir_min_dac_amplitude <= '0;
        sr_cir_max_dac_amplitude <= '0;
      end
      else if (adc_valid) begin

        if ($signed(adc_data) < $signed(sr_cir_min_adc_amplitude)) begin
          sr_cir_min_adc_amplitude <= adc_data;
        end

        if ($signed(adc_data) > $signed(sr_cir_max_adc_amplitude)) begin
          sr_cir_max_adc_amplitude <= adc_data;
        end

        if ($signed(adc_data) < $signed(sr_cir_min_dac_amplitude)) begin
          sr_cir_min_dac_amplitude <= adc_data;
        end

        if ($signed(adc_data) > $signed(sr_cir_max_dac_amplitude)) begin
          sr_cir_max_dac_amplitude <= adc_data;
        end

      end
    end
  end



  // Mixer Egress
  always_ff @(posedge clk or negedge rst_n) begin : mixer_egress_p0
    if (!rst_n) begin
      mix_egr_state <= MIX_WAIT_VALID;
      out_ready     <= '1;
      out_right_r0  <= '0;
      dac_data      <= '0;
      dac_last      <= '0;
      dac_valid     <= '0;
    end
    else begin

      case (mix_egr_state)

        MIX_WAIT_VALID: begin
          if (out_valid) begin
            mix_egr_state <= MIX_SEND_FIRST;
            out_right_r0  <= out_right;
            dac_data      <= out_left;
            dac_last      <= '0;
            dac_valid     <= '1;
          end
        end

        MIX_SEND_FIRST: begin
          if (dac_ready) begin
            mix_egr_state <= MIX_SEND_LAST;
            dac_data   <= out_right_r0;
            dac_last   <= '1;
          end

        end

        MIX_SEND_LAST: begin
          if (dac_ready) begin
            mix_egr_state <= MIX_WAIT_VALID;
            dac_valid  <= '0;
          end
        end

      endcase
    end
  end



  mixer_core #(
    .AUDIO_WIDTH_P       ( AUDIO_WIDTH_C       ),
    .GAIN_WIDTH_P        ( GAIN_WIDTH_C        ),
    .NR_OF_CHANNELS_P    ( NR_OF_CHANNELS_C    ),
    .Q_BITS_P            ( Q_BITS_C            )
  ) mixer_core_i0 (
    .clk                 ( clk                 ), // input
    .rst_n               ( rst_n               ), // input
    .channel_data        ( channel_data        ), // input
    .channel_valid       ( channel_valid       ), // input
    .out_left            ( out_left            ), // output
    .out_right           ( out_right           ), // output
    .out_valid           ( out_valid           ), // input
    .out_ready           ( out_ready           ), // input
    .sr_mix_channel_clip ( sr_mix_channel_clip ), // output
    .sr_mix_out_clip     ( sr_mix_out_clip     ), // output
    .cr_mix_channel_gain ( cr_mix_channel_gain ), // input
    .cr_mix_channel_pan  ( cr_mix_channel_pan  ), // input
    .cr_mix_output_gain  ( cr_mix_output_gain  )  // input
  );


endmodule

`default_nettype wire
