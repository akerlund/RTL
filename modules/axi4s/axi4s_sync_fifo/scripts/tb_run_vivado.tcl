#-------------------------------------------------------------------------------
# Specify all the files of the test bench
#-------------------------------------------------------------------------------

set top_module_name "syfi_tb_top";
set git_root        [exec git rev-parse --show-toplevel];
set module_path     $git_root/modules/axi4s/axi4s_sync_fifo;
set script_dir      [pwd]

file mkdir "rundir"
cd   rundir

set rtl_directories [list \
  "$git_root/modules/memory/reg/rtl" \
  "$git_root/modules/fifo/synchronous_fifo/rtl" \
  "$module_path/rtl"];

set uvm_directories [list \
  "$git_root/vip/vip_axi4s_agent/" \
  "$module_path/tb/" \
  "$module_path/tc/"];

set package_files [list \
  "$git_root/vip/vip_axi4s_agent/vip_axi4s_types_pkg.sv"];

set header_files [list \
  "$module_path/tb/tb.svh" \
  "$git_root/vip/vip_axi4s_agent/vip_axi4s.svh"];


set tb_files [list \
  "$module_path/tb/syfi_tb_pkg.sv" \
  "$module_path/tc/syfi_tc_pkg.sv" \
  "$module_path/tb/syfi_tb_top.sv"];

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
exec xelab syfi_tb_top -debug all -relax -s top -timescale 1ns/1ps

cd $script_dir
