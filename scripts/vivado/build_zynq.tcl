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
## along with this program.  If not, see <https://www.gnu.org/licenses/>.
##
## Description:
##
################################################################################

# ------------------------------------------------------------------------------
# Description:
#   The main procedure which creates a Xilinx Hardware Design from a
#   ZynQ RTL project. The resulting .xsa (Xilinx Support Archive) is used in a
#   Xilinx Vitis software project and contains the implemented bit file.
# ------------------------------------------------------------------------------
proc build_zynq { _project_name _rundir        _fpga_part \
                  _board_part   _file_list     _xip_properties _ip_interfaces \
                  _constraints  _fclk_freq_mhz _bd_design_name } {

  puts "INFO \[project\] Creating a Vivado project"

  create_project    $_project_name $_rundir/$_project_name -part $_fpga_part -force

  set_property      board_part         $_board_part [current_project]
  set_property      simulator_language "Verilog"    [current_project]

  add_verilog_files $_file_list

  # Constraint files for the XIP which will be generated
  foreach _constraint [dict get $_constraints xip_timing] {
    if [string length $_constraint] {
      puts "INFO \[project\] Adding IP constraint ($_constraint)"
      add_files -fileset constrs_1 -norecurse $_constraint
      set_property used_in_implementation false [get_files $_constraint]
      set_property used_in_simulation     false [get_files $_constraint]
    }
  }

  foreach _constraint [dict get $_constraints xip_physical] {
    if [string length $_constraint] {
      puts "INFO \[project\] Adding IP constraint ($_constraint)"
      add_files -fileset constrs_1 -norecurse $_constraint
      set_property used_in_implementation false [get_files $_constraint]
      set_property used_in_simulation     false [get_files $_constraint]
    }
  }

  create_ip $_rundir $_xip_properties $_ip_interfaces

  create_block_design $_xip_properties $_ip_interfaces $_fclk_freq_mhz $_bd_design_name

  create_wrapper $_rundir $_project_name $_bd_design_name

  generate_output_products $_rundir $_project_name $_bd_design_name

  # Constraint files for the XIP which will be generated
  foreach _constraint [dict get $_constraints top_timing] {
    if [string length $_constraint] {
      puts "INFO \[project\] Adding TOP constraint ($_constraint)"
      add_files -fileset constrs_1 -norecurse $_constraint
      set_property used_in_synthesis  false [get_files $_constraint]
      set_property used_in_simulation false [get_files $_constraint]
    }
  }

  foreach _constraint [dict get $_constraints top_physical] {
    if [string length $_constraint] {
      puts "INFO \[project\] Adding TOP constraint ($_constraint)"
      add_files -fileset constrs_1 -norecurse $_constraint
      set_property used_in_synthesis  false [get_files $_constraint]
      set_property used_in_simulation false [get_files $_constraint]
    }
  }

  launch_runs impl_1 -to_step write_bitstream -jobs 12 -verbose
  wait_on_run impl_1 -quiet

  export_hardware $_rundir $_project_name $_bd_design_name

  close_project
}


proc synth_and_all {rtl_top} {

  puts "\n--------------------------------------------------------------------------------"
  puts "INFO \[flow\] synth_design"
  puts "--------------------------------------------------------------------------------\n"

  synth_design -top $rtl_top -part 7z020clg484-1

  write_checkpoint      -force $rpt_dir/post_synth.dcp
  report_timing_summary -file  $rpt_dir/post_synth_timing_summary.rpt
  report_utilization    -file  $rpt_dir/post_synth_util.rpt

  puts "\n--------------------------------------------------------------------------------"
  puts "INFO \[flow\] opt_design"
  puts "--------------------------------------------------------------------------------\n"

  opt_design

  puts "\n--------------------------------------------------------------------------------"
  puts "INFO \[flow\] place_design"
  puts "--------------------------------------------------------------------------------\n"

  place_design

  puts "\n--------------------------------------------------------------------------------"
  puts "INFO \[flow\] report_clock_utilization"
  puts "--------------------------------------------------------------------------------\n"

  report_clock_utilization -file $rpt_dir/clock_util.rpt
  if {[get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]] < 0} {
  puts "Found setup timing violations: running physical optimization"
    phys_opt_design
  }

  write_checkpoint      -force $rpt_dir/post_place.dcp
  report_utilization    -file  $rpt_dir/post_place_util.rpt
  report_timing_summary -file  $rpt_dir/post_place_timing_summary.rpt

  puts "\n--------------------------------------------------------------------------------"
  puts "INFO \[flow\] route_design"
  puts "--------------------------------------------------------------------------------\n"

  route_design
  write_checkpoint      -force $rpt_dir/post_route.dcp

  report_route_status   -file $rpt_dir/post_route_status.rpt
  report_timing_summary -file $rpt_dir/post_route_timing_summary.rpt
  report_power          -file $rpt_dir/post_route_power.rpt
  report_drc            -file $rpt_dir/post_imp_drc.rpt

  puts "\n--------------------------------------------------------------------------------"
  puts "INFO \[flow\] write_bitstream"
  puts "--------------------------------------------------------------------------------\n"

  write_verilog   -force $rpt_dir/cpu_impl_netlist.v -mode timesim -sdf_anno true
  write_bitstream -force $rpt_dir/cpu.bit
}

# ------------------------------------------------------------------------------
# Description:
#   Adds verilog files to a project which are read from a file list.
#   A regular expression is used to sort out commented (#) and empty lines.
# ------------------------------------------------------------------------------
proc add_verilog_files {_file_list} {


  puts "INFO \[add_verilog_files\] Reading file list ($_file_list)"
  # Reading the System Verilog files
  set _file_ref  [open $_file_list r]
  set _file_data [read $_file_ref]
  close $_file_ref

  read_verilog $_file_data

  puts "INFO \[add_verilog_files\] Completed"
}


# ------------------------------------------------------------------------------
# Description:
#
# Packages a project into an Xilinx IP component.
#
# ------------------------------------------------------------------------------
#
# Documentation:
#
# - Arguments of "package_project";
#     Name            Description
#     ------------------------------------------
#     [-root_dir]     User specified root directory for component.xml
#     [-vendor]       User specified vendor of the IP VLNV
#     [-library]      User specified library of the IP VLNV
#     -taxonomy       User specified taxonomy for the IP
#     [-import_files] If true, import remote IP files into the IP structure.
#     [-set_current]  Set the core as the current core.
#     [-force]        Override existing packaged component.xml.
#
# ------------------------------------------------------------------------------
proc create_ip {_rundir _xip_properties _ip_interfaces} {

  puts "INFO \[create_ip\] Creating IP"

  ipx::package_project    -root_dir "$_rundir/packed_ip" -taxonomy "/UserIP" -import_files -set_current false -force
  ipx::unload_core        $_rundir/packed_ip/component.xml
  ipx::edit_ip_in_project -upgrade true -name "tmp_edit_project" -directory "$_rundir/packed_ip" "$_rundir/packed_ip/component.xml"

  set_ip_properties    $_xip_properties
  set_ip_interfaces    $_ip_interfaces
  set_ip_clk_frequency [dict get $_ip_interfaces clocks]

  set_property previous_version_for_upgrade user.org:user:project_top:1.0 [ipx::current_core]
  set_property core_revision 1 [ipx::current_core]

  ipx::create_xgui_files [ipx::current_core]
  ipx::update_checksums  [ipx::current_core]
  ipx::save_core         [ipx::current_core]

  ipx::move_temp_component_back -component [ipx::current_core]
  close_project -delete

  set_property ip_repo_paths $_rundir/packed_ip [current_project]
  update_ip_catalog
}



# ------------------------------------------------------------------------------
# Description:
#   Sets properties of new XIP's
# ------------------------------------------------------------------------------
#
# Documentation:
#
# - To see properties of an IP; report_property [ipx::current_core]
# ------------------------------------------------------------------------------
proc set_ip_properties {_xip_properties} {

  puts "INFO \[set_ip_properties\] Setting the IP's properties"

  set_property CORE_REVISION 2 [ipx::current_core]

  # Vendor
  if {[dict exists $_xip_properties ip_vendor]} {
    set_property VENDOR              [dict get $_xip_properties ip_vendor] [ipx::current_core]
    set_property VENDOR_DISPLAY_NAME [dict get $_xip_properties ip_vendor] [ipx::current_core]
  } else {
    puts "INFO \[set_ip_properties\] Property VENDOR not provided"
  }

  # Library
  if {[dict exists $_xip_properties ip_library]} {
    set_property LIBRARY      [dict get $_xip_properties ip_library]       [ipx::current_core]
  } else {
    puts "INFO \[set_ip_properties\] Property LIBRARY not provided"
  }

  # Name
  if {[dict exists $_xip_properties ip_name]} {
    set_property NAME         [dict get $_xip_properties ip_name]          [ipx::current_core]
  } else {
    puts "INFO \[set_ip_properties\] Property NAME not provided"
  }

  # Version
  if {[dict exists $_xip_properties ip_version]} {
    set_property VERSION      [dict get $_xip_properties ip_version]       [ipx::current_core]
  } else {
    puts "INFO \[set_ip_properties\] Property VERSION not provided"
  }

  # Display name
  if {[dict exists $_xip_properties ip_display_name]} {
    set_property DISPLAY_NAME [dict get $_xip_properties ip_display_name]  [ipx::current_core]
  } else {
    puts "INFO \[set_ip_properties\] Property DISPLAY_NAME not provided"
  }

  # Description
  if {[dict exists $_xip_properties ip_description]} {
    set_property DESCRIPTION  [dict get $_xip_properties ip_description]   [ipx::current_core]
  } else {
    puts "INFO \[set_ip_properties\] Property DESCRIPTION not provided"
  }
}


# ------------------------------------------------------------------------------
# Description:
#   Sets signal types of XIP ports
# ------------------------------------------------------------------------------
proc set_ip_interfaces {_ip_interfaces} {

  puts "INFO \[set_ip_interfaces\] Setting up the IP's clock interface(s)"
  foreach _clk [dict get $_ip_interfaces clocks] {
    ipx::infer_bus_interface [dict get $_clk name] xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
  }

  puts "INFO \[set_ip_interfaces\] Setting up the IP's reset interface(s)"
  foreach _rst [dict get $_ip_interfaces resets] {
    ipx::infer_bus_interface $_rst xilinx.com:signal:reset_rtl:1.0                 [ipx::current_core]
  }

  puts "INFO \[set_ip_interfaces\] Setting up the IP's interrupt interface(s)"
  foreach _irq [dict get $_ip_interfaces irq] {
    ipx::infer_bus_interface $_irq xilinx.com:signal:interrupt_rtl:1.0             [ipx::current_core]
  }

  puts "INFO \[set_ip_interfaces\] Setting up the IP's data I/O interface(s)"
  foreach _io [dict get $_ip_interfaces data_io] {
    ipx::infer_bus_interface [dict get $_io name] xilinx.com:signal:data_rtl:1.0   [ipx::current_core]
  }
}


# ------------------------------------------------------------------------------
# Description:
#   Sets the clock frequency of all clocks in the argument list
# ------------------------------------------------------------------------------
proc set_ip_clk_frequency {_ip_clocks} {

  puts "INFO \[set_ip_clk_frequency\] Setting up the IP's ([llength $_ip_clocks]) clock frequency(s)"

  foreach _clk $_ip_clocks {
    ipx::add_bus_parameter FREQ_HZ [ipx::get_bus_interfaces [dict get $_clk name] -of_objects [ipx::current_core]]
    set_property VALUE [dict get $_clk freq_hz] [ipx::get_bus_parameters -of_objects [ipx::get_bus_interfaces -of_objects [ipx::current_core] [dict get $_clk name] ] FREQ_HZ]
  }
}


# ------------------------------------------------------------------------------
# Description:
#   Creates a new block design and creates top I/O's and connects them
#   to the top module
# ------------------------------------------------------------------------------
proc create_block_design {_xip_properties _ip_interfaces _fclk_freq_mhz _bd_design_name} {

  puts "INFO \[create_block_design\] Creating block design"

  set _xip_vendor     [dict get $_xip_properties ip_vendor]
  set _xip_ip_library [dict get $_xip_properties ip_library]
  set _xip_ip_name    [dict get $_xip_properties ip_name]
  set _bd_name        bd_${_xip_ip_name}_0


  create_bd_design $_bd_design_name

  puts "INFO \[create_block_design\] Cells"
  set _user_ip             [create_bd_cell -type ip -vlnv $_xip_vendor:$_xip_ip_library:$_xip_ip_name:1.0 $_bd_name]
  set processing_system7_0 [create_bd_cell -type ip -vlnv xilinx.com:ip:processing_system7:5.5 processing_system7_0]
  set xlconcat_0           [create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0]

  puts "INFO \[create_block_design\] Config"

  # Run this automation first because it will reset any previous congirations you have made
  apply_bd_automation -rule xilinx.com:bd_rule:processing_system7 -config {make_external "FIXED_IO, DDR" apply_board_preset "1" Master "Disable" Slave "Disable"} [get_bd_cells processing_system7_0]

  # ----------------------------------------------------------------------------
  # Properites
  # ----------------------------------------------------------------------------

  #set_property -dict [list CONFIG.preset                          {ZC702*}]        [get_bd_cells processing_system7_0]
  set_property -dict [list CONFIG.PCW_USE_S_AXI_HP0            {1}             \
                           CONFIG.PCW_USE_FABRIC_INTERRUPT     {1}             \
                           CONFIG.PCW_IRQ_F2P_INTR             {1}             \
                           CONFIG.PCW_TTC0_PERIPHERAL_ENABLE   {0}             \
                           CONFIG.PCW_FPGA0_PERIPHERAL_FREQMHZ $_fclk_freq_mhz ] [get_bd_cells processing_system7_0]
  #set_property -dict [list CONFIG.PCW_IMPORT_BOARD_PRESET {/opt/Xilinx/Vivado/2020.1/data/boards/board_files/arty-z7-20/A.0/preset.xml}] [get_bd_cells processing_system7_0]

  set_property -dict [list CONFIG.NUM_PORTS                    {2}]             $xlconcat_0

  # ----------------------------------------------------------------------------
  # Creating interface ports and connections
  # ----------------------------------------------------------------------------

  # Connect IP's AXI4 ports
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {Auto} Clk_slave {Auto} Clk_xbar {Auto} Master {/processing_system7_0/M_AXI_GP0} Slave {/$_bd_name/cfg} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins $_bd_name/cfg]
  apply_bd_automation -rule xilinx.com:bd_rule:axi4 -config { Clk_master {/processing_system7_0/FCLK_CLK0 (125 MHz)} Clk_slave {Auto} Clk_xbar {Auto} Master {/bd_project_top_0/mc} Slave {/processing_system7_0/S_AXI_HP0} ddr_seg {Auto} intc_ip {New AXI Interconnect} master_apm {0}}  [get_bd_intf_pins processing_system7_0/S_AXI_HP0]

  # Create ports in the block design and connect them to the top module
  foreach _io [dict get $_ip_interfaces data_io] {
    create_bd_port -dir [dict get $_io dir] -type data [dict get $_io name]
    connect_bd_net [get_bd_pins /$_bd_name/[dict get $_io name]] [get_bd_ports [dict get $_io name]]
  }

  # IRQ
  connect_bd_net [get_bd_pins bd_project_top_0/irq_0] [get_bd_pins xlconcat_0/In0]
  connect_bd_net [get_bd_pins bd_project_top_0/irq_1] [get_bd_pins xlconcat_0/In1]
  connect_bd_net [get_bd_pins xlconcat_0/dout] [get_bd_pins processing_system7_0/IRQ_F2P]

  # Only if no AXI
  #connect_bd_net [get_bd_pins processing_system7_0/M_AXI_GP0_ACLK] [get_bd_pins processing_system7_0/FCLK_CLK0]

  # ----------------------------------------------------------------------------
  # Finish
  # ----------------------------------------------------------------------------

  regenerate_bd_layout
  validate_bd_design
  save_bd_design
}


# ------------------------------------------------------------------------------
# Description:
#   Creates an HDL wrapper of a block design
# ------------------------------------------------------------------------------
proc create_wrapper {_rundir _project_name _bd_design_name} {

  puts "INFO \[create_wrapper\] Create wrapper and synthesize"

  make_wrapper -files    [get_files $_rundir/$_project_name/$_project_name.srcs/sources_1/bd/$_bd_design_name/$_bd_design_name.bd] -top
  add_files    -norecurse $_rundir/$_project_name/$_project_name.srcs/sources_1/bd/$_bd_design_name/hdl/${_bd_design_name}_wrapper.v
  set_property top ${_bd_design_name}_wrapper [current_fileset]
}


# ------------------------------------------------------------------------------
# Description:
#   Generated files produced for an IP customization. They can include HDL,
#   constraints, and simulation targets. During output product generation, the
#   Vivado tools store IP customizations in the XCI file and uses the XCI file
#   to produce the files used during synthesis and simulation.
# ------------------------------------------------------------------------------
proc generate_output_products {_rundir _project_name _bd_design_name} {

  puts "INFO \[generate_output_products\] Generating output products"

  generate_target      all         [get_files $_rundir/$_project_name/$_project_name.srcs/sources_1/bd/$_bd_design_name/$_bd_design_name.bd]
  export_ip_user_files -of_objects [get_files $_rundir/$_project_name/$_project_name.srcs/sources_1/bd/$_bd_design_name/$_bd_design_name.bd] -no_script -sync -force -quiet
}


# ------------------------------------------------------------------------------
# Description:
#   Exports the hardware specification required for Xilinx Vitis
# ------------------------------------------------------------------------------
proc export_hardware {_rundir _project_name _bd_design_name} {

  puts "INFO \[export_hardware\] Exporting hardware as .xsa file"

  set_property pfm_name {} [get_files -all $_rundir/$_project_name/$_project_name.srcs/sources_1/bd/$_bd_design_name/$_bd_design_name.bd]
  write_hw_platform -fixed -include_bit -force -file $_rundir/$_project_name/${_bd_design_name}_wrapper.xsa
}
