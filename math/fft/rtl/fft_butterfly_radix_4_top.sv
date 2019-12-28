`default_nettype none

module fft_butterfly_radix_4_top #(
    parameter int data_width_p    = -1,
    parameter int nr_of_samples_p = -1
  )(
    input  wire                            clk,
    input  wire                            rst_n,
    // Data flow control
    input  wire                            x_valid,
    output logic                           y_valid,
    // Input
    input  wire  signed [data_width_p-1:0] x_re [nr_of_samples_p],
    input  wire  signed [data_width_p-1:0] x_im [nr_of_samples_p],
    // Output
    output logic signed [data_width_p-1:0] y_re [nr_of_samples_p],
    output logic signed [data_width_p-1:0] y_im [nr_of_samples_p],
    // Overflow status
    output logic                           sr_overflow_underflow
  );

  localparam int N_c               = nr_of_samples_p;
  localparam int log2_N_c          = $clog2(N_c);
  localparam int nr_of_butterflies = N_c / 4; //4096/4=1024

  logic                   y_valid_d [log2_N_c][nr_of_butterflies];
  logic [data_width_p-1:0] y_a_re [log2_N_c-1][nr_of_butterflies];
  logic [data_width_p-1:0] y_a_im [log2_N_c-1][nr_of_butterflies];
  logic [data_width_p-1:0] y_b_re [log2_N_c-1][nr_of_butterflies];
  logic [data_width_p-1:0] y_b_im [log2_N_c-1][nr_of_butterflies];
  logic [data_width_p-1:0] y_c_re [log2_N_c-1][nr_of_butterflies];
  logic [data_width_p-1:0] y_c_im [log2_N_c-1][nr_of_butterflies];
  logic [data_width_p-1:0] y_d_re [log2_N_c-1][nr_of_butterflies];
  logic [data_width_p-1:0] y_d_im [log2_N_c-1][nr_of_butterflies];

  logic sr_overflow_underflow_d [log2_N_c][nr_of_butterflies];

  assign sr_overflow_underflow = sr_overflow_underflow_d[log2_N_c-1][0];
  assign y_valid =  y_valid_d [log2_N_c-1][nr_of_butterflies-1];
  genvar i;
  genvar j;

  // Input stage
  generate
    for (j = 0; j < nr_of_butterflies; j++) begin
      fft_butterfly_radix_4 #(
        .data_width_p          ( data_width_p                 )
      ) fft_butterfly_radix_4_i (
        .clk                   ( clk                          ),
        .rst_n                 ( rst_n                        ),
        .x_valid               ( x_valid                      ),
        .y_valid               ( y_valid_d[0][j]                ),
        .x_a_re                ( x_re[j*4 + 0]                ),
        .x_a_im                ( x_im[j*4 + 0]                ),
        .x_b_re                ( x_re[j*4 + 1]                ),
        .x_b_im                ( x_im[j*4 + 1]                ),
        .x_c_im                ( x_re[j*4 + 2]                ),
        .x_c_re                ( x_im[j*4 + 2]                ),
        .x_d_re                ( x_re[j*4 + 3]                ),
        .x_d_im                ( x_im[j*4 + 3]                ),
        .y_a_re                ( y_a_re[0][j]                 ),
        .y_a_im                ( y_a_im[0][j]                 ),
        .y_b_re                ( y_b_re[0][j]                 ),
        .y_b_im                ( y_b_im[0][j]                 ),
        .y_c_re                ( y_c_re[0][j]                 ),
        .y_c_im                ( y_c_im[0][j]                 ),
        .y_d_re                ( y_d_re[0][j]                 ),
        .y_d_im                ( y_d_im[0][j]                 ),
        .sr_overflow_underflow ( sr_overflow_underflow_d [0][j] )
      );
    end
        endgenerate


  // Middle stages
  generate
    for (i = 1; i < log2_N_c-1; i++) begin //stage  1 to 8, so not 0 and 9
      for (j = 0; j < nr_of_butterflies; j++) begin
        fft_butterfly_radix_4 #(
          .data_width_p          ( data_width_p                 )
      ) fft_butterfly_radix_4_i (
          .clk                   ( clk                          ),
          .rst_n                 ( rst_n                        ),
          .x_valid               ( y_valid_d[i-1][j]              ),
          .y_valid               ( y_valid_d[i][j]                ),
          .x_a_re                ( y_a_re[i-1][j]               ),
          .x_a_im                ( y_a_im[i-1][j]               ),
          .x_b_re                ( y_b_re[i-1][j]               ),
          .x_b_im                ( y_b_im[i-1][j]               ),
          .x_c_im                ( y_c_re[i-1][j]               ),
          .x_c_re                ( y_c_im[i-1][j]               ),
          .x_d_re                ( y_d_re[i-1][j]               ),
          .x_d_im                ( y_d_im[i-1][j]               ),
          .y_a_re                ( y_a_re[i][j]                 ),
          .y_a_im                ( y_a_im[i][j]                 ),
          .y_b_re                ( y_b_re[i][j]                 ),
          .y_b_im                ( y_b_im[i][j]                 ),
          .y_c_re                ( y_c_re[i][j]                 ),
          .y_c_im                ( y_c_im[i][j]                 ),
          .y_d_re                ( y_d_re[i][j]                 ),
          .y_d_im                ( y_d_im[i][j]                 ),
          .sr_overflow_underflow ( sr_overflow_underflow_d [0][j] )
        );
      end
    end
  endgenerate

  // Output stage
  generate
    for (j = 0; j < nr_of_butterflies; j++) begin
      fft_butterfly_radix_4 #(
        .data_width_p          ( data_width_p                          )
      ) fft_butterfly_radix_4_i (
        .clk                   ( clk                                   ),
        .rst_n                 ( rst_n                                 ),
        .x_valid               ( y_valid_d[log2_N_c-2][j]              ),
        .y_valid               ( y_valid_d[log2_N_c-1][j]              ),
        .x_a_re                ( y_a_re[log2_N_c-2][j]                 ),
        .x_a_im                ( y_a_im[log2_N_c-2][j]                 ),
        .x_b_re                ( y_b_re[log2_N_c-2][j]                 ),
        .x_b_im                ( y_b_im[log2_N_c-2][j]                 ),
        .x_c_im                ( y_c_re[log2_N_c-2][j]                 ),
        .x_c_re                ( y_c_im[log2_N_c-2][j]                 ),
        .x_d_re                ( y_d_re[log2_N_c-2][j]                 ),
        .x_d_im                ( y_d_im[log2_N_c-2][j]                 ),
        .y_a_re                ( y_re[j*4 + 0]                         ),
        .y_a_im                ( y_im[j*4 + 0]                         ),
        .y_b_re                ( y_re[j*4 + 1]                         ),
        .y_b_im                ( y_im[j*4 + 1]                         ),
        .y_c_re                ( y_re[j*4 + 2]                         ),
        .y_c_im                ( y_im[j*4 + 2]                         ),
        .y_d_re                ( y_re[j*4 + 3]                         ),
        .y_d_im                ( y_im[j*4 + 3]                         ),
        .sr_overflow_underflow ( sr_overflow_underflow_d [log2_N_c-1][j] )
      );
    end
        endgenerate

endmodule

`default_nettype wire
