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

# Reverses bits
def bit_reverse(bit_width, n):
  b = '{:0{width}b}'.format(n, width = bit_width)
  return int(b[::-1], 2)

# Return the number as binary digits
def binary_digits(n, bits):
  s = bin(n & int("1" * bits, 2))[2:]
  return ("{0:0>%s}" % (bits)).format(s)