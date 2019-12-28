import float_to_fixed_point as fl2fp
import fft_fixed_point      as fft_fixed
import binary_number_tools  as bin_tool
import cmath, math
import random

def generate_tb_fft_data(nr_of_test, N, nr_of_integer_bits, nr_of_fractional_bits):

  pkg_name = 'tb_fft_N%s_Q%s_%s_test_data_pkg' % ( str(N), str(nr_of_integer_bits), str(nr_of_fractional_bits))

  #  N | gain_bits
  #  8 | 3
  # 16 | 4
  gain_bits = int(math.log(N,2))

  width        = nr_of_integer_bits + nr_of_fractional_bits
  q_max, q_min = fl2fp.get_max_and_min(nr_of_integer_bits-gain_bits, nr_of_fractional_bits)

  # Inputs in fixed point format
  x_inputs = []

  # Inputs in floating point format
  x_floats_inputs = []
  # Generating the inputs x(t)
  for _ in range(nr_of_test):
    x_in_fixed_point = []
    x_in_float_point = []
    for _ in range(N):
      # Random float
      random_float       = float(random.uniform(q_min, q_max))
      # Converting the random to fixed point
      random_fixed_point = fl2fp.float_to_fixed_point(random_float, nr_of_integer_bits, nr_of_fractional_bits)
      # Saving the fixed point as the input for the package file
      x_in_fixed_point.append(bin_tool.binary_digits(int(random_fixed_point,2), width))
      # Converting the fixed point back to float for generating correct y values
      x_in_float_point.append(fl2fp.fixed_point_to_float(random_fixed_point, nr_of_integer_bits, nr_of_fractional_bits))
    x_inputs.append(x_in_fixed_point)
    x_floats_inputs.append(x_in_float_point)

  # Outputs of fft_fixed_point in float format
  fft_fixed_point_floats_y = []

  # FFT FIXED POINT - Using the fft_fixed_point to generate the correct Y(w) values
  for x_in in x_floats_inputs:
    fft_fixed_point_floats_y.append(fft_fixed.fft_fixed_point(x_in, nr_of_integer_bits, nr_of_fractional_bits))

  # Converted outputs of fft_fixed_point to fixed point
  y_outputs_re = []
  y_outputs_im = []

  # Convering the float output to fft_fixed_point_floats_y point
  for y_float in fft_fixed_point_floats_y:

    y_out_re = []
    y_out_im = []

    y_float_largest  = 0
    y_float_smallest = 0

    for y in y_float:

      y_float_re = y.real
      y_float_im = y.imag

      y_fixed_point_re = fl2fp.float_to_fixed_point(y_float_re, nr_of_integer_bits, nr_of_fractional_bits)
      y_fixed_point_im = fl2fp.float_to_fixed_point(y_float_im, nr_of_integer_bits, nr_of_fractional_bits)

      y_out_re.append(y_fixed_point_re)
      y_out_im.append(y_fixed_point_im)

      if y_float_re > y_float_largest:  y_float_largest  = y_float_re
      if y_float_re < y_float_smallest: y_float_smallest = y_float_re
      if y_float_im > y_float_largest:  y_float_largest  = y_float_im
      if y_float_im < y_float_smallest: y_float_smallest = y_float_im

    y_outputs_re.append(y_out_re)
    y_outputs_im.append(y_out_im)


  # Writing the data to a file
  logic  = '// There is a gain of %s bits, therefore:\n' % str(gain_bits)
  logic += '// Maximum input size is %s\n'  % str(q_max)
  logic += '// Minimum input size is %s\n'  % str(q_min)
  q_max, q_min = fl2fp.get_max_and_min(nr_of_integer_bits, nr_of_fractional_bits)
  logic += '// Maximum output size is %s\n' % str(q_max)
  logic += '// Minimum output size is %s\n' % str(q_min)
  logic += '//\n'
  logic += '// Smallest output is %s\n' % str(y_float_smallest)
  logic += '// Largest  output is %s\n\n' % str(y_float_largest)

  logic += 'package ' + pkg_name + ';\n\n'
  logic += 'localparam int nr_of_tests_c   = %s;\n'   % str(nr_of_test)
  logic += 'localparam int data_width_c    = %s;\n'   % str(width)
  logic += 'localparam int nr_of_samples_c = %s;\n'   % str(N)
  logic += 'localparam int nr_of_n_bits_c  = %s;\n'   % str(nr_of_integer_bits)
  logic += 'localparam int nr_of_q_bits_c  = %s;\n\n' % str(nr_of_fractional_bits)

  # The real part of x(t)
  logic += 'logic [%s : 0] x_test_data_re [nr_of_tests_c][%s] = {\n' % (str(width-1), str(N))
  i = 0
  j = 0
  for x_in in x_inputs:

    array  = ", ".join(map(str, x_floats_inputs[i]))
    logic += '  // x_re_%s = [%s]\n  {\n' % (str(i), str(array))
    j = 0
    for x in x_in:
      x_as_float = fl2fp.fixed_point_to_float(x, nr_of_integer_bits, nr_of_fractional_bits)
      if not j == N-1:
        logic += '    %s\'b%s,' % (str(width), str(x))
      else:
        logic += '    %s\'b%s ' % (str(width), str(x))
      logic += '  // %s\n' % str(x_as_float)
      j += 1
    if not i == nr_of_test-1:
      logic += '  },\n'
    else:
      logic += '  }\n'
    i += 1
  logic += '};\n'


  # The real part of y(t)
  logic += '\n\nlogic [%s : 0] y_test_data_re [nr_of_tests_c][%s] = {\n' % (str(width-1), str(N))
  i = 0
  j = 0
  for y_out in y_outputs_re:

    array  = ", ".join(map(str, [cmplx.real for cmplx in fft_fixed_point_floats_y[i]]))
    logic += '  // y_re_%s = [%s]\n  {\n' % (str(i), str(array))
    j = 0
    for y in y_out:
      y_as_float = fl2fp.fixed_point_to_float(y, nr_of_integer_bits, nr_of_fractional_bits)
      if not j == N-1:
        logic += '    %s\'b%s,' % (str(width), str(y))
      else:
        logic += '    %s\'b%s ' % (str(width), str(y))
      logic += '  // %s\n' % str(y_as_float)
      j += 1
    if not i == nr_of_test-1:
      logic += '  },\n'
    else:
      logic += '  }\n'
    i += 1
  logic += '};\n'


  # The imaginary part of y(t)
  logic += '\n\nlogic [%s : 0] y_test_data_im [nr_of_tests_c][%s] = {\n' % (str(width-1), str(N))
  i = 0
  j = 0
  for y_out in y_outputs_im:

    array  = ", ".join(map(str, [cmplx.imag for cmplx in fft_fixed_point_floats_y[i]]))
    logic += '  // y_im_%s = [%s]\n  {\n' % (str(i), str(array))
    j = 0
    for y in y_out:
      y_as_float = fl2fp.fixed_point_to_float(y, nr_of_integer_bits, nr_of_fractional_bits)
      if not j == N-1:
        logic += '    %s\'b%s,' % (str(width), str(y))
      else:
        logic += '    %s\'b%s ' % (str(width), str(y))
      logic += '  // %s\n' % str(y_as_float)
      j += 1

    if not i == nr_of_test-1:
      logic += '  },\n'
    else:
      logic += '  }\n'
    i += 1
  logic += '};\n'

  logic += '\nendpackage'

  file_name = '../tb/%s.sv' % pkg_name
  with open(file_name, 'w') as fft_test_data_file:
    fft_test_data_file.write(logic)



if __name__ == '__main__':

  nr_of_test            = 4
  N                     = 8
  data_width            = 16
  nr_of_integer_bits    = 8
  nr_of_fractional_bits = data_width - nr_of_integer_bits

  generate_tb_fft_data(nr_of_test, N, nr_of_integer_bits, nr_of_fractional_bits)