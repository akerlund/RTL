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

from cmath import exp
from cmath import pi
import numpy
import math

def cround(c):
  return round(c.real, 3) + round(c.imag, 3) * 1j

def fft(x, debug = False):

  N = len(x)

  if N <= 1:
    return x

  even = fft(x[0::2], debug)
  odd  = fft(x[1::2], debug)

  T = [ exp(-2j*pi*k/N)*odd[k] for k in range(N//2)]

  if debug:
    print('----------------------------------------')
    print('N = %d' % (N))
    print('even =')
    print(even)
    print('odd =')
    print(odd)
    print('Twiddle factors:')
    for w in [ exp(-2j*pi*k/N) for k in range(N//2)]:
      print(w)

    print('\nProducts are:')
    for k in range(N//2):
      print('exp(-2j*pi*%d/%d)*odd[%d] = %s*%s = %s' %(k, N, k, str(exp(-2j*pi*k/N)), str(cround(odd[k])), str(cround(T[k]))))


    print('Result:')
    for k in range(N//2):
      a = ('even[%d] + T[%d] = %s' % (k, k, str(cround(even[k]))))
      b = ('even[%d] - T[%d] = %s' % (k, k, str(cround(even[k]))))
      c = str(cround(T[k]))
      print(a.ljust(25) + ' + ' + c.ljust(10) + (' = %s' % (str(cround(even[k] + T[k])))))
      print(b.ljust(25) + ' - ' + c.ljust(10) + (' = %s' % (str(cround(even[k] - T[k])))))

  return [even[k] + T[k] for k in range(N//2)] + \
         [even[k] - T[k] for k in range(N//2)]


def ifft_recursive(x):

  N = len(x)

  if N <= 1:
    return x

  even = ifft_recursive(x[0::2])
  odd  = ifft_recursive(x[1::2])

  T = [exp(2j*pi*k/N)*odd[k] for k in range(N//2)]

  return [(even[k] + T[k]) for k in range(N//2)] + \
         [(even[k] - T[k]) for k in range(N//2)]


def ifft(x):

  N    = len(x)
  ifft = ifft_recursive(x)

  # The imaginary part really low, around e-17 and should not be there at all
  # so we only return the real part. The real parts also have a rounding error
  # which is why we call round()
  return [ round(f.real)/N for f in ifft ]


def test(time_data):

  fft_ref     = numpy.fft.fft(time_data)
  ifft_ref    = numpy.real(numpy.fft.ifft(fft_ref))

  fft_f_data  = fft(time_data)
  ifft_t_data = ifft(fft_f_data)

  print('Original time data')
  print(time_data)
  print('Numpy FFT')
  print(fft_ref)
  print('Implemented FFT')
  print(fft_f_data)
  print('Numpy IFFT')
  print(ifft_ref)
  print('Implemented IFFT')
  print(ifft_t_data)

def test_8():
  #time_data_8 = [0,1,0,1,0,1,0,1]
  #time_data_8 = [1,0,1,0,1,0,1,0]
  time_data_8 = [1,1,1,1,0,0,0,0]
  time_data_8 = [255.75,255.75,255.75,255.75,255.75,255.75,255.75,255.75]
  time_data_8 = [-5.0, 2.0, 2.0, 5.0, 0.0, -3.0, -7.0, -5.0]

  #time_data_8 = [-16.51953125,46.2734375,81.0703125,120.08984375,-126.31640625,-100.67578125,-74.25390625,16.61328125]
  #time_data_8 = [-51.52734375, -10.80859375, -2.78515625, -0.67578125, -27.22265625, 41.40625, 5.34765625, -29.640625]
  _ = fft(time_data_8, debug = True)
  print('\n\nNumpy')
  for n in numpy.fft.fft(time_data_8):
    print(n)


def test_16():
  time_data_16 = [-21.6953125, 49.296875, -51.3203125, 19.8671875, 28.7734375, -12.6953125, 44.2890625, 18.9609375, 23.515625, -48.8515625, -38.0625, 16.5078125, 47.8359375, -57.46875, -12.9921875, 17.28125]
  _ = fft(time_data_16, debug = True)

  print('\n\nNumpy')
  for n in numpy.fft.fft(time_data_16):
    print(n)


def test_32(N):
  #time_data_16 = [1000, 1230, 1800, 2300, 2700, 3000, 3350, 3670, 3350, 3000, 2700, 2300, 1800, 1230, 1000, 750]
  time_data_32 = [1000, 1230, 1800, 2300, 2700, 3000, 3350, 3670, 3350, 3000, 2700, 2300, 1800, 1230, 1000, 750, 1000, 1230, 1800, 2300, 2700, 3000, 3350, 3670, 3350, 3000, 2700, 2300, 1800, 1230, 1000, 750]
  test(time_data_32)

if __name__ == '__main__':
  test_8()