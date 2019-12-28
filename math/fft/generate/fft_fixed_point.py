import float_to_fixed_point as ftfp
import binary_number_tools  as bin_tool
from cmath import exp
from cmath import pi
import random
import numpy

def fixed_multiply(a, b, n, q):
  x = ftfp.fixed_point_to_float(a, n, q)
  y = ftfp.fixed_point_to_float(b, n, q)
  z = x*y >> q*2 -1
  print('x = %d' % x)
  print('y = %d' % y)
  print('zb = %d' % z)

  return bin_tool.binary_digits(z, n+q)


def fft_fixed_point(x, nr_of_n_bits, nr_of_q_bits):

  N = len(x)

  if N <= 1:
    return [ftfp.round_to_fixed_point_decimals(f, nr_of_n_bits, nr_of_q_bits) for f in x]

  even = fft_fixed_point(x[0::2], nr_of_n_bits, nr_of_q_bits)
  odd  = fft_fixed_point(x[1::2], nr_of_n_bits, nr_of_q_bits)

  T = []
  for k in range(N//2):
    w = ftfp.complex_round_to_fixed_point_decimals(exp(-2j*pi*k/N), nr_of_n_bits, nr_of_q_bits)
    odd_k = ftfp.complex_round_to_fixed_point_decimals(odd[k], nr_of_n_bits, nr_of_q_bits)
    T.append(ftfp.complex_round_to_fixed_point_decimals(w*odd_k, nr_of_n_bits, nr_of_q_bits))

  return [ftfp.complex_round_to_fixed_point_decimals(even[k] + T[k], nr_of_n_bits, nr_of_q_bits) for k in range(N//2)] + \
         [ftfp.complex_round_to_fixed_point_decimals(even[k] - T[k], nr_of_n_bits, nr_of_q_bits) for k in range(N//2)]



def ifft_recursive_fixed_point(x, nr_of_n_bits, nr_of_q_bits):

  N = len(x)

  if N <= 1:
    return [ftfp.round_to_fixed_point_decimals(f, nr_of_n_bits, nr_of_q_bits) for f in x]

  even = ifft_recursive_fixed_point(x[0::2], nr_of_n_bits, nr_of_q_bits)
  odd  = ifft_recursive_fixed_point(x[1::2], nr_of_n_bits, nr_of_q_bits)

  T = []
  for k in range(N//2):
    w = ftfp.complex_round_to_fixed_point_decimals(exp(2j*pi*k/N), nr_of_n_bits, nr_of_q_bits)
    T.append(ftfp.complex_round_to_fixed_point_decimals(w*odd[k], nr_of_n_bits, nr_of_q_bits))

  return [(even[k] + T[k]) for k in range(N//2)] + \
         [(even[k] - T[k]) for k in range(N//2)]



def ifft_fixed_point(x, nr_of_n_bits, nr_of_q_bits):

  N    = len(x)
  ifft = ifft_recursive_fixed_point(x, nr_of_n_bits, nr_of_q_bits)

  # The imaginary part really low, around e-17 and should not be there at all
  # so we only return the real part. The real parts also have a rounding error
  # which is why we call round()
  return [ round(f.real)/N for f in ifft ]



def fft_fixed_point_error(time_data, nr_of_n_bits, nr_of_q_bits):

  fft_ref     = numpy.fft.fft(time_data)
  fft_f_data  = fft_fixed_point(time_data, nr_of_n_bits, nr_of_q_bits)
  #ifft_t_data = ifft_fixed_point(fft_f_data, nr_of_n_bits, nr_of_q_bits)

  fft_ref_abs    = []
  fft_f_data_abs = []

  for a in fft_ref:
    fft_ref_abs.append(abs(a))

  for a in fft_f_data:
    fft_f_data_abs.append(abs(a))

  fft_f_data_abs_errors = []
  max_error = 0.0
  for i in range(len(time_data)):
    error = abs(fft_ref_abs[i] - fft_f_data_abs[i]) / fft_ref_abs[i]
    fft_f_data_abs_errors.append(error)
    if error > max_error:
      max_error = error

  error_avg = sum(fft_f_data_abs_errors) / len(time_data)

  return error_avg, max_error*100



def run_test():

  N0_exp       = 3
  N1_exp       = 12
  q0           = 1
  q1           = 20
  loops        = 128
  nr_of_n_bits = 24

  N = []
  for n in range(N0_exp, N1_exp+1):
    N.append(2**n)

  """ The for loop will construct, e.g., 10 lists, each with
      the range of q's measured errors
  """
  errors_list = []

  for n in N:
    print('Looping for N = %d' % n)
    q_list = []

    for q_bits in range(q0, q1+1):
      print('Number of q-bits = %d' % q_bits)
      loop_avg = []
      loop_max = []

      for _ in range(loops):
        time_data            = [random.randint(0, 2**nr_of_n_bits-1) for x in range(n)]
        error_avg, max_error = fft_fixed_point_error(time_data, nr_of_n_bits, q_bits)
        loop_avg.append(error_avg)
        loop_max.append(max_error)

      #print('sum(loop_avg) = %d' % sum(loop_avg))
      #print('max(loop_max) = %d' % max(loop_max))
      q_list.append([q_bits, sum(loop_avg)/loops, max(loop_max)])
    errors_list.append(q_list)

  N = 2**N0_exp

  all_N     = 'all_N   = ['
  all_q     = 'all_q   = [' + str(q0) + ':' + str(q1) + ']\n'
  all_max   = 'all_max = ['
  all_avg   = 'all_avg = ['
  e_str_avg = ''
  e_str_max = ''
  for q_list in errors_list:
    all_N     += ''    + str(N) + ' '
    all_max   += 'e_N' + str(N) + '_avg '
    all_avg   += 'e_N' + str(N) + '_max '
    e_str_avg += 'e_N' + str(N) + '_avg = [ '
    e_str_max += 'e_N' + str(N) + '_max = [ '

    for q in q_list:
      q_bits, error_avg, max_error = q
      e_str_avg += str(error_avg) + '; '
      e_str_max += str(max_error) + '; '

    N = 2*N

    e_str_avg += '];\n'
    e_str_max += '];\n'

  all_N     += '];\n'
  all_max   += '];\n'
  all_avg   += '];\n'

  print(e_str_avg)
  print(e_str_max)
  print(all_N)
  print(all_q)
  print(all_max)
  print(all_avg)

  with open('matlab_file.m', 'w') as file:
    file.write(e_str_avg)
    file.write(e_str_max)
    file.write(all_N)
    file.write(all_q)
    file.write(all_max)
    file.write(all_avg)


if __name__ == '__main__':

#  time_data = [-33.546875, 19.484375, -50.75, -2.1640625, -50.8359375, -34.5625, 18.6640625, 5.7578125, -15.2109375, 35.734375, 32.1953125, -33.125, -48.3671875, -35.734375, 58.28125, -23.96875]
#  nr_of_n_bits = 11
#  nr_of_q_bits = 8-1
#  f = fft_fixed_point(time_data, nr_of_n_bits, nr_of_q_bits)
#  for w in f:
#    print(w)
#
#  fft_fixed_point(time_data, nr_of_n_bits, nr_of_q_bits)

  #run_test()
  print('Multiply test')
  a = '00000010000000'
  b = '00000010000000'
  n = 8
  q = 8
  print(fixed_multiply(a, b, n, q))













