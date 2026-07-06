////////////////////////////////////////////////////////////////////////////////
//
// Copyright (C) 2026 Fredrik Åkerlund
// https://github.com/akerlund/RTL
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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

  localparam int SUM_WIDTH_C = AUDIO_WIDTH_P + $clog2(NR_OF_CHANNELS_P) + 1;

  localparam logic signed [AUDIO_WIDTH_P-1 : 0] AUDIO_MAX_C = {1'b0, {(AUDIO_WIDTH_P-1){1'b1}}};
  localparam logic signed [AUDIO_WIDTH_P-1 : 0] AUDIO_MIN_C = {1'b1, {(AUDIO_WIDTH_P-1){1'b0}}};

  logic signed [NR_OF_CHANNELS_P-1 : 0]   [AUDIO_WIDTH_P-1 : 0] y_left;
  logic signed [NR_OF_CHANNELS_P-1 : 0]   [AUDIO_WIDTH_P-1 : 0] y_right;
  logic        [NR_OF_CHANNELS_P-1 : 0]                         y_valid;
  logic        [NR_OF_CHANNELS_P-1 : 0]                         y_clip;


  logic signed                            [AUDIO_WIDTH_P-1 : 0] left_channel_sum;
  logic signed                            [AUDIO_WIDTH_P-1 : 0] right_channel_sum;

  logic signed                              [SUM_WIDTH_C-1 : 0] left_channel_sum_c0;
  logic signed                              [SUM_WIDTH_C-1 : 0] right_channel_sum_c0;

  logic                                                      channel_valid;
  logic                                                      sum_clip_left;
  logic                                                      sum_clip_right;
  logic                                                      sum_accepted;
  logic                                                      product_valid;
  logic                                                      out_clip_left;
  logic                                                      out_clip_right;
  logic signed                         [AUDIO_WIDTH_P-1 : 0] out_left_c0;
  logic signed                         [AUDIO_WIDTH_P-1 : 0] out_right_c0;
  logic                                                      out_valid_c0;

  function automatic logic signed [AUDIO_WIDTH_P-1 : 0] clip_to_audio(
    input logic signed [SUM_WIDTH_C-1 : 0] value
  );
    begin
      if (value > $signed(AUDIO_MAX_C)) begin
        clip_to_audio = AUDIO_MAX_C;
      end else if (value < $signed(AUDIO_MIN_C)) begin
        clip_to_audio = AUDIO_MIN_C;
      end else begin
        clip_to_audio = value[AUDIO_WIDTH_P-1 : 0];
      end
    end
  endfunction

  assign channel_valid     = &y_valid;
  assign sum_clip_left     = (left_channel_sum_c0 > $signed(AUDIO_MAX_C)) ||
                             (left_channel_sum_c0 < $signed(AUDIO_MIN_C));
  assign sum_clip_right    = (right_channel_sum_c0 > $signed(AUDIO_MAX_C)) ||
                             (right_channel_sum_c0 < $signed(AUDIO_MIN_C));
  assign sum_accepted      = channel_valid && (!out_valid || out_ready);
  assign out_valid_c0      = out_valid && !out_ready;
  assign sr_mix_out_clip   = sum_clip_left || sum_clip_right || out_clip_left || out_clip_right;
  assign sr_mix_channel_clip = y_clip;


  always_ff @(posedge clk or negedge rst_n) begin : mixer_output_p0
    if (!rst_n) begin
      product_valid     <= '0;
      left_channel_sum  <= '0;
      right_channel_sum <= '0;
      out_left          <= '0;
      out_right         <= '0;
      out_valid         <= '0;
    end
    else begin

      product_valid <= sum_accepted;

      if (sum_accepted) begin
        left_channel_sum  <= clip_to_audio(left_channel_sum_c0);
        right_channel_sum <= clip_to_audio(right_channel_sum_c0);
      end

      if (!out_valid_c0) begin
        out_valid <= product_valid;
        if (product_valid) begin
          out_left  <= out_left_c0;
          out_right <= out_right_c0;
        end
      end
    end
  end


  // Summing up the output
  always_comb begin

    left_channel_sum_c0  = '0;
    right_channel_sum_c0 = '0;

    if (channel_valid) begin
      for (int i = 0; i < NR_OF_CHANNELS_P; i++) begin
        left_channel_sum_c0  = left_channel_sum_c0  + {{(SUM_WIDTH_C-AUDIO_WIDTH_P){y_left[i][AUDIO_WIDTH_P-1]}},  y_left[i]};
        right_channel_sum_c0 = right_channel_sum_c0 + {{(SUM_WIDTH_C-AUDIO_WIDTH_P){y_right[i][AUDIO_WIDTH_P-1]}}, y_right[i]};
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
    .egr_product      ( out_left_c0        ), // output
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
    .egr_product      ( out_right_c0       ), // output
    .egr_overflow     ( out_clip_right     )  // output
  );


endmodule

`default_nettype wire
