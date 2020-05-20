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
// FFT butterfly using a 6 clock cycle pipeline with 1 multiplicator
//
////////////////////////////////////////////////////////////////////////////////

`default_nettype none

module fft_butterfly_lite_4 #(
    parameter int data_width_p   = -1,
    parameter int nr_of_q_bits_p = -1
  )(
    // Clock and reset
    input  wire                            clk,
    input  wire                            rst_n,
    // Data flow control
    input  wire                            x_valid,
    output logic                           x_ready,
    output logic                           y_valid,
    // Inputs (x0, x1) real and imaginary vectors
    input  wire  signed [data_width_p-1:0] x0_re,
    input  wire  signed [data_width_p-1:0] x0_im,
    input  wire  signed [data_width_p-1:0] x1_re,
    input  wire  signed [data_width_p-1:0] x1_im,
    // Output (y0, y1) real and imaginary vectors
    output logic signed [data_width_p-1:0] y0_re,
    output logic signed [data_width_p-1:0] y0_im,
    output logic signed [data_width_p-1:0] y1_re,
    output logic signed [data_width_p-1:0] y1_im,
    // Twiddle factors
    input  wire  signed [data_width_p-1:0] cr_twiddle_re,
    input  wire  signed [data_width_p-1:0] cr_twiddle_im,
    // Overflow status
    output logic                           sr_overflow,
    output logic                           sr_underflow
  );

  localparam int mul_high_c = nr_of_q_bits_p + data_width_p - 1;
  localparam int mul_low_c  = nr_of_q_bits_p;

  typedef enum {
    stage_0_e = 0,
    stage_1_e,
    stage_2_e,
    stage_3_e,
    stage_4_e,
    stage_5_e
  } state_t;

  state_t state;

  logic signed     [data_width_p:0] y0_re_d;
  logic signed     [data_width_p:0] y1_re_d;
  logic signed     [data_width_p:0] y0_im_d;
  logic signed     [data_width_p:0] y1_im_d;

  logic signed [2*data_width_p-1:0] mul_reg_0;
  logic signed [2*data_width_p-1:0] mul_reg_1;

  logic signed   [data_width_p-1:0] mul_reg_0_section;
  logic signed   [data_width_p-1:0] mul_reg_1_section;

  logic signed     [data_width_p:0] shift_sub_re;
  logic signed     [data_width_p:0] shift_add_im;

  assign mul_reg_0_section = mul_reg_0[mul_high_c:mul_low_c];
  assign mul_reg_1_section = mul_reg_1[mul_high_c:mul_low_c];

  assign y0_re = y0_re_d[data_width_p-1:0];
  assign y1_re = y1_re_d[data_width_p-1:0];
  assign y0_im = y0_im_d[data_width_p-1:0];
  assign y1_im = y1_im_d[data_width_p-1:0];

  assign sr_overflow  = y0_re_d[data_width_p]      ^ y0_re_d[data_width_p-1] ||
                        y0_im_d[data_width_p]      ^ y0_im_d[data_width_p-1] ||
                        shift_add_im[data_width_p] ^ shift_add_im[data_width_p-1];

  assign sr_underflow = y1_re_d[data_width_p]      ^ y1_re_d[data_width_p-1] ||
                        y1_im_d[data_width_p]      ^ y1_im_d[data_width_p-1] ||
                        shift_sub_re[data_width_p] ^ shift_sub_re[data_width_p-1];

  always_ff @ (posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state        <= stage_0_e;
      x_ready      <= '0;
      y_valid      <= '0;
      y0_re_d      <= '0;
      y0_im_d      <= '0;
      y1_re_d      <= '0;
      y1_im_d      <= '0;
      mul_reg_0    <= '0;
      mul_reg_1    <= '0;
      shift_sub_re <= '0;
      shift_add_im <= '0;
    end
    else begin

      x_ready <= '0;
      y_valid <= '0;

      case (state)

        stage_0_e: begin
          x_ready     <= 1;
          if (x_valid) begin
            state     <= stage_1_e;
            x_ready   <= '0;
            y0_re_d   <= '0;
            y1_re_d   <= '0;
            y0_im_d   <= '0;
            y1_im_d   <= '0;
            mul_reg_0 <= x1_re * cr_twiddle_re;
          end
        end

        stage_1_e: begin
          state     <= stage_2_e;
          mul_reg_0 <= x1_im * cr_twiddle_im;
          mul_reg_1 <= mul_reg_0;
        end


        stage_2_e: begin
          state        <= stage_3_e;
          mul_reg_0    <= x1_re * cr_twiddle_im;
          shift_sub_re <= mul_reg_1_section - mul_reg_0_section;
        end


        stage_3_e: begin
          state     <= stage_4_e;
          mul_reg_0 <= x1_im * cr_twiddle_re;
          mul_reg_1 <= mul_reg_0;
          y0_re_d   <= x0_re + shift_sub_re;
          y1_re_d   <= x0_re - shift_sub_re;
        end


        stage_4_e: begin
          state        <= stage_5_e;
          shift_add_im <= mul_reg_1_section + mul_reg_0_section;
        end


        stage_5_e: begin
          state   <= stage_0_e;
          y_valid <= 1;
          y0_im_d <= x0_im + shift_add_im;
          y1_im_d <= x0_im - shift_add_im;
        end

      endcase

    end
  end

endmodule

`default_nettype wire