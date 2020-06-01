#-------------------------------------------------------------------------------
# Select testcase
#-------------------------------------------------------------------------------
set test_case "tc_osc_frequency_test";
set test_case "tc_osc_duty_cycle_sweep";

set  script_dir [pwd]
cd   rundir
exec xsim top -testplusarg UVM_TESTNAME=$test_case -testplusarg UVM_VERBOSITY=UVM_LOW -gui
cd   $script_dir
