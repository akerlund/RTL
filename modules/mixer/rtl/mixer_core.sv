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

`default_nettype none

module mixer_core #(
    parameter int AUDIO_WIDTH_P    = -1,
    parameter int GAIN_WIDTH_P     = -1,
    parameter int NR_OF_CHANNELS_P = -1,
    parameter int Q_BITS_P         = -1
  )(
    // Clock and reset
    input  wire                                                       clk,
    input  wire                                                       rst_n,

    // Ingress
    input  wire signed [NR_OF_CHANNELS_P-1 : 0] [AUDIO_WIDTH_P-1 : 0] x_data,
    input  wire                                                       x_valid,

    // Egress
    output logic signed                         [AUDIO_WIDTH_P-1 : 0] out_left,
    output logic signed                         [AUDIO_WIDTH_P-1 : 0] out_right,
    output logic                                                      out_valid,
    input  wire                                                       out_ready,

    // Registers
    input  wire         [NR_OF_CHANNELS_P-1 : 0] [GAIN_WIDTH_P-1 : 0] cr_mix_channel_gain,
    input  wire         [NR_OF_CHANNELS_P-1 : 0] [GAIN_WIDTH_P-1 : 0] cr_mix_channel_pan,
    input  wire                                  [GAIN_WIDTH_P-1 : 0] cr_mix_output_gain,
    output logic                                                      sr_mix_out_clip,
    output logic                             [NR_OF_CHANNELS_P-1 : 0] sr_mix_channel_clip
  );


  logic signed [NR_OF_CHANNELS_P-1 : 0]   [AUDIO_WIDTH_P-1 : 0] y_left;
  logic signed [NR_OF_CHANNELS_P-1 : 0]   [AUDIO_WIDTH_P-1 : 0] y_right;
  logic signed [NR_OF_CHANNELS_P-1 : 0]                         y_valid;
  logic signed [NR_OF_CHANNELS_P-1 : 0]                         y_clip;


  logic signed                            [AUDIO_WIDTH_P-1 : 0] left_channel_sum;
  logic signed                            [AUDIO_WIDTH_P-1 : 0] right_channel_sum;

  logic signed                              [AUDIO_WIDTH_P : 0] left_channel_sum_r0;
  logic signed                              [AUDIO_WIDTH_P : 0] right_channel_sum_r0;
  logic signed                              [AUDIO_WIDTH_P : 0] left_channel_sum_c0;
  logic signed                              [AUDIO_WIDTH_P : 0] right_channel_sum_c0;

  logic [2 : 0] valid_d0;
  logic         out_clip_left;
  logic         out_clip_right;

  assign out_valid = valid_d0[0];

  assign sr_mix_out_clip   = out_clip_left || out_clip_right;
  assign left_channel_sum  = left_channel_sum_r0[AUDIO_WIDTH_P-1 : 0];
  assign right_channel_sum = right_channel_sum_r0[AUDIO_WIDTH_P-1 : 0];


  always_ff @(posedge clk or negedge rst_n) begin : mixer_output_p0
    if (!rst_n) begin
      valid_d0             <= '0;
      left_channel_sum_r0  <= '0;
      right_channel_sum_r0 <= '0;
    end
    else begin

      // Delaying output valid
      valid_d0 <= {x_valid, valid_d0[2 : 1]};

      if (valid_d0[2]) begin
        left_channel_sum_r0  <= left_channel_sum_c0;
        right_channel_sum_r0 <= right_channel_sum_c0;
      end
    end
  end


  // Summing up the output
  always_comb begin

    left_channel_sum_c0  = '0;
    right_channel_sum_c0 = '0;

    if (valid_d0[2]) begin
      for (int i = 0; i < NR_OF_CHANNELS_P; i++) begin
        if (!cr_mix_channel_pan[i]) begin
          left_channel_sum_c0  = left_channel_sum_c0  + {y_left[i][AUDIO_WIDTH_P-1],  y_left[i]};
        end else begin
          right_channel_sum_c0 = right_channel_sum_c0 + {y_right[i][AUDIO_WIDTH_P-1], y_right[i]};
        end
      end
    end
  end


  // Channels
  genvar i;
  generate
    for (i = 0; i < NR_OF_CHANNELS_P; i++) begin
      mixer_channel #(
        .AUDIO_WIDTH_P ( AUDIO_WIDTH_P          ),
        .GAIN_WIDTH_P  ( GAIN_WIDTH_P           ),
        .Q_BITS_P      ( Q_BITS_P               )
      ) mixer_channel_i (
        // Clock and reset
        .clk           ( clk                    ), // input
        .rst_n         ( rst_n                  ), // input

        // Ingress
        .x             ( x_data[i]              ), // input
        .x_valid       ( x_valid                ), // input

        // Egress
        .y_left        ( y_left[i]              ), // output
        .y_right       ( y_right[i]             ), // output
        .y_valid       ( y_valid[i]             ), // output

        // Registers
        .cr_gain       ( cr_mix_channel_gain[i] ), // input
        .cr_pan        ( cr_mix_channel_pan[i]  ), // input
        .sr_clip       ( y_clip[i]              )  // output
      );
    end
  endgenerate

  // Left output gain
  dsp48_nq_multiplier #(
    .N_BITS_P         ( AUDIO_WIDTH_P      ),
    .Q_BITS_P         ( Q_BITS_P           )
  ) dsp48_nq_multiplier_i0 (
    .clk              ( clk                ), // input
    .rst_n            ( rst_n              ), // input
    .ing_multiplicand ( left_channel_sum   ), // input
    .ing_multiplier   ( cr_mix_output_gain ), // input
    .egr_product      ( out_left           ), // output
    .egr_overflow     ( out_clip_left      )  // output
  );

  // Right output gain
  dsp48_nq_multiplier #(
    .N_BITS_P         ( AUDIO_WIDTH_P      ),
    .Q_BITS_P         ( Q_BITS_P           )
  ) dsp48_nq_multiplier_i1 (
    .clk              ( clk                ), // input
    .rst_n            ( rst_n              ), // input
    .ing_multiplicand ( right_channel_sum  ), // input
    .ing_multiplier   ( cr_mix_output_gain ), // input
    .egr_product      ( out_right          ), // output
    .egr_overflow     ( out_clip_right     )  // output
  );


endmodule

`default_nettype wire
