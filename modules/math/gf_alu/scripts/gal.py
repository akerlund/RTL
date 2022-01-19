#!/usr/bin/env python3

import galois
import argparse
import random
import math
import sys

HEADER_C = """\
__H__

package gf_ref_pkg;

localparam int M_C        = __M__;
localparam int P_ORDER_C  = __P__;
localparam int REF_SIZE_C = __REF_SIZE__;

localparam logic [M_C-1 : 0] GF_ADD_C [REF_SIZE_C] [3] = '{
__GF_ADD__
};

localparam logic [M_C-1 : 0] GF_MUL_C [REF_SIZE_C] [3] = '{
__GF_MUL__
};

localparam logic [M_C-1 : 0] GF_DIV_C [REF_SIZE_C] [3] = '{
__GF_DIV__
};

"""

def gen_gf_reference(raw_args = None):

  # ----------------------------------------------------------------------------
  # Argument parser
  # ----------------------------------------------------------------------------

  parser = argparse.ArgumentParser()
  parser.add_argument("-o", "--order", type = int, required = True, help = "M",           metavar=' ')
  parser.add_argument("-s", "--size",  type = int, required = True, help = "Table sizes", metavar=' ')
  parser.add_argument("-p", "--poly",  type = int,                  help = "Polynom",     metavar=' ')
  args  = parser.parse_args(raw_args)

  order = args.order
  if not (order != 0) & ((order & (order-1)) == 0):
    sys.exit("FATAL: Order must be a power of two")

  if args.poly:
    g_field = galois.GF(order, args.poly)
  else:
    g_field = galois.GF(order)

  print("INFO: Created a GF:")
  print(g_field.properties)

  prop  = g_field.properties.split("\n")
  prop  = ''.join(["//" + p + "\n" for p in prop])

  if args.poly:
    prop += "//  Poly (decimal): %d\n" % args.poly

  m = int(math.log2(order))

  pkg_str = HEADER_C
  pkg_str = pkg_str.replace("__H__", str(prop))
  pkg_str = pkg_str.replace("__M__", str(m))
  pkg_str = pkg_str.replace("__P__", str(order))
  pkg_str = pkg_str.replace("__REF_SIZE__", str(args.size))

  # Addition and subtraction
  gf_ref = ""
  for i in range(args.size):
    int0   = random.randint(0, order-1)
    int1   = random.randint(0, order-1)
    gf0    = g_field([int0])
    gf1    = g_field([int1])
    gf_add = gf0 + gf1
    gf_ref += "  '{%s,%s,%s}" % (int0, int1, gf_add.data[0])
    if i != args.size-1:
      gf_ref += ",\n"
  pkg_str = pkg_str.replace("__GF_ADD__", gf_ref)

  # Multiplication
  gf_ref = ""
  for i in range(args.size):
    int0   = random.randint(0, order-1)
    int1   = random.randint(0, order-1)
    gf0    = g_field([int0])
    gf1    = g_field([int1])
    gf_mul = gf0 * gf1
    gf_ref += "  '{%s,%s,%s}" % (int0, int1, gf_mul.data[0])
    if i != args.size-1:
      gf_ref += ",\n"
  pkg_str = pkg_str.replace("__GF_MUL__", gf_ref)

  # Division
  gf_ref = ""
  for i in range(args.size):
    int0   = random.randint(0, order-1)
    int1   = random.randint(1, order-1)
    gf_div = gf0 / gf1
    gf_ref += "  '{%s,%s,%s}" % (int0, int1, gf_div.data[0])
    if i != args.size-1:
      gf_ref += ",\n"
  pkg_str = pkg_str.replace("__GF_DIV__", gf_ref)


  pkg_str += "endpackage\n"
  file_name = "gf_ref_pkg.sv"
  with open(file_name, 'w') as file:
    file.write(pkg_str)

if __name__ == "__main__":
  gen_gf_reference()
