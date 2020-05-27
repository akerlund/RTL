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
## along with this program.  If not, see <https:##www.gnu.org/licenses/>.
##
## Description:
##
################################################################################

import math

def biquad_coefficients(f0, fs, q, bq_type):

  w0   = 2 * math.pi * f0 / fs
  alfa = math.sin(w0) / (2 * q)

  if (bq_type == "BQ_LP_E"):

      b0 =  (1 - math.cos(w0)) / 2
      b1 =   1 - math.cos(w0)
      b2 =  (1 - math.cos(w0)) / 2
      a0 =   1 + alfa
      a1 = -(2 * math.cos(w0))
      a2 =   1 - alfa


  if (bq_type == "BQ_HP_E"):

      b0 =  (1 + math.cos(w0)) / 2
      b1 = -(1 + math.cos(w0))
      b2 =  (1 + math.cos(w0)) / 2
      a0 =   1 + alfa
      a1 = -(2 * math.cos(w0))
      a2 =   1 - alfa


  if (bq_type == "BQ_BP_E"):

      b0 =   math.sin(w0) / 2
      b1 =   0
      b2 = -(math.sin(w0) / 2)
      a0 =   1 + alfa
      a1 = -(2 * math.cos(w0))
      a2 =   1 - alfa

  print(bq_type)
  print("w0 = %f" % w0)
  print("a  = %f" % alfa)
  print("b0 = %f" % b0)
  print("b1 = %f" % b1)
  print("b2 = %f" % b2)
  print("a0 = %f" % a0)
  print("a1 = %f" % a1)
  print("a2 = %f" % a2)


if __name__ == '__main__':

  f0      = 10000.0
  fs      = 44100.0
  q       = 1
  bq_type = "BQ_LP_E"

  biquad_coefficients(f0, fs, q, bq_type)