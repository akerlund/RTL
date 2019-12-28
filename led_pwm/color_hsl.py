import gamma_table as gt

def colorHSL ( hue,  sat,  light):

  tR   = 0
  tG   = 0
  tB   = 0
  frac = (6*hue) >> 12

  # Chroma.
  C = ((4095 - abs( (light << 1) - 4095)) * sat) >> 12

  X = (C * (4095 - abs((6*hue % 8192) - 4095))) >> 12

	# Hue.
  if(frac== 0):
    tR = C
    tG = X
    tB = 0
  elif (frac == 1):
    tR = X
    tG = C
    tB = 0
  elif (frac == 2):
    tR = 0
    tG = C
    tB = X
  elif (frac == 3):
    tR = 0
    tG = X
    tB = C
  elif (frac == 4):
    tR = X
    tG = 0
    tB = C
  elif (frac == 5):
    tR = C
    tG = 0
    tB = X

	# Lightness.	
  m = light - (C>>1)
  tR += m
  tG += m
  tB += m

  print("Chroma = %d" % C)
  print("X = %d" % X)
  print("m = %d" % m)
  print("frac = %d" % frac)
  print("red = %d" % gt.gamma_table[tR])
  print("green = %d" % gt.gamma_table[tG])
  print("blue = %d" % gt.gamma_table[tB])

colorHSL( 1333,  2895,  3333)