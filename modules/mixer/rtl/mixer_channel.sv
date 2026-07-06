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

module mixer_channel #(
    parameter int AUDIO_WIDTH_P    = -1,
    parameter int GAIN_WIDTH_P     = -1,
    parameter int Q_BITS_P         = -1
  )(
    // Clock and reset
    input  wire                               clk,
    input  wire                               rst_n,

    // Ingress
    input  wire signed  [AUDIO_WIDTH_P-1 : 0] x,
    input  wire                               x_valid,

    // Egress
    output logic signed [AUDIO_WIDTH_P-1 : 0] y_left,
    output logic signed [AUDIO_WIDTH_P-1 : 0] y_right,
    output logic                              y_valid,

    // Registers
    input  wire          [GAIN_WIDTH_P-1 : 0] cr_gain,
    input  wire          [GAIN_WIDTH_P-1 : 0] cr_pan,
    output logic                              sr_clip
  );

  localparam logic signed [AUDIO_WIDTH_P-1 : 0] ONE_C = 1 << Q_BITS_P;

  logic        [GAIN_WIDTH_P-1 : 0] cr_pan_right;
  logic        [AUDIO_WIDTH_P-1 : 0] x_gain;
  logic               [2 : 0] x_valid_d;
  logic                         left_clip;
  logic                         right_clip;

  assign y_valid = x_valid_d[2];
  assign cr_pan_right = ONE_C - cr_pan;
  assign sr_clip = left_clip || right_clip;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      x_valid_d <= '0;
    end
    else begin
      x_valid_d <= {x_valid_d[1 : 0], x_valid};
    end
  end


  dsp48_nq_multiplier #(
    .N_BITS_P         ( AUDIO_WIDTH_P ),
    .Q_BITS_P         ( Q_BITS_P      )
  ) dsp48_nq_multiplier_i0 (
    .clk              ( clk           ), // input
    .rst_n            ( rst_n         ), // input
    .ing_multiplicand ( x             ), // input
    .ing_multiplier   ( cr_gain       ), // input
    .egr_product      ( x_gain        ), // output
    .egr_overflow     ( left_clip     )  // output
  );


  dsp48_nq_multiplier #(
    .N_BITS_P         ( AUDIO_WIDTH_P ),
    .Q_BITS_P         ( Q_BITS_P      )
  ) dsp48_nq_multiplier_i1 (
    .clk              ( clk           ), // input
    .rst_n            ( rst_n         ), // input
    .ing_multiplicand ( x_gain        ), // input
    .ing_multiplier   ( cr_pan        ), // input
    .egr_product      ( y_left        ), // output
    .egr_overflow     (               )  // output
  );

  dsp48_nq_multiplier #(
    .N_BITS_P         ( AUDIO_WIDTH_P ),
    .Q_BITS_P         ( Q_BITS_P      )
  ) dsp48_nq_multiplier_i2 (
    .clk              ( clk           ), // input
    .rst_n            ( rst_n         ), // input
    .ing_multiplicand ( x_gain        ), // input
    .ing_multiplier   ( cr_pan_right  ), // input
    .egr_product      ( y_right       ), // output
    .egr_overflow     ( right_clip    )  // output
  );


endmodule

`default_nettype wire
