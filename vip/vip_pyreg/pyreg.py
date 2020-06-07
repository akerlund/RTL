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
## Description: Demonstrating how a yaml file with information about registers
## can be parsed and printed.
##
################################################################################

import yaml
import sys, os

if __name__ == '__main__':

  yaml_file = os.path.dirname(os.path.abspath(sys.argv[0])) + '/test_apb_slave.yml'

  with open(yaml_file, 'r') as file:

    reg_file = yaml.load(file, Loader=yaml.FullLoader)

    for register in reg_file:

      for reg in reg_file[register]:

        print('Name = %s' % reg['name'])
        print('Type = %s' % reg['type'])
        print('Mode = %s' % reg['mode'])
        print('Desc = %s' % reg['desc'])
        print('\n')

        for field in reg['bit_fields']:

          print('Name        = %s' % field['field']['name'])
          print('Description = %s' % field['field']['description'])
          print('Reset Value = %s' % field['field']['reset_value'])
          print('Size        = %s' % field['field']['size'])
          print('\n')

        print('\n')
        print('\n')
        print('\n')
