def fft_tb_generator(N, nr_of_integer_bits, nr_of_fractional_bits):

  dut_name = 'fft_N%s_Q%s_%s_core' % ( str(N), str(nr_of_integer_bits), str(nr_of_fractional_bits) )
  tb_name  = 'tb_fft_N%s_Q%s_%s'   % ( str(N), str(nr_of_integer_bits), str(nr_of_fractional_bits) )

  fft_tb  = '`timescale 1ns/1ps\n\n'
  fft_tb += 'import %s_test_data_pkg::*;\n\n' % tb_name

  fft_tb += 'module %s;\n' % tb_name
  fft_tb += '''
  logic                    clk;
  logic                    rst_n;

  logic                    x_valid;
  logic                    x_ready;
  logic                    y_valid;

  logic [data_width_c-1:0] x_re [nr_of_samples_c];
  logic [data_width_c-1:0] x_im [nr_of_samples_c];

  logic [data_width_c-1:0] y_re [nr_of_samples_c];
  logic [data_width_c-1:0] y_im [nr_of_samples_c];

  logic                    cr_fft_or_ifft;
  logic                    sr_overflow;
  logic                    sr_underflow;

  int test_counter;
  int nr_of_failed_tests;

  real error_threshold_c = 0.2;

  // Clock generation
  initial begin
    clk = 1'b0;
    forever clk = #4.0 ~clk;
  end

  // Reset logic
  initial begin
    rst_n       = 1'b0;
    #10ns rst_n = 1'b1;
  end


  // This function takes a fixed point binary value and returns it as a floating point
  function real fixed_point_to_float(input logic signed [data_width_c-1:0] fixed_point,
                                     input int nr_of_q_bits);
    fixed_point_to_float = int'(fixed_point)/real'(2**nr_of_q_bits);
  endfunction


  // Float absolute
  function real fabs(input real a);
    if (a < 0) begin
      fabs = -a;
    end
    else begin
      fabs = a;
    end
  endfunction


  // This task compares two logic arrays and prints out a message if they differ
  function int compare_fft(input logic [data_width_c-1:0] y_result[nr_of_samples_c],
                           input logic [data_width_c-1:0] y_reference[nr_of_samples_c]);
    real real_y_result;
    real real_y_reference;
    real real_y_differ;
    compare_fft = 1;

    for (int i = 0; i < nr_of_samples_c; i++) begin
      real_y_result    = fabs(fixed_point_to_float(y_result[i], nr_of_q_bits_c));
      real_y_reference = fabs(fixed_point_to_float(y_reference[i], nr_of_q_bits_c));
      real_y_differ    = fabs(real_y_result - real_y_reference);
      if ( real_y_differ > error_threshold_c ) begin
        $display("Data %0d incorrect %4.6f != %4.6f",i, real_y_result, real_y_reference);
        compare_fft = 0;
      end
    end
  endfunction


  // Main simulation sequence
  initial begin

    // Reset
    x_re           <= '{default:0};
    x_im           <= '{default:0};
    x_valid        <= '0;
    cr_fft_or_ifft <= '0;

    test_counter       = 0;
    nr_of_failed_tests = 0;

    @(posedge rst_n);
    $display("Reset complete");

    $display("Running %d tests", nr_of_tests_c);

    for (int i = 0; i < nr_of_tests_c; i++) begin

      $display("Test number %d", i);
      test_counter = i;

      for (int j = 0; j < nr_of_samples_c; j++) begin
        x_re[j] <= x_test_data_re[i][j];
        x_im[j] <= '0;
      end

      wait (x_ready == 1);
      x_valid <= 1'b1;

      wait (x_ready == '0);
      x_valid <= '0;

      wait (y_valid == 1);

      if (sr_overflow) begin
        $display("Overflow detected");
      end

      if (sr_underflow) begin
        $display("Underflow detected");
      end

      if (!compare_fft(y_re, y_test_data_re[i])) begin
        $error("Real part was wrong");
        nr_of_failed_tests++;
      end

      if (!compare_fft(y_im, y_test_data_im[i])) begin
        $error("Imag part was wrong");
      end
    end

   if (!nr_of_failed_tests) begin
     $display("All %0d tests passed", nr_of_tests_c);
   end
   else begin
     $display("%0d tests did not pass", nr_of_failed_tests);
   end

    $display("Finished");
    $finish;
  end\n\n'''

  fft_tb += '''
  %s #(
    .data_width_p    ( data_width_c    ),
    .nr_of_samples_p ( nr_of_samples_c ),
    .nr_of_q_bits_p  ( nr_of_q_bits_c  )
  ) %s_i0 (
    .clk             ( clk             ),
    .rst_n           ( rst_n           ),
    .x_valid         ( x_valid         ),
    .x_ready         ( x_ready         ),
    .y_valid         ( y_valid         ),
    .x_re            ( x_re            ),
    .x_im            ( x_im            ),
    .y_re            ( y_re            ),
    .y_im            ( y_im            ),
    .cr_fft_or_ifft  ( cr_fft_or_ifft  ),
    .sr_overflow     ( sr_overflow     ),
    .sr_underflow    ( sr_underflow    )
  );\n\nendmodule''' % (dut_name, dut_name)

  file_name = '../tb/%s.sv' % tb_name
  with open(file_name, 'w') as tb_file:
    tb_file.write(fft_tb)

if __name__ == '__main__':

  N                     = 8
  nr_of_integer_bits    = 8
  nr_of_fractional_bits = 8

  fft_tb_generator(N, nr_of_integer_bits, nr_of_fractional_bits)