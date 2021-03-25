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

    // Connect LED for blink effect
    output logic                                                      clip_led,

    // Data of channels and sampling enable strobe
    input  wire                                                       fs_strobe,
    input  wire signed [NR_OF_CHANNELS_P-1 : 0] [AUDIO_WIDTH_P-1 : 0] channel_data,

    // DAC
    output logic                                             [23 : 0] dac_data,
    output logic                                                      dac_valid,
    input  wire                                                       dac_ready,
    output logic                                                      dac_last,

    // Registers
    input  wire                                                       cmd_mix_clear_dac_min_max,
    input  wire         [NR_OF_CHANNELS_P-1 : 0] [GAIN_WIDTH_P-1 : 0] cr_mix_channel_gain,
    input  wire                              [NR_OF_CHANNELS_P-1 : 0] cr_mix_channel_pan,
    input  wire                                  [GAIN_WIDTH_P-1 : 0] cr_mix_output_gain,
    output logic                                                      sr_mix_out_clip,
    output logic                             [NR_OF_CHANNELS_P-1 : 0] sr_mix_channel_clip,
    output logic                                [AUDIO_WIDTH_P-1 : 0] sr_mix_max_dac_amplitude,
    output logic                                [AUDIO_WIDTH_P-1 : 0] sr_mix_min_dac_amplitude
  );

  typedef enum {
    DAC_WAIT_MIX_VALID_E,
    DAC_SEND_LEFT_E,
    DAC_SEND_RIGHT_E
  } dac_state_t;

  dac_state_t dac_state;

  logic signed [AUDIO_WIDTH_P-1 : 0] mix_out_left;
  logic signed [AUDIO_WIDTH_P-1 : 0] mix_out_right;
  logic                              mix_out_valid;
  logic                              mix_out_ready;
  logic signed [AUDIO_WIDTH_P-1 : 0] mix_out_right_r0;

  logic                              clip_detected;
  logic                     [31 : 0] clip_counter;

  // Mixer Egress
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      dac_state        <= DAC_WAIT_MIX_VALID_E;
      mix_out_ready    <= '1;
      mix_out_right_r0 <= '0;
      dac_data         <= '0;
      dac_last         <= '0;
      dac_valid        <= '0;
    end
    else begin

      case (dac_state)

        DAC_WAIT_MIX_VALID_E: begin
          if (mix_out_valid) begin
            dac_state        <= DAC_SEND_LEFT_E;
            dac_data         <= mix_out_left;
            dac_last         <= '0;
            dac_valid        <= '1;
            mix_out_right_r0 <= mix_out_right;
          end
        end

        DAC_SEND_LEFT_E: begin
          if (dac_ready) begin
            dac_state <= DAC_SEND_RIGHT_E;
            dac_data  <= mix_out_right_r0;
            dac_last  <= '1;
          end

        end

        DAC_SEND_RIGHT_E: begin
          if (dac_ready) begin
            dac_state <= DAC_WAIT_MIX_VALID_E;
            dac_valid <= '0;
          end
        end
      endcase
    end
  end

  // DAC amplitude status register
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      sr_mix_min_dac_amplitude <= '1;
      sr_mix_max_dac_amplitude <= '0;
    end
    else begin
      if (cmd_mix_clear_dac_min_max) begin
        sr_mix_min_dac_amplitude <= '1;
        sr_mix_max_dac_amplitude <= '0;
      end else if (dac_valid) begin
        if ($signed(dac_data) < $signed(sr_mix_min_dac_amplitude)) begin
          sr_mix_min_dac_amplitude <= dac_data;
        end
        if ($signed(dac_data) > $signed(sr_mix_max_dac_amplitude)) begin
          sr_mix_max_dac_amplitude <= dac_data;
        end
      end
    end
  end

  // Mixer Clip LED
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      clip_led      <= '0;
      clip_detected <= '0;
      clip_counter  <= '0;
    end
    else begin

      clip_led <= clip_counter[25]; // 2**25 = 67108864/2

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


  mixer_core #(
    .AUDIO_WIDTH_P       ( AUDIO_WIDTH_P       ),
    .GAIN_WIDTH_P        ( GAIN_WIDTH_P        ),
    .NR_OF_CHANNELS_P    ( NR_OF_CHANNELS_P    ),
    .Q_BITS_P            ( Q_BITS_P            )
  ) mixer_core_i0 (
    .clk                 ( clk                 ), // input
    .rst_n               ( rst_n               ), // input
    .channel_data        ( channel_data        ), // input
    .channel_valid       ( fs_strobe           ), // input
    .out_left            ( mix_out_left        ), // output
    .out_right           ( mix_out_right       ), // output
    .out_valid           ( mix_out_valid       ), // input
    .out_ready           ( mix_out_ready       ), // input
    .cr_mix_channel_gain ( cr_mix_channel_gain ), // input
    .cr_mix_channel_pan  ( cr_mix_channel_pan  ), // input
    .cr_mix_output_gain  ( cr_mix_output_gain  ), // input
    .sr_mix_out_clip     ( sr_mix_out_clip     ), // output
    .sr_mix_channel_clip ( sr_mix_channel_clip )  // output
  );


endmodule

`default_nettype wire
