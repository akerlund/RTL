#!/usr/bin/env python3

import yaml
import subprocess
import string


def test_pyyaml():

  port_out = '  output logic     [AXI_DATA_WIDTH_C-1 : 0] '
  port_in  = '  input  wire      [AXI_DATA_WIDTH_C-1 : 0] '


  git_root = subprocess.Popen(['git', 'rev-parse', '--show-toplevel'], stdout = subprocess.PIPE).communicate()[0].rstrip().decode('utf-8')

  print('Python YAML version: ', yaml.__version__)


  #with open(git_root + '/submodules/rtl_common_design/scripts/pyreg/register_slave.yml', 'r') as file:
  with open(git_root + '/submodules/rtl_common_design/scripts/pyreg/ip_config_apb_slave.yml', 'r') as file:

    reg_dict = yaml.load(file, Loader=yaml.Loader)
    key_list = list(reg_dict)

    if len(key_list) != 1:
      print('ERROR [format] YAML file contains more than one key, found ', len(key_list))
      return -1

    apb_slave_name = key_list[0]


    print('Creating the ports:')
    port_declarations = []
    cr_resets         = []
    cmd_resets        = []

    for reg in reg_dict[apb_slave_name]:

      if 'type' not in reg:
        print('ERROR [port_type] Missing port type: ', reg['name'])
      elif reg['type'] == 'CR':
        port_declarations.append(port_out + 'cr_'  + reg['name'])
        cr_resets.append(port_out + 'cr_'  + reg['name'])
      elif reg['type'] == 'SR':
        port_declarations.append(port_in  + 'sr_'  + reg['name'])
      elif reg['type'] == 'CMD':
        port_declarations.append(port_in  + 'cmd_' + reg['name'])
        cmd_resets.append(port_in         + 'cmd_' + reg['name'])
      elif reg['type'] == 'IRQ':
        port_declarations.append(port_in  + 'irq_' + reg['name'])
      else:
        print('ERROR [port_type] Undefined port type (%s)', reg['type'])
        #return -1

    print('All created ports:')
    for port in port_declarations:
      print(port)


    print('Top key: ', apb_slave_name, '\n')




if __name__ == '__main__':
  #test_yaml()
  #test_py()
  test_pyyaml()


  replace_list = [\
    '__PORTS__',
    '__RESETS__',
    '__COMMANDS__',
    '__WRITES__',
    '__READS__'
    ]
