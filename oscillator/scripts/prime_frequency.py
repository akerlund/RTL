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
## Description: The Triangle generating module use a prime frequency as its
##   base. All possible triangle waves have frequencies that are lower than the
##   prime frequency as they are made from it using a clock enable module.
##   The possible frequencies are thus; f'/n, for n = 1, 2, 3, ... n - 1.
##   This script print out all possible frequencies the triangle waves can have.
##
################################################################################

import math

if __name__ == '__main__':

  PRIME_FREQUENCY_P = 1000000
  print("Start")
  for i in range(2**12, 2**12+256):
    print("%d: %i" % (i, PRIME_FREQUENCY_P/(i+1)))