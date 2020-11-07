#-------------------------------------------------------------------------------
# Select testcase
#-------------------------------------------------------------------------------
set test_case "tc_syfi_basic";
set test_case "tc_syfi_back_pressure";
set test_case "tc_syfi_fill_up_read_out";

set  script_dir [pwd]
cd   rundir
exec xsim top -testplusarg UVM_TESTNAME=$test_case -testplusarg UVM_VERBOSITY=UVM_LOW -gui
cd   $script_dir
