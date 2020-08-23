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

`default_nettype none
//
// | X(0) |   | 1  1  1  1 | | a + jb |
// | X(1) | = | 1 -j -1  j | | c + jd |
// | X(2) |   | 1 -1  1 -1 | | e + jf |
// | X(3) |   | 1  j -1 -j | | h + ji |
//
// X(0) = a + c + e + h + j*(b + d + f + i)
// X(1) = a + d - e - i + j*(b - c - f + h)
// X(2) = a - c + e - h + j*(b - d + f - i)
// X(3) = a - d - e + i + j*(b + c - f - h)
//
// Rename:
//
// | X(0) |   | 1  1  1  1 | | a_re + j*a_im |
// | X(1) | = | 1 -j -1  j | | b_re + j*b_im |
// | X(2) |   | 1 -1  1 -1 | | c_re + j*c_im |
// | X(3) |   | 1  j -1 -j | | d_re + j*d_im |
//
// X(0) = a_re + b_re + c_re + d_re + j*(a_im + b_im + c_im + d_im)
// X(1) = a_re + b_im - c_re - d_im + j*(a_im - b_re - c_im + d_re)
// X(2) = a_re - b_re + c_re - d_re + j*(a_im - b_im + c_im - d_im)
// X(3) = a_re - b_im - c_re + d_im + j*(a_im + b_re - c_im - d_re)
//
// y_a_re = a_re + b_re + c_re + d_re
// y_a_im = a_im + b_im + c_im + d_im
//
// y_b_re = a_re + b_im - c_re - d_im
// y_b_im = a_im - b_re - c_im + d_re
//
// y_c_re = a_re - b_re + c_re - d_re
// y_c_im = a_im - b_im + c_im - d_im
//
// y_d_re = a_re - b_im - c_re + d_im
// y_d_im = a_im + b_re - c_im - d_re
//
//
// Synth 1.
// Pipeline, 3 stages, 24-bit
// LUT 400
// FF  205
//
// Synth 2.
// No pipeline
// LUT 436
// FF  201
//
//
// Synth 3.
// Pipeline, 3 stages, 16-bit
// LUT 272
// FF  140
//
//
// Synth 4.
// Pipeline, 3 stages, 16-bit, Removed overflow
// LUT 261
// FF  132
//
//
// Synth 5.
// Pipeline, 3 stages, 15-bit, Removed overflow
// LUT 245
// FF  124
//
module fft_butterfly_radix_4 #(
    parameter data_width_p = 15
  )(
    input  wire                            clk,
    input  wire                            rst_n,
    // Data flow control
    input  wire                            x_valid,
    output logic                           y_valid,
    // Input
    input  wire  signed [data_width_p-1:0] x_a_re,
    input  wire  signed [data_width_p-1:0] x_a_im,
    input  wire  signed [data_width_p-1:0] x_b_re,
    input  wire  signed [data_width_p-1:0] x_b_im,
    input  wire  signed [data_width_p-1:0] x_c_im,
    input  wire  signed [data_width_p-1:0] x_c_re,
    input  wire  signed [data_width_p-1:0] x_d_re,
    input  wire  signed [data_width_p-1:0] x_d_im,
    // Output
    output logic signed [data_width_p-1:0] y_a_re,
    output logic signed [data_width_p-1:0] y_a_im,
    output logic signed [data_width_p-1:0] y_b_re,
    output logic signed [data_width_p-1:0] y_b_im,
    output logic signed [data_width_p-1:0] y_c_re,
    output logic signed [data_width_p-1:0] y_c_im,
    output logic signed [data_width_p-1:0] y_d_re,
    output logic signed [data_width_p-1:0] y_d_im
    // Overflow status
    //output logic                           sr_overflow_underflow
  );

  typedef enum {
    stage_0_e = 0,
    stage_1_e,
    stage_2_e
  } state_t;

  state_t state;

  logic signed [data_width_p:0] y_a_re_d;
  logic signed [data_width_p:0] y_a_im_d;
  logic signed [data_width_p:0] y_b_re_d;
  logic signed [data_width_p:0] y_b_im_d;
  logic signed [data_width_p:0] y_c_re_d;
  logic signed [data_width_p:0] y_c_im_d;
  logic signed [data_width_p:0] y_d_re_d;
  logic signed [data_width_p:0] y_d_im_d;

  assign y_a_re = y_a_re_d[data_width_p-1:0];
  assign y_a_im = y_a_im_d[data_width_p-1:0];
  assign y_b_re = y_b_re_d[data_width_p-1:0];
  assign y_b_im = y_b_im_d[data_width_p-1:0];
  assign y_c_re = y_c_re_d[data_width_p-1:0];
  assign y_c_im = y_c_im_d[data_width_p-1:0];
  assign y_d_re = y_d_re_d[data_width_p-1:0];
  assign y_d_im = y_d_im_d[data_width_p-1:0];

  //assign sr_overflow_underflow = y_a_re_d[data_width_p] ^ y_a_re_d[data_width_p-1] ||
  //                               y_a_im_d[data_width_p] ^ y_a_im_d[data_width_p-1] ||
  //                               y_b_re_d[data_width_p] ^ y_b_re_d[data_width_p-1] ||
  //                               y_b_im_d[data_width_p] ^ y_b_im_d[data_width_p-1] ||
  //                               y_c_re_d[data_width_p] ^ y_c_re_d[data_width_p-1] ||
  //                               y_c_im_d[data_width_p] ^ y_c_im_d[data_width_p-1] ||
  //                               y_d_re_d[data_width_p] ^ y_d_re_d[data_width_p-1] ||
  //                               y_d_im_d[data_width_p] ^ y_d_im_d[data_width_p-1];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state                 <= stage_0_e;
      y_valid               <= '0;
      y_a_re_d              <= '0;
      y_a_im_d              <= '0;
      y_b_re_d              <= '0;
      y_b_im_d              <= '0;
      y_c_re_d              <= '0;
      y_c_im_d              <= '0;
      y_d_re_d              <= '0;
      y_d_im_d              <= '0;
    end
    else begin

      y_valid <= '0;

      case (state)
        stage_0_e: begin
          if (x_valid) begin
            state  <= stage_1_e;
            y_a_re_d <= x_a_re + x_b_re;
            y_a_im_d <= x_a_im + x_b_im;
            y_b_re_d <= x_a_re + x_b_im;
            y_b_im_d <= x_a_im - x_b_re;
            y_c_re_d <= x_a_re - x_b_re;
            y_c_im_d <= x_a_im - x_b_im;
            y_d_re_d <= x_a_re - x_b_im;
            y_d_im_d <= x_a_im + x_b_re;
          end
        end

        stage_1_e: begin
          state  <= stage_2_e;
          y_a_re_d <= y_a_re + x_c_re;
          y_a_im_d <= y_a_im + x_c_im;
          y_b_re_d <= y_b_re - x_c_re;
          y_b_im_d <= y_b_im - x_c_im;
          y_c_re_d <= y_c_re + x_c_re;
          y_c_im_d <= y_c_im + x_c_im;
          y_d_re_d <= y_d_re - x_c_re;
          y_d_im_d <= y_d_im - x_c_im;
        end

        stage_2_e: begin
          state   <= stage_0_e;
          y_valid <= 1;
          y_a_re_d  <= y_a_re + x_d_re;
          y_a_im_d  <= y_a_im + x_d_im;
          y_b_re_d  <= y_b_re - x_d_im;
          y_b_im_d  <= y_b_im + x_d_re;
          y_c_re_d  <= y_c_re - x_d_re;
          y_c_im_d  <= y_c_im - x_d_im;
          y_d_re_d  <= y_d_re + x_d_im;
          y_d_im_d  <= y_d_im - x_d_re;
        end

      endcase
    end
  end

endmodule

`default_nettype wire
