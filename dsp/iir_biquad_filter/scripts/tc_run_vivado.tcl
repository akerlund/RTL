#-------------------------------------------------------------------------------
# Select testcase
#-------------------------------------------------------------------------------
set test_case "tc_iir_basic_configuration";
#set test_case "tc_iir_coefficient_check";

set  script_dir [pwd]
cd   rundir
exec xsim top -testplusarg UVM_TESTNAME=$test_case -testplusarg UVM_VERBOSITY=UVM_LOW -gui
cd   $script_dir
