################################################################################
##
## Copyright (C) 2020 Fredrik Åkerlund
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <https://www.gnu.org/licenses/>.
##
## Description:
##
################################################################################

import binary_number_tools as bin_tool
import math

# Converts floating point numbers to fixed point
# Returns the number as a string
def float_to_fixed_point(float_number, nr_of_integer_bits, nr_of_fractional_bits):

  float_f    = float_number * (2**nr_of_fractional_bits)
  nr_of_bits = nr_of_integer_bits + nr_of_fractional_bits
  int_f      = int(float_f)

  binary_n   = int(bin_tool.binary_digits(int_f, nr_of_bits)) # Can lose one digit if negative

  # If it is a positive number
  fixed_p    = str(binary_n).zfill(nr_of_bits)

  if False:
    print('float_f    = %f' % (float_f))
    print('nr_of_bits = %d' % (nr_of_bits))
    print('int_f      = %d' % (int_f))
    print('binary_n   = %d' % (binary_n))
    print('fixed_p    = %s' % (fixed_p))


  if int_f < 0:
    fixed_p  = ~binary_n
    fixed_p += 1
    fixed_p  = str(fixed_p)[1:].rjust(nr_of_bits,'1')

  return fixed_p


# Converts fixed point numbers to float point
def fixed_point_to_float(fixed_point, nr_of_integer_bits, nr_of_fractional_bits):

  nr_of_bits      = nr_of_integer_bits + nr_of_fractional_bits
  int_fixed_point = int(fixed_point, 2)
  is_negative     = fixed_point[0]

  if int(is_negative) == 1:
    int_fixed_point = int(bin_tool.binary_digits(~int_fixed_point, nr_of_bits), 2) + 1
    return float(-int_fixed_point / (2**nr_of_fractional_bits))
  return float(int_fixed_point / (2**nr_of_fractional_bits))


# Rounds of floats to an accuracy of a fixed point
def round_to_fixed_point_decimals(float_number, nr_of_integer_bits, nr_of_fractional_bits):

  f = float_to_fixed_point(float_number, nr_of_integer_bits, nr_of_fractional_bits)
  return fixed_point_to_float(f, nr_of_integer_bits, nr_of_fractional_bits)


# Rounds of complex numbers to an accuracy of a fixed point
def complex_round_to_fixed_point_decimals(complex_number, nr_of_integer_bits, nr_of_fractional_bits):

  float_number = complex_number.real
  fp           = float_to_fixed_point(float_number, nr_of_integer_bits, nr_of_fractional_bits)
  r            = fixed_point_to_float(fp, nr_of_integer_bits, nr_of_fractional_bits)

  float_number = complex_number.imag
  fp           = float_to_fixed_point(float_number, nr_of_integer_bits, nr_of_fractional_bits)
  i            = fixed_point_to_float(fp, nr_of_integer_bits, nr_of_fractional_bits)

  return complex(r,i)


# Returns the maximum and minimum of a fixed point number
def get_max_and_min(nr_of_integer_bits, nr_of_fractional_bits):
  max_fixed = '0' + (nr_of_integer_bits+nr_of_fractional_bits-1)*'1'
  min_fixed = '1' + (nr_of_integer_bits+nr_of_fractional_bits-1)*'0'

  return fixed_point_to_float(max_fixed, nr_of_integer_bits, nr_of_fractional_bits),\
         fixed_point_to_float(min_fixed, nr_of_integer_bits, nr_of_fractional_bits)

# Prints out the error of a fixed point number compared to a floating point
def convertion_analyze(float_number, nr_of_integer_bits, nr_of_fractional_bits):

  rounded = round_to_fixed_point_decimals(float_number, nr_of_integer_bits, nr_of_fractional_bits)
  error   = (math.sqrt(2) - rounded) / float_number * 100

  r0 = '{0:.16f}'.format(float_number)
  r1 = '{0:.16f}'.format(rounded)
  r2 = '{0:.16f}'.format(error)
  print("%s was rounded to %s, error is = %s%% with %d q-bits\n" % (r0, r1, r2, nr_of_fractional_bits))


# Example test
def test_example():

  float_number = -1
  nr_of_integer_bits = 8
  nr_of_fractional_bits = 8
  fp           = float_to_fixed_point(float_number, nr_of_integer_bits, nr_of_fractional_bits)

  print('%f converted to %s' % (float_number, fp))
  print('(%s.%s)' % (fp[:nr_of_integer_bits], fp[nr_of_integer_bits:]))


def test_numbers():
  n = 9
  q = 8

  xb_re = -8.1328125
  cr_re =  -1
  mul   = xb_re*cr_re
  fake  = -59.8671875

  xb_re_fp = float_to_fixed_point(xb_re,n,q)
  cr_re_fp = float_to_fixed_point(cr_re,n,q)
  mul_fp   = float_to_fixed_point(mul,2*n,2*q)
  mul_fl   = fixed_point_to_float(mul_fp[n:n+n+q], n, q)
  fake_fp  = float_to_fixed_point(fake,n,q)

  print('xb_re   = ' + xb_re_fp)
  print('cr_re   = ' + cr_re_fp)
  print('mul_fp  = ' + mul_fp)
  print('mul_fp  = ' + mul_fp[n:n+n+q])
  print('mul_fl  = ' + str(mul_fl))
  print('fake_fp = ' + fake_fp)



if __name__ == '__main__':

  n = 8
  q = 7

  print(fixed_point_to_float('111101100001001001', n, q))


  print(get_max_and_min(n, q))