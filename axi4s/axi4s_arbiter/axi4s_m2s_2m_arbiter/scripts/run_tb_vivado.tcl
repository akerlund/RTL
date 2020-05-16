#-------------------------------------------------------------------------------
# Select testcase
#-------------------------------------------------------------------------------
set test_case       "tc_arb_simple_test";

#-------------------------------------------------------------------------------
# Specify all the files of the test bench
#-------------------------------------------------------------------------------

set top_module_name "arb_tb_top";
set git_root        [exec git rev-parse --show-toplevel];
set module_path     $git_root/axi4s/axi4s_arbiter/axi4s_m2s_2m_arbiter;

file mkdir "rundir"
cd   rundir

set rtl_directories [list \
  "$module_path/rtl/" \
  "$git_root/axi4s/axi4s_retime/rtl"];

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
  "$module_path/tb/arb_tb_pkg.sv" \
  "$module_path/tc/arb_tc_pkg.sv" \
  "$module_path/tb/arb_tb_top.sv"];

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

exec xvlog -sv -f compile_list.txt -L uvm
exec xelab -v 2 arb_tb_top -debug typical -relax -s top -timescale 1ns/1ps
exec xsim top -maxdeltaid 100000 -testplusarg UVM_TESTNAME=$test_case -testplusarg UVM_VERBOSITY=UVM_LOW -runall
