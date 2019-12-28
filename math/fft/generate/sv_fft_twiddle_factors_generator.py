from cmath import exp
from cmath import pi
import numpy
import math
import float_to_fixed_point as ftfp

#
#      N-1
# Xk =  E  xn*exp(-j2*pi*kn/N)
#      n=0
#


# Returns the twiddle factors of a stage of an DFFT with a size N
def generate_fft_twiddle_factors(N, stage):

  log_N       = int(math.log(N,2))
  N_in_stage  = N // 2**(log_N-stage)
  fft_tf      = []
  ifft_tf     = []

  for _ in range(N//N_in_stage):
    for i in [exp(-2j*pi*k/N_in_stage) for k in range(N_in_stage//2)]:
      fft_tf.append(i)

  for _ in range(N//N_in_stage):
    for i in [exp(2j*pi*k/N_in_stage) for k in range(N_in_stage//2)]:
      ifft_tf.append(i)

  return fft_tf, ifft_tf

# The twiddle factors are converted into fixed point format and
# saved in separate vectors of real and imaginary values.
def generate_fixed_point_twiddle_factors(N, nr_of_n_bits, nr_of_q_bits):

  log2_N = int(math.log(N, 2))

  # We save the twiddle factors here in order to sort out duplicates later for saving FPGA resources
  fft_all_re_tf  = []
  fft_all_im_tf  = []
  ifft_all_re_tf = []
  ifft_all_im_tf = []

  # Looping through all stages
  for i in range(log2_N):

    # Call the function which generates the twiddle factors
    fft_tf, ifft_tf = generate_fft_twiddle_factors(N, i+1)

    # Converting all twiddle factors to fixed point and append them to the lists
    fft_re_tf  = []
    fft_im_tf  = []
    ifft_re_tf = []
    ifft_im_tf = []

    for w in fft_tf:
      re_fixed_point = ftfp.float_to_fixed_point(w.real, nr_of_n_bits, nr_of_q_bits)
      im_fixed_point = ftfp.float_to_fixed_point(w.imag, nr_of_n_bits, nr_of_q_bits)
      fft_re_tf.append(re_fixed_point)
      fft_im_tf.append(im_fixed_point)

    for w in ifft_tf:
      re_fixed_point = ftfp.float_to_fixed_point(w.real, nr_of_n_bits, nr_of_q_bits)
      im_fixed_point = ftfp.float_to_fixed_point(w.imag, nr_of_n_bits, nr_of_q_bits)
      ifft_re_tf.append(re_fixed_point)
      ifft_im_tf.append(im_fixed_point)

    # Saving the generated integer twiddle factors
    fft_all_re_tf.append(fft_re_tf)
    fft_all_im_tf.append(fft_im_tf)
    ifft_all_re_tf.append(ifft_re_tf)
    ifft_all_im_tf.append(ifft_im_tf)

  return fft_all_re_tf, fft_all_im_tf, ifft_all_re_tf, ifft_all_im_tf



# Generates twiddle factors as declared constants
def convert_tf_val_to_constant(all_re_tf, all_im_tf, nr_of_n_bits, nr_of_q_bits):

  twiddle_factors_re = []
  twiddle_factors_im = []

  # Real list
  for fixed_point_re in all_re_tf:
    stage = []
    for re_stage in fixed_point_re:
      float_point_re = ftfp.fixed_point_to_float(re_stage, nr_of_n_bits, nr_of_q_bits)
      float_str = ''
      if float_point_re < 0:
        float_str = 'neg_' + '{0:.9f}'.format(float_point_re)[1:].replace('.','_') + '_c'
      else:
        float_str = 'pos_' + '{0:.9f}'.format(float_point_re).replace('.','_') + '_c'
      float_str  = ('{0:0<%s}' % 9).format(float_str)
      stage.append(float_str)
    twiddle_factors_re.append(stage)

  # Imaginary list
  for fixed_point_im in all_im_tf:
    stage = []
    for im_stage in fixed_point_im:
      float_point_im = ftfp.fixed_point_to_float(im_stage, nr_of_n_bits, nr_of_q_bits)
      float_str = ''
      if float_point_im < 0:
        float_str = 'neg_' + '{0:.9f}'.format(float_point_im)[1:].replace('.','_') + '_c'
      else:
        float_str = 'pos_' + '{0:.9f}'.format(float_point_im).replace('.','_') + '_c'
      float_str  = ('{0:0<%s}' % 9).format(float_str)
      stage.append(float_str)
    twiddle_factors_im.append(stage)

  return twiddle_factors_re, twiddle_factors_im



# Generates all unique twiddle factors as localparam logics
def get_twiddle_factors(N, nr_of_n_bits, nr_of_q_bits, ifft_tf = 0):

  nr_of_bits =  nr_of_n_bits + nr_of_q_bits

  fft_all_re_tf, fft_all_im_tf, ifft_all_re_tf, ifft_all_im_tf = generate_fixed_point_twiddle_factors(N, nr_of_n_bits, nr_of_q_bits)

  tf_localparam = ''

  # First we gather all the twiddle factors from the real list
  for fixed_point_re in fft_all_re_tf[-1]:

    float_point_re = ftfp.fixed_point_to_float(fixed_point_re, nr_of_n_bits, nr_of_q_bits)
    float_str = '  localparam logic [' + str(nr_of_bits-1) + ' : 0] '

    if float_point_re < 0:
      float_str += 'neg_' + '{0:.9f}'.format(float_point_re)[1:].replace('.','_') + '_c'
    else:
      float_str += 'pos_' + '{0:.9f}'.format(float_point_re).replace('.','_') + '_c'

    float_str  = ('{0:0<%s}' % 9).format(float_str)
    float_str += ' = ' + str(nr_of_bits) + '\'b' + fixed_point_re + ';\n'

    tf_localparam += float_str

    #print(float_str)

  # We know that -1 is missing
  minus_one_fp  = ftfp.float_to_fixed_point(-1.0, nr_of_n_bits, nr_of_q_bits)
  minus_one_fl  = ftfp.fixed_point_to_float(minus_one_fp, nr_of_n_bits, nr_of_q_bits)
  float_str     = '  localparam logic [' + str(nr_of_bits-1) + ' : 0] '
  float_str    += 'neg_' + '{0:.9f}'.format(minus_one_fl)[1:].replace('.','_') + '_c'
  float_str     = ('{0:0<%s}' % 9).format(float_str)
  float_str    += ' = ' + str(nr_of_bits) + '\'b' + minus_one_fp + ';\n'
  tf_localparam += float_str

  tf_fft_re,   tf_fft_im = convert_tf_val_to_constant(fft_all_re_tf,   fft_all_im_tf, nr_of_n_bits, nr_of_q_bits)
  tf_ifft_re, tf_ifft_im = convert_tf_val_to_constant(ifft_all_re_tf, ifft_all_im_tf, nr_of_n_bits, nr_of_q_bits)

  return tf_localparam, tf_fft_re, tf_fft_im, tf_ifft_re, tf_ifft_im



if __name__ == '__main__':

  N            = 8
  nr_of_n_bits = 24
  nr_of_q_bits = 16
  print(''.join(get_twiddle_factors(N, nr_of_n_bits, nr_of_q_bits)))
  #all_constanf_tf = generate_fixed_point_twiddle_factors(64, nr_of_n_bits, nr_of_q_bits)