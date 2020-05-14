set test_case       "tc_arb_simple_test"

set git_root        [exec git rev-parse --show-toplevel]
set module_path     $git_root/axi4s/axi4s_arbiter/axi4s_m2s_2m_arbiter
set top_module_name "arb_tb_top"

set rtl_directories [list \
  "$module_path/rtl/"]

set uvm_directories [list \
  "$git_root/vip/vip_axi4s_agent/" \
  "$module_path/tb/" \
  "$module_path/tc/"]

set package_files [list \
  "$git_root/vip/vip_axi4s_agent/vip_axi4s_types_pkg.sv"]

set header_files [list \
  "$git_root/vip/vip_axi4s_agent/vip_axi4s.svh"]


set tb_files [list \
  "$module_path/tb/tb.svh" \
  "$module_path/tb/arb_tb_pkg.sv" \
  "$module_path/tc/arb_tc_pkg.sv" \
  "$module_path/tb/arb_tb_top.sv"]


puts [join $uvm_directories]

#-------------------------------------------------------------------------------
# Generate a file with a list of all files to be compiled
#-------------------------------------------------------------------------------

set outfile [open "report.out" w]

foreach dir $rtl_directories {
  puts $outfile "-i $dir"
}

foreach dir $uvm_directories {
  puts $outfile "-i $dir"
}

foreach f $package_files {
  puts $outfile "$f"
}

foreach f $header_files {
  puts $outfile "$f"
}

foreach f $tb_files {
  puts $outfile "$f"
}

close $outfile

exec xvlog -sv -f report.out -L uvm
exec xelab $top_module_name -relax -s top -timescale 1ns/1ps
exec xsim top -testplusarg UVM_TESTNAME=$test_case -testplusarg UVM_VERBOSITY=UVM_LOW -runall