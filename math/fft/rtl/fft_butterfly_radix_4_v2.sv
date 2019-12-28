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
// Pipeline, 3 stages
// LUT 400
// FF  205
//
// Synth 2.
// No pipeline
//
//
//
module fft_butterfly_radix_4_v2 #(
    parameter data_width_p = 24
  )(
    input  wire                            clk,
    input  wire                            rst_n,
    // Data flow control
    input  wire                            x_valid,
    output logic                           x_ready,
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
    output logic signed [data_width_p-1:0] y_d_im,
    // Overflow status
    output logic                           sr_overflow_underflow
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

  assign sr_overflow_underflow = y_a_re_d[data_width_p] ^ y_a_re_d[data_width_p-1] ||
                                 y_a_im_d[data_width_p] ^ y_a_im_d[data_width_p-1] ||
                                 y_b_re_d[data_width_p] ^ y_b_re_d[data_width_p-1] ||
                                 y_b_im_d[data_width_p] ^ y_b_im_d[data_width_p-1] ||
                                 y_c_re_d[data_width_p] ^ y_c_re_d[data_width_p-1] ||
                                 y_c_im_d[data_width_p] ^ y_c_im_d[data_width_p-1] ||
                                 y_d_re_d[data_width_p] ^ y_d_re_d[data_width_p-1] ||
                                 y_d_im_d[data_width_p] ^ y_d_im_d[data_width_p-1];

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      state                 <= stage_0_e;
      x_ready               <= '0;
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

      x_ready <= '0;
      y_valid <= '0;

      if (x_valid) begin
        y_valid  <= 1;
        y_a_re_d <= x_a_re + x_b_re + x_c_re + x_d_re;
        y_a_im_d <= x_a_im + x_b_im + x_c_im + x_d_im;
        y_b_re_d <= x_a_re + x_b_im - x_c_re - x_d_im;
        y_b_im_d <= x_a_im - x_b_re - x_c_im + x_d_re;
        y_c_re_d <= x_a_re - x_b_re + x_c_re - x_d_re;
        y_c_im_d <= x_a_im - x_b_im + x_c_im - x_d_im;
        y_d_re_d <= x_a_re - x_b_im - x_c_re + x_d_im;
        y_d_im_d <= x_a_im + x_b_re - x_c_im - x_d_re;
      end
    end
  end

endmodule

`default_nettype wire
