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
from datetime import date

def generate_uvm(yaml_file_path):

  this_path           = os.path.dirname(os.path.abspath(sys.argv[0]))
  uvm_reg_file_path   = this_path + "/templates/uvm_reg.sv"
  uvm_block_file_path = this_path + "/templates/uvm_block.sv"
  field_template_path = this_path + "/templates/reg_field.txt"
  header_file_path    = this_path + "/templates/header.txt"


  rtl_path = '/'.join(yaml_file_path.split('/')[:-2]) + "/rtl/"
  uvm_path = '/'.join(yaml_file_path.split('/')[:-2]) + "/tb/uvm_reg/"
  sw_path  = '/'.join(yaml_file_path.split('/')[:-2]) + "/sw/"

  if not os.path.exists(rtl_path):
      os.makedirs(rtl_path)

  if not os.path.exists(uvm_path):
      os.makedirs(uvm_path)

  if not os.path.exists(sw_path):
      os.makedirs(uvm_path)

  # ----------------------------------------------------------------------------
  # Loading in the templates
  # ----------------------------------------------------------------------------

  uvm_reg = ""
  with open(uvm_reg_file_path, 'r') as file:
    uvm_reg = file.read()

  uvm_block = ""
  with open(uvm_block_file_path, 'r') as file:
    uvm_block = file.read()

  header = ""
  with open(header_file_path, 'r') as file:
    header = file.read()

  field_template = ""
  with open(field_template_path, 'r') as file:
    field_template = file.read()

  # ----------------------------------------------------------------------------
  # Loading in the YAML file and the UVM templates
  # ----------------------------------------------------------------------------

  # Variables for storing the YAML file contents
  block_name     = None
  block_contents = None

  with open(yaml_file_path, 'r') as file:

    yaml_reg = yaml.load(file, Loader = yaml.FullLoader)

    block_name, block_contents = list(yaml_reg.items())[0]

  # ----------------------------------------------------------------------------
  # PART 1
  # Creating all register classes and their uvm_reg_field's
  # ----------------------------------------------------------------------------

  # First information in the file
  BLOCK_NAME    = block_name
  BASE_ADDR     = block_contents['base_addr']
  BUS_BIT_WIDTH = block_contents['bus_width']
  ACRONYM       = block_contents['acronym'].upper()

  UVM_BUILD      = ""

  register_names = [] # Used later to generate the register block
  sv_address_map = []
  c_address_map  = []

  # We are saving the generated "uvm_reg" classes in this variable
  reg_classes = header.replace("DATE", str(date.today()))

  # Iterating through the list of registers
  for reg in block_contents['registers']:

    reg_name   = reg['name']
    reg_access = "\"" + reg['access'] + "\""
    reg_class  = uvm_reg.replace("CLASS_DESCRIPTION", reg['desc'])

    register_names.append((reg_name, reg_access))
    sv_address_map.append("  localparam logic [%d : 0] %s_%s_ADDR" % ((int(BUS_BIT_WIDTH)-1), ACRONYM, reg_name.upper()))
    c_address_map.append("  #define %s_%s_ADDR" % (ACRONYM, reg_name.upper()))

    reg_field_declarations = ""

    # Generating the fields of the register
    for field in reg['bit_fields']:

      reg_field_declarations += "  rand uvm_reg_field %s;\n" % field['field']['name']

      _field_instance         = "%s = uvm_reg_field::type_id::create(\"%s\");" % (field['field']['name'], field['field']['name'])
      _field_size_description = field['field']['description']
      _field_name             = field['field']['name']
      _field_size             = str(field['field']['size'])
      _field_lsb_pos          = str(field['field']['lsb_pos'])


      _reg_field = field_template
      _reg_field = _reg_field.replace("FIELD_INSTANCE",    _field_instance)
      _reg_field = _reg_field.replace("FIELD_DESCRIPTION", _field_size_description)
      _reg_field = _reg_field.replace("FIELD_NAME",        _field_name)
      _reg_field = _reg_field.replace("FIELD_SIZE",        _field_size)
      _reg_field = _reg_field.replace("FIELD_LSB_POS",     _field_lsb_pos)
      _reg_field = _reg_field.replace("FIELD_ACCESS",      reg_access)


      if ("reset_value" in field['field'].keys()):
        _reg_field = _reg_field.replace("FIELD_RESET",     str(field['field']['reset_value']))
        _reg_field = _reg_field.replace("FIELD_HAS_RESET", str(1))
      else:
        _reg_field = _reg_field.replace("FIELD_RESET",     str(0))
        _reg_field = _reg_field.replace("FIELD_HAS_RESET", str(0))

      UVM_BUILD += _reg_field


    reg_class = reg_class.replace("REG_NAME",               (reg_name + "_reg"))
    reg_class = reg_class.replace("UVM_FIELD_DECLARATIONS", reg_field_declarations)
    reg_class = reg_class.replace("UVM_REG_SIZE",           str(BUS_BIT_WIDTH)) # Not all bits need to be implemented.
    reg_class = reg_class.replace("UVM_BUILD",              UVM_BUILD)

    reg_classes += reg_class
    UVM_BUILD    = ""

  # Write the register classes to file
  output_file = uvm_path + BLOCK_NAME + "_reg.sv"
  with open(output_file, 'w') as file:
    file.write(reg_classes)

  print("INFO [pyrg] Generated %s" % output_file)





  # ----------------------------------------------------------------------------
  # PART 2.1
  # Creating the System Verilog address map
  # ----------------------------------------------------------------------------

  longest_name = 0
  for addr in sv_address_map:
    if len(addr) > longest_name:
      longest_name = len(addr)

  for i in range(len(sv_address_map)):
    sv_address_map[i] = sv_address_map[i].ljust(longest_name, " ") + " = %d'h" % BUS_BIT_WIDTH + str(hex(i*4)[2:].zfill(4)).upper() + ";\n"

  ADDRESS_HIGH = ("  localparam logic [%d : 0] " % (int(BUS_BIT_WIDTH)-1) + ACRONYM + "_HIGH_ADDRESS").ljust(longest_name, " ") +\
                  " = %d'h" % BUS_BIT_WIDTH + str(hex(len(sv_address_map)*4)[2:].zfill(4)).upper() + ";\n"

  pkt_top  = ""
  pkt_top += "`ifndef %s\n"   % (BLOCK_NAME.upper() + "_ADDRESS_PKG")
  pkt_top += "`define %s\n" % (BLOCK_NAME.upper() + "_ADDRESS_PKG")
  pkt_top += "\n"
  pkt_top += "package %s;\n\n" % (BLOCK_NAME + "_address_pkg")

  pkt_bot  = "\n\n"
  pkt_bot  = "\nendpackage\n\n`endif\n"

  output_file = rtl_path + BLOCK_NAME + "_address_pkg.sv"
  with open(output_file, 'w') as file:
    file.write(header.replace("DATE", str(date.today())))
    file.write(pkt_top)
    file.write(ADDRESS_HIGH)
    file.write(''.join(sv_address_map))
    file.write(pkt_bot)

  print("INFO [pyrg] Generated %s" % output_file)


  # ----------------------------------------------------------------------------
  # PART 2.1
  # Creating the C address map
  # ----------------------------------------------------------------------------

  longest_name = 0
  for addr in c_address_map:
    if len(addr) > longest_name:
      longest_name = len(addr)

  for i in range(len(c_address_map)):
    c_address_map[i] = c_address_map[i].ljust(longest_name, " ") +\
                       " 0x%s\n" % str(hex(i*4)[2:].zfill(4)).upper()

  ADDRESS_HIGH = ("  #define %s" % (ACRONYM + "_HIGH_ADDRESS")).ljust(longest_name, " ") +\
                  " 0x%s\n" % str(hex(len(c_address_map)*4)[2:].zfill(4)).upper()

  pkt_top  = ""
  pkt_top += "#ifndef %s\n"   % (BLOCK_NAME.upper() + "_ADDRESS_H")
  pkt_top += "#define %s\n" % (BLOCK_NAME.upper() + "_ADDRESS_H")
  pkt_top += "\n"

  pkt_bot  = "\n#endif\n"

  output_file = sw_path + BLOCK_NAME + "_address.h"
  with open(output_file, 'w') as file:
    file.write(header.replace("DATE", str(date.today())))
    file.write(pkt_top)
    file.write(ADDRESS_HIGH)
    file.write(''.join(c_address_map))
    file.write(pkt_bot)

  print("INFO [pyrg] Generated %s" % output_file)


  # ----------------------------------------------------------------------------
  # PART 3
  # Creating the register block
  # ----------------------------------------------------------------------------

  UVM_REG_DECLARATIONS = ""
  UVM_BUILD            = ""
  UVM_ADD              = ""
  offset   = 0
  MAP_NAME = "\"" + BLOCK_NAME + "_map\""

  for (reg, access) in register_names:

    UVM_REG_DECLARATIONS += "  rand %s_reg %s;\n" % (reg, reg)

    UVM_BUILD += "    %s = %s_reg::type_id::create(\"%s\");\n" % (reg, reg, reg)
    UVM_BUILD += "    %s.build();\n" % (reg)
    UVM_BUILD += "    %s.configure(this);\n\n" % (reg)

    _access = ""
    if 'R' in access:
      if 'W' in access:
        _access = "\"RW\""
      else:
        _access = "\"RO\""
    else:
      _access = "\"WO\""

    UVM_ADD += "    default_map.add_reg(%s, %d, %s);\n" % (reg, offset, _access)

    offset += BUS_BIT_WIDTH/8

  block = header.replace("DATE", str(date.today())) + uvm_block
  block = block.replace("CLASS_NAME",           (BLOCK_NAME + "_block"))
  block = block.replace("UVM_REG_DECLARATIONS", UVM_REG_DECLARATIONS)
  block = block.replace("UVM_BUILD",            UVM_BUILD)
  block = block.replace("MAP_NAME",             MAP_NAME)
  block = block.replace("BASE_ADDR",            BASE_ADDR)
  block = block.replace("BUS_BIT_WIDTH",        str(BUS_BIT_WIDTH))
  block = block.replace("UVM_ADD",              UVM_ADD)


  # Write the register block to file
  output_file = uvm_path + BLOCK_NAME + "_block.sv"
  with open(output_file, 'w') as file:
    file.write(block)

  print("INFO [pyrg] Generated %s" % output_file)
