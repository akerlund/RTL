import math

def radian_to_degree(radian):
  return radian*180/math.pi

def cordic_angles(stages, phase_bits):

  gain = 1.0

  for k in range(stages):

    gain = gain * math.sqrt(1 + 2**(-2*k))
    phase = math.atan(2**-k) * 4.0 * (1 << (phase_bits-2)) / (math.pi * 2.0)

    # Truncate phase, turn binary and fill withh zero's
    bin_phase = bin(int(phase))[2:].zfill(phase_bits)

    print("atan_table[%2d] = %2d\'h%s; // %3.9f deg" % (k, phase_bits, bin_phase, radian_to_degree(phase)))

  print("Gain = %f" % gain)
  x_max = 2**(phase_bits-1)
  x_in = math.floor(x_max / gain)
  print("X in = %i" % x_in)




cordic_angles(31,16)