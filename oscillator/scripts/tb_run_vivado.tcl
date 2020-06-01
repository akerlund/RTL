#-------------------------------------------------------------------------------
# Specify all the files of the test bench
#-------------------------------------------------------------------------------

set top_module_name "osc_tb_top";
set git_root        [exec git rev-parse --show-toplevel];
set module_path     $git_root/oscillator
set script_dir      [pwd]

file mkdir "rundir"
cd   rundir

set rtl_directories [list \
  "$git_root/clock_enable/rtl" \
  "$git_root/math/division/long_division/rtl" \
  "$module_path/rtl"];

set uvm_directories [list \
  "$git_root/vip/vip_apb3_agent/" \
  "$module_path/tb/" \
  "$module_path/tc/"];

set package_files [list \
  "$git_root/vip/vip_apb3_agent/vip_apb3_types_pkg.sv" \
  "$git_root/vip/vip_fixed_point/vip_fixed_point_pkg.sv" \
  "$module_path/rtl/osc_apb_slave_addr_pkg.sv" \
  "$module_path/rtl/oscillator_types_pkg.sv"];

set header_files [list \
  "$module_path/tb/tb.svh" \
  "$git_root/vip/vip_apb3_agent/vip_apb3.svh"];

set tb_files [list \
  "$module_path/tb/osc_tb_pkg.sv" \
  "$module_path/tc/osc_tc_pkg.sv" \
  "$module_path/tb/osc_tb_top.sv"];

#-------------------------------------------------------------------------------
# Generate a file with a list of all files to be compiled
#-------------------------------------------------------------------------------

set outfile [open "compile_list.txt" w];
foreach dir $rtl_directories { puts $outfile "-i $dir" };
foreach dir $uvm_directories { puts $outfile "-i $dir" };
foreach f   $package_files   { puts $outfile "$f"      };
foreach f   $header_files    { puts $outfile "$f"      };
foreach f   $tb_files        { puts $outfile "$f"      };
close $outfile;

#-------------------------------------------------------------------------------
# Execute Vivado commands
#-------------------------------------------------------------------------------

puts "INFO \[xvlog\] Parsing the compile list"
exec xvlog -sv -f compile_list.txt -L uvm

puts "INFO \[xelab\] Elaborating the design"
exec xelab osc_tb_top -debug all -s top -timescale 1ns/1ps

cd $script_dir
