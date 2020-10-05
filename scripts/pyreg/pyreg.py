ports     = "<PORTS>"
registers = "<REGISTERS>"
resets    = "<RESETS>"
writes    = "<WRITES>"
reads     = "<READS>"


def add_ports(register_list):

  ports     = ""
  direction = ""


  for reg in register_list:

    if reg.type == "SR":
      direction = "input  wire "
    else:
      direction = "output logic"

    ports += direction + "     [AXI_DATA_WIDTH_C-1 : 0] " +\
             reg.type.lower() + "_" + reg.name + ",\n"

  return ports



def add_registers(register_list):

  register_widths = []
  register_names  = []

  for reg in register_list:

    if reg.type != "SR":

      register_widths.append("[" + reg.size + "-1 : 0] ")
      register_names.append(reg.type.lower() + "_" + reg.name)


  longest_width = 0

  # Find the longest logic width declaration
  for reg in register_widths:
    if reg.size() > longest_width:
      longest_width = reg.size()

  # Align all declarations to the longest one
  for reg in register_widths:
    reg = reg.ljust(longest_width)

  reg_declarations = ""

  for i in range(len(register_widths)):
    reg_declarations += "  logic " + register_widths[i] + register_names[i] + ";\n"


  return reg_declarations



def add_resets(register_list):

  reset_names  = []
  reset_values = []

  for reg in register_list:

    if reg.type != "SR":

      reset_names.append(reg.type.lower() + "_" + reg.name)
      reset_values.append(reg.reset_value)


  longest_name = 0

  # Find the longest register name
  for reg in reset_names:
    if reg.size() > longest_name:
      longest_name = reg.size()

  # Align all declarations to the longest one
  for reg in reset_names:
    reg = reg.ljust(longest_name)



def add_writes(register_list):

  write_template = """
          ADDRESS: begin
            for (byte_index = 0; byte_index <= (AXI_DATA_WIDTH_C/8)-1; byte_index++) begin
              if (wstrb[byte_index] == 1) begin
                REGISTER_NAME[(byte_index*8) +: 8] <= wdata[(byte_index*8) +: 8];
              end
            end
          end
  """

  writes = ""
  reads  = ""

  reg_counter   = 0
  #nr_of_registers = len(register_list)
  register_name = ""

  for reg in register_list:

    if reg.type != "SR":
      register_name = reg.type.lower() + "_" + reg.name
      writes += write_template.replace("ADDRESS", reg_counter).replace("REGISTER_NAME", register_name)
      reg_counter += 1

    reads += str(reg_counter) + " : rdata_d0 <= " + register_name
