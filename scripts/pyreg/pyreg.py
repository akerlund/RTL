#!/usr/bin/env python3

################################################################################
##
## Copyright (C) 2020 Fredrik ��kerlund
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

import os, sys, shutil
import pyreg_uvm
import pyreg_axi


if __name__ == '__main__':

  this_path = os.path.dirname(os.path.abspath(sys.argv[0]))

  yml_files = [
    (this_path + "register_example.yml")
  ]

  for yml in yml_files:

    pyreg_uvm.generate_uvm(yml)
    pyreg_axi.generate_axi(yml)

  shutil.rmtree(this_path + "/__pycache__")
