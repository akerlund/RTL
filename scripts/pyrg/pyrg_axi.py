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
import itertools, operator
from datetime import date

def sort_uniq(sequence):
  return map(operator.itemgetter(0),
             itertools.groupby(sorted(sequence)))

def generate_axi(yaml_file_path):

  this_path          = os.path.dirname(os.path.abspath(sys.argv[0]))
  axi_template_path  = this_path + "/templates/axi4_reg_slave.sv"
  header_file_path   = this_path + "/templates/header.txt"

  # ----------------------------------------------------------------------------
  # Loading in the templates
  # ----------------------------------------------------------------------------

  header = ""
  with open(header_file_path, 'r') as file:
    header = file.read()

  axi_template = ""
  with open(axi_template_path, 'r') as file:
    axi_template = file.read()

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
  # Creating all register classes and their uvm_reg_field's
  # ----------------------------------------------------------------------------

  # First information in the file
  BLOCK_NAME      = block_name
  #BASE_ADDR       = block_contents['base_addr']
  #BUS_BYTE_WIDTH  = block_contents['bus_width']
  BLOCK_ACRONYM   = block_contents['acronym'].upper()

  # Variables for construction the AXI slave
  #MODULE_NAME
  rtl_parameters       = [] # Size fields which are strings are considered parameters
  rtl_ports            = [] # We list all ports we generate as tuples (IO, PORT_WIDTH, FIELD_NAME)
  rtl_resets           = [] # If a reset value is specified for a register we add in this list
  rtl_cmd_registers    = [] # Save all 'cmd_' registers here, used later to set them to '0' as default
  all_rtl_writes       = "" # Contains the RTL writes
  all_rtl_reads        = "" # Contains the RTL reads
  all_rtl_rc_update    = "" # Contains the RTL update of RC registers

  reg_all_fields       = [] # If a register contains 2 or more fields, we save them here because
                            # we need to finish iterating through all fields so we later can make the
                            # assignment like, e.g., "{f2, f1, f0} <= wdata;"
  reg_rc_accessed      = {} # ReadAndClear registers
  reg_rc_declarations  = []
  reg_rom_declarations = []

  rtl_parameters.append("AXI_DATA_WIDTH_P")
  rtl_parameters.append("AXI_ADDR_WIDTH_P")


  # Iterating through the list of registers
  for reg in block_contents['registers']:

    # Register information
    reg_name   = reg['name']
    reg_access = reg['access']

    # Generate RTL code (for fields) are appended to these
    _reg_writes = []
    _reg_reads  = []

    nr_of_fields = len(reg['bit_fields'])

    # Check if this register has access type RC (Read and Clear)
    if (reg_access in ["RC"]):
      reg_rc_accessed[reg_name] = []

    # --------------------------------------------------------------------------
    # Iterating through the fields
    # --------------------------------------------------------------------------
    for field in reg['bit_fields']:

      # Field variables
      _field_name        = field['field']['name']
      #_field_description = field['field']['description']
      _field_size        = field['field']['size']
      _field_lsb_pos     = field['field']['lsb_pos']
      _field_type        = _field_name.split("_")[0].upper() # Register have the naming: prefix_block_register

      # ------------------------------------------------------------------------
      # rtl_ports
      # Deciding the port's width declaration
      # ------------------------------------------------------------------------

      # If the size is a string, i.e., a constant
      if (isinstance(_field_size, str)):
        _port_width = "[%s-1 : 0]" % (_field_size)
        rtl_parameters.append(_field_size)
      # If the size is just one bit
      elif (_field_size == 1):
        _port_width = " "
      # Else, any other integer
      else:
        _port_width = "[%s : 0]" % (str(_field_size-1))

      if (_field_type in ["CR", "CMD"]):
        rtl_ports.append(("    output logic ", _port_width, _field_name))
      elif (_field_type in ["SR", "IRQ"]):
        rtl_ports.append(("    input  wire  ", _port_width, _field_name))
      elif (_field_type in ["ROM"]):
        reg_rom_declarations.append((_port_width, _field_name))

      # Declaration of Read and Clear registers
      if (reg_access in ["RC"]):
        reg_rc_declarations.append((_port_width, _field_name))


      # ------------------------------------------------------------------------
      # rtl_resets
      # Only registers with the key 'reset_value' are appended to this list
      # ------------------------------------------------------------------------

      if ("reset_value" in field['field'].keys()):
        rtl_resets.append((_field_name, field['field']['reset_value']))

      if (reg_access in ["RC"]):
        rtl_resets.append(("rc_" + _field_name, 0))

      # ------------------------------------------------------------------------
      # rtl_cmd_registers
      # Used later to set their default value to '0' because they are
      # supposed to be strobe signals
      # ------------------------------------------------------------------------

      if (_field_type in ["CMD"]):
        rtl_cmd_registers.append(_field_name)

      # ------------------------------------------------------------------------
      # all_rtl_writes
      # all_rtl_reads
      # ------------------------------------------------------------------------

      _axi_range = ""

      # If this register contains only one field
      if nr_of_fields == 1:

        # Calculating the AXI range
        if (isinstance(_field_size, str)):
          # NOTE: The lsb position must be an integer
          if (_field_lsb_pos == 0):
            _axi_range = "%s-1 : 0" % (_field_size)
          else:
            _axi_range = "%s+%s-1 : %s" % (_field_size, _field_lsb_pos, _field_lsb_pos)
        # If the size is just one bit we do not have to define a range
        elif (_field_size == 1):
          _axi_range = _field_lsb_pos
        # Else, any other integer
        else:
          _axi_range = "%s : 0" % (str(_field_size-1))

        # Writes
        if (reg_access in ["WO", "RW"]):
          _write = 12*" " + _field_name + (" <= wdata[%s]" % (_axi_range))
          _reg_writes.append(_write)

        # Reads
        if (reg_access in ["RO", "RW", "ROM"]):
          _read = 8*" " + ("rdata_d0[%s] = ") % (_axi_range) + _field_name
          _reg_reads.append(_read)

        # Read and Clear
        if (reg_access in ["RC"]):
          reg_rc_accessed[reg_name].append(_field_name)
          _read  = 6*" " + ("rdata_d0[%s] = rc_") % (_axi_range) + _field_name
          _read += 6*" " + "rc_" + _field_name + " <= '0"
          _reg_reads.append(_read)

      else:

        if (reg_access in ["RC"]):
          reg_rc_accessed[reg_name].append(_field_name)

      # ------------------------------------------------------------------------
      # If there are more than one fields we make assignments instead
      # ------------------------------------------------------------------------

      if (nr_of_fields != 1) and not (reg_access in ["RC"]):
        reg_all_fields.append(_field_name)



    # --------------------------------------------------------------------------
    # End of field the iteration
    # --------------------------------------------------------------------------



    # For register with more than one field we make assignments
    if len(reg_all_fields):

      # Reversing reg_all_fields so that the first fields is placed at the lowest bits
      _fields_concatenated = ', '.join(reg_all_fields[::-1])

      if (reg_access in ["WO", "RW"]):
        _write = 12*" " + "{" + _fields_concatenated + "} <= wdata"
        _reg_writes.append(_write)

      if (reg_access in ["RO", "RW"]):
        _read = 12*" " + "rdata_d0 = " + "{" + _fields_concatenated + "}"
        _reg_reads.append(_read)


      reg_all_fields = []

    # Read And Clear
    if reg_name in reg_rc_accessed.keys() and len(reg_rc_accessed[reg_name]):

      _fields_concatenated    = ", ".join(reg_rc_accessed[reg_name][::-1])
      _rc_fields_concatenated = "rc_" + ", rc_".join(reg_rc_accessed[reg_name][::-1])
      # AXI Read operation
      _read  = 12*" " + "rdata_d0 = " + "{" + _rc_fields_concatenated + "};\n" # Assign the AXI read bus
      _read += 12*" " + "{" + _rc_fields_concatenated + "} <= '0"             # Clear the "rc_" fields
      _reg_reads.append(_read)

      # Update of the corresponding "rc_" registers
      _rc_update  = 6*' ' + "if (|{%s}) begin\n" % _fields_concatenated
      _rc_update += 6*' ' + "  {%s} <= {%s};\n"  % (_rc_fields_concatenated, _fields_concatenated)
      _rc_update += 6*' ' + "end\n\n"


      all_rtl_rc_update += _rc_update

    # Append the register writes and reads
    _reg_address = "%s_%s_ADDR" % (BLOCK_ACRONYM, reg_name.upper())

    # Generating all the write fields
    if len(_reg_writes):

      _wr_row = 10*" " + _reg_address + ": begin\n"

      for wr in _reg_writes:
        _wr_row += wr + ";\n"

      _wr_row += 10*" " + "end\n\n"
      _reg_writes = []
      all_rtl_writes += _wr_row


    # Generating all the read fields
    if len(_reg_reads):
      _rd_row = 6*" " + _reg_address + ": begin\n"
      for rd in _reg_reads:
        _rd_row += rd + ";\n"
      _rd_row += 6*" " + "end\n\n"
      _reg_reads = []
      all_rtl_reads  += _rd_row

  # ------------------------------------------------------------------------
  # End of register iteration
  # Now we generate the RTL code
  # ------------------------------------------------------------------------

  # ------------------------------------------------------------------------
  # Package imports
  # ------------------------------------------------------------------------

  IMPORT = "import " + BLOCK_NAME + "_address_pkg::*;"

  # ------------------------------------------------------------------------
  # rtl_parameters
  # ------------------------------------------------------------------------

  PARAMETERS = ""
  rtl_parameters = sort_uniq(rtl_parameters)

  for p in rtl_parameters:
    PARAMETERS += 4*' ' + "parameter int %s = -1,\n" % p

  PARAMETERS = PARAMETERS[:-2]

  # ------------------------------------------------------------------------
  # rtl_ports
  # Generating the port declaration
  # Saving the result in the variable 'AXI_PORTS'
  # ------------------------------------------------------------------------

  # Find the longest declaration for indenting nice
  longest = 0
  for port in rtl_ports:
    (_, _field_size, _) = port
    if (len(_field_size) > longest):
      longest = len(_field_size)

  # Generate the module ports
  AXI_PORTS = ""
  for port in rtl_ports:
    (IO, _field_size, _field_name) = port
    AXI_PORTS += IO + _field_size.rjust(longest, " ") + " " + _field_name + ",\n"

  # Remove the last comma and newline
  AXI_PORTS = AXI_PORTS[:-2]

  # ------------------------------------------------------------------------
  # reg_rc_declarations and reg_rom_declarations
  # ------------------------------------------------------------------------

  # Find the longest declaration for indenting nice
  longest = 0
  for reg in reg_rc_declarations:
    (_port_width, _field_name) = reg
    if (len(_port_width) > longest):
      longest = len(_port_width)

  for reg in reg_rom_declarations:
    (_port_width, _field_name) = reg
    if (len(_port_width) > longest):
      longest = len(_port_width)

  LOGIC_DECLARATIONS = "\n"

  for reg in reg_rc_declarations:
    (_port_width, _field_name) = reg
    LOGIC_DECLARATIONS += "  logic " + _port_width.rjust(longest, " ") + " rc_" + _field_name + ";\n"

  for reg in reg_rom_declarations:
    (_port_width, _field_name) = reg
    LOGIC_DECLARATIONS += "  logic " + _port_width.rjust(longest, " ") + " " + _field_name + ";\n"

  # ------------------------------------------------------------------------
  # rtl_resets
  # ------------------------------------------------------------------------

  # Find the longest declaration for indenting nice
  longest = 0
  for port in rtl_resets:
    (_field_name, _) = port
    if (len(_field_name) > longest):
      longest = len(_field_name)

  # Generate the resets
  AXI_RESET = ""
  for port in rtl_resets:
    (_field_name, _field_reset_value) = port
    AXI_RESET += 6*" " + _field_name.ljust(longest, " ") + " <= " + str(_field_reset_value) + ";\n"

  # ------------------------------------------------------------------------
  # rtl_cmd_registers
  # ------------------------------------------------------------------------

  # Find the longest declaration for indenting nice
  longest = 0
  for cmd in rtl_cmd_registers:
    if (len(cmd) > longest):
      longest = len(cmd)

  CMD_DEFAULT = "\n"
  for cmd in rtl_cmd_registers:
    CMD_DEFAULT += 6*" " + cmd.ljust(longest, " ") + " <= '0;\n"



  # ------------------------------------------------------------------------
  # Replacing fields in the template
  # ------------------------------------------------------------------------

  output = header + axi_template
  output = output.replace("IMPORT",             IMPORT)
  output = output.replace("PARAMETERS",         PARAMETERS)
  output = output.replace("CLASS_NAME",         (BLOCK_NAME + "_axi_slave"))
  output = output.replace("PORTS",              AXI_PORTS)
  output = output.replace("LOGIC_DECLARATIONS", LOGIC_DECLARATIONS)
  output = output.replace("CMD_REGISTERS",      CMD_DEFAULT)
  output = output.replace("RC_ASSIGNMENTS",     all_rtl_rc_update)
  output = output.replace("RESETS",             AXI_RESET)
  output = output.replace("AXI_WRITES",         all_rtl_writes)
  output = output.replace("AXI_READS",          all_rtl_reads)

  # Write the AXI slave to file
  output_path = '/'.join(yaml_file_path.split('/')[:-2]) + "/rtl/"
  output_file = output_path + BLOCK_NAME + "_axi_slave.sv"
  with open(output_file, 'w') as file:
    file.write(output)

  print("INFO [pyrg] Generated %s" % output_file)
