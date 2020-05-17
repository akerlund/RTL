#-------------------------------------------------------------------------------
# Select testcase
#-------------------------------------------------------------------------------
set test_case "tc_hsl_simple_test";

set  script_dir [pwd]
cd   rundir
exec xsim top -maxdeltaid 100000 -testplusarg UVM_TESTNAME=$test_case -testplusarg UVM_VERBOSITY=UVM_LOW -gui
cd   $script_dir
