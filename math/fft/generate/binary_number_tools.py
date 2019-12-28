# Reverses bits
def bit_reverse(bit_width, n):
  b = '{:0{width}b}'.format(n, width = bit_width)
  return int(b[::-1], 2)

# Return the number as binary digits
def binary_digits(n, bits):
  s = bin(n & int("1" * bits, 2))[2:]
  return ("{0:0>%s}" % (bits)).format(s)