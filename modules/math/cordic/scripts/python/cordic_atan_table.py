import math
import float_to_fixed_point as ftfp

def radian_to_degree(radian):
  return radian*180/math.pi


def cordic_tan_radians(stages, n, q):


  for k in range(stages):

    rad  = ftfp.float_to_fixed_point(math.atan(2**-k),n,q)
    print("%2d\'b%s; // atan(2^-%d) -> %3.12f degrees -> %3.12f radians" % (n+q, rad, k, radian_to_degree(math.atan(2**-k)), math.atan(2**-k)))


def cordic_gains(stages, n, q):

  gain = 1.0

  for k in range(stages):

    gain = gain * math.sqrt(1 + 2**(-2*k))
    x_in = 1 / gain
    print("%s'b%s, // -> %1.12f (Gain for %i stages = %1.12f)" % (n+q, ftfp.float_to_fixed_point(x_in,n,q), x_in, k+1, gain))


def generate_fixed_point_pi_values(n, q, sign = 1):

  pi_1_4 = ftfp.float_to_fixed_point(sign*1*math.pi/4, n, q)
  pi_2_4 = ftfp.float_to_fixed_point(sign*2*math.pi/4, n, q)
  pi_3_4 = ftfp.float_to_fixed_point(sign*3*math.pi/4, n, q)
  pi_4_4 = ftfp.float_to_fixed_point(sign*4*math.pi/4, n, q)
  pi_5_4 = ftfp.float_to_fixed_point(sign*5*math.pi/4, n, q)
  pi_6_4 = ftfp.float_to_fixed_point(sign*6*math.pi/4, n, q)
  pi_7_4 = ftfp.float_to_fixed_point(sign*7*math.pi/4, n, q)
  pi_8_4 = ftfp.float_to_fixed_point(sign*8*math.pi/4, n, q)

  print("%s'b%s // 45  deg = %3.12f rad" % (n+q, pi_1_4, sign*1*math.pi/4))
  print("%s'b%s // 90  deg = %3.12f rad" % (n+q, pi_2_4, sign*2*math.pi/4))
  print("%s'b%s // 135 deg = %3.12f rad" % (n+q, pi_3_4, sign*3*math.pi/4))
  print("%s'b%s // 180 deg = %3.12f rad" % (n+q, pi_4_4, sign*4*math.pi/4))
  print("%s'b%s // 225 deg = %3.12f rad" % (n+q, pi_5_4, sign*5*math.pi/4))
  print("%s'b%s // 270 deg = %3.12f rad" % (n+q, pi_6_4, sign*6*math.pi/4))
  print("%s'b%s // 315 deg = %3.12f rad" % (n+q, pi_7_4, sign*7*math.pi/4))
  print("%s'b%s // 360 deg = %3.12f rad" % (n+q, pi_8_4, sign*8*math.pi/4))


def gen_positive_radian_spin_data():

  n = 4
  q = 28

  steps = 360
  phase_increment = 2*math.pi/steps

  for k in range(steps):
    print("%s'b%s," % (32, ftfp.float_to_fixed_point(k*phase_increment,n,q)))


def gen_negative_radian_spin_data():

  n = 4
  q = 28

  steps = 360
  phase_increment = -2*math.pi/steps

  for k in range(steps):
    print("%s'b%s," % (32, ftfp.float_to_fixed_point(k*phase_increment,n,q)))




if __name__ == '__main__':

  n      = 4
  q      = 60
  stages = 31

  #cordic_tan_radians(stages, n, q)
  #cordic_gains(stages, n, q)
  generate_fixed_point_pi_values(n, q)
  #gen_positive_radian_spin_data()
  #gen_negative_radian_spin_data()