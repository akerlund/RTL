# multiply(x,y){
#    for (i=1; i=<B; i++){
#       if (x > 0)
#          x = x - 2^(-i)
#          z = z + y*2^(-i)
#       else
#          x = x + 2^(-i)
#          z = z - y*2^(-i)
#    }
#    return(z)
# }
# log10(x){
#    z = 0;
#    for ( i=1;i=<B;i++ ){
#       if (x > 1)
#          x = x - x*2^(-i);
#          z = z - log10(1-2^(-i));
#        else
#          x = x + x*2^(-i);
#          z = z - log10(1+2^(-i));
#    }
#    return(z)
# }

# Listing Five
# 10_to_power(x){
#    z = 1;
#    for ( i=1;i=<B; i++ ){
#       if (x > 0)
#          x = x - log10(1+2^(-i));
#          z = z + z*2^(-i);
#       else
#          x = x - log10(1-2^(-i));
#          z = z - z*2^(-i);
#    }
#    return(z)
# }

def cordic_divide(x, y, stages):

  z = 0

  for i in range(1, stages):
    if x > 0:
      x = x - y*2**(-i)
      z = z + 2**(-i)
      print("x0 = %f, z0 = %f" % (x, z))
    else:
      x = x + y*2**(-i)
      z = z - 2**(-i)
      print("x1 = %f, z2 = %f" % (x, z))
  return z


def cordic_divide_4_quartant(x, y, stages):

  z = 0

  for i in range(1, stages):
    if x > 0:
      if y > 0:
        x = x - y*2**(-i)
        z = z + 2**(-i)
      else:
        x = x + y*2**(-i)
        z = z - 2**(-i)
    else:
      if y > 0:
        x = x + y*2**(-i)
        z = z - 2**(-i)
      else:
        x = x - y*2**(-i)
        z = z + 2**(-i)
  return z



if __name__ == '__main__':

  stages   = 16
  dividend_c0 = -0.1
  divisor_c0  = -0.5
  quotient = cordic_divide_4_quartant(dividend_c0, divisor_c0, stages)

  print("%f / %f = %f" % (divisor_c0, divisor_c0, quotient))
