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

  logic [AUDIO_WIDTH_P-1 : 0] x_gain;
  logic               [2 : 0] x_valid_d;

  assign y_valid = x_valid_d[2];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      x_valid_d <= '0;
      y_right   <= '0;
    end
    else begin
      x_valid_d <= {x_valid_d[1 : 0], x_valid};
      y_right   <= x_gain - y_left;
    end
  end


  // Gain
  dsp48_nq_multiplier #(
    .N_BITS_P         ( AUDIO_WIDTH_P ),
    .Q_BITS_P         ( Q_BITS_P      )
  ) dsp48_nq_multiplier_i0 (
    .clk              ( clk           ), // input
    .rst_n            ( rst_n         ), // input
    .ing_multiplicand ( x             ), // input
    .ing_multiplier   ( cr_gain       ), // input
    .egr_product      ( x_gain        ), // output
    .egr_overflow     ( sr_clip       )  // output
  );

  // Pan
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


endmodule

`default_nettype wire
