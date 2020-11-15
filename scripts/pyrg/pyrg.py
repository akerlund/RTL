#!/usr/bin/env python3

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

import os, sys, shutil, glob
import pyrg_uvm
import pyrg_axi


if __name__ == '__main__':

  this_path = os.path.dirname(os.path.abspath(sys.argv[0]))

  if (len(sys.argv) != 2):
    sys.exit("ERROR [yml] Provide a YML file with register definitions")

  yml_files = os.listdir(sys.argv[1])
  yml_files = glob.glob(sys.argv[1]+"/*.yml")

  if (len(yml_files) == 0):
    sys.exit("ERROR [yml] No files found")

  for yml in yml_files:

    pyrg_uvm.generate_uvm(yml)
    pyrg_axi.generate_axi(yml)


  shutil.rmtree(this_path + "/__pycache__")
