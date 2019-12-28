import math
import binary_number_tools as bin_tool


# Stage 0, the first, input connections
def fft_get_butterfly_connections_stage_0(N, width):

  x_in = [x for x in range(0,N)]
  connections = []

  for x in x_in:
    b   = '{:0{width}b}'.format(x, width = width)
    rev = int(b[::-1], 2)
    connections.append(rev)

  return connections


# Last stage's input connections
def fft_get_butterfly_connections_stage_last(N):

  x_in = [x for x in range(0,N)]
  even = x_in[0::2]
  odd  = x_in[1::2]
  return even + odd


# Returns the input connections for any stage
def fft_get_butterfly_connections(N, stage, print_debug = False):

  blocks_in_stage = N//2//(2**stage)
  block_bit_width = int(math.log(N//blocks_in_stage, 2))

  # Make a list of all connecting integers
  int_list = [bin_tool.binary_digits(x,block_bit_width) for x in range(0,2**block_bit_width)]

  # Reversing all the connecting integers
  reverse = [bin_tool.bit_reverse(block_bit_width, int(x, 2)) for x in int_list]

  connections = []

  if print_debug:
    print('Stage %d' % stage)
    print('blocks_in_stage = %s' % str(blocks_in_stage))
    print('block_bit_width = %s' % str(block_bit_width))
    print('int_list = %s' % str(int_list))
    print('reverse  = %s' % str(reverse))


  # Make a list that contains all the BF block's connections
  for i in range(0, blocks_in_stage):
    for rev in reverse:
      con = rev + i*2**block_bit_width
      connections.append(con)

  return connections


# Returns the input connections for any stage
def fft_make_butterfly_connections(N, stage, print_debug = False):

  blocks_in_stage = N//2//(2**stage)
  block_bit_width = int(math.log(N//blocks_in_stage, 2))

  # Make a list of all connecting integers
  int_list = [x for x in range(0,2**block_bit_width)]

  # Separating
  even0     = int_list[0::2]
  odd0      = int_list[1::2]

  even1     = even0[:len(even0)//2]
  even2     = even0[len(even0)//2:]
  odd1      = odd0[:len(odd0)//2]
  odd2      = odd0[len(odd0)//2:]

  even = []
  for i in range(len(even1)):
    even.append(even1[i])
    even.append(even2[i])
  odd = []
  for i in range(len(odd1)):
    odd.append(odd1[i])
    odd.append(odd2[i])


  connections = []
  # Make a list that contains all the BF block's connections
  for i in range(0, blocks_in_stage):
    for eo in even + odd:
      con = eo + i*2**block_bit_width
      connections.append(con)

  if print_debug:
    print('Stage %d' % stage)

    print('even0 = %s' % str(even0))
    print('even1 = %s' % str(even1))
    print('even2 = %s' % str(even2))
    print('odd0  = %s' % str(odd0))
    print('odd1  = %s' % str(odd1))
    print('odd2  = %s' % str(odd2))

    print('even = %s' % str(even))
    print('odd  = %s' % str(odd))
    print('con  = %s' % str(even + odd))
    print('blocks_in_stage = %s' % str(blocks_in_stage))
    print('block_bit_width = %s' % str(block_bit_width))
    print('int_list        = %s' % str(int_list))
    print('connections     = %s' % str(connections))

  return connections



def test():
  N      = 16
  log2_n = int(math.log(N,2))

  print(fft_get_butterfly_connections_stage_0(N, log2_n))

  for i in range(1, log2_n):
    x = (fft_get_butterfly_connections(N, i, print_debug = True))
    print(x)

  print(fft_get_butterfly_connections_stage_last(N))



def circular_shift_right(number, shifts):

  a = number[0:-shifts]
  b = number[-shifts:]
  return b + a


def circular_shift_left(number, shifts):

  a = number[0:-shifts]
  b = number[-shifts:]
  return b + a


def beta(N, stage, print_debug = False):
  '''
  Represent the counter in binary form in log2N bits (here 4 bits).
  Circularly shift the counter s−1 times to the right.
  Bit reverse the result.
  Represent in decimal.
  '''

  print('\nstage %d' % stage)
  log2_n = int(math.log(N,2))
  int_list  = [bin_tool.binary_digits(x, log2_n) for x in range(0,N)]
  circ_list = [circular_shift_left(x, stage) for x in int_list]
  reverse   = [bin_tool.bit_reverse(log2_n, int(x, 2)) for x in circ_list]

  if print_debug:
    print(int_list)
    print(circ_list)
    print(reverse)
  return reverse


if __name__ == '__main__':
  N      = 16
  log2_n = int(math.log(N,2))
  for i in range(0, log2_n):
    fft_make_butterfly_connections(N, i, print_debug = True)
#  for i in range(0, log2_n):
#    beta(N, i, print_debug = True)