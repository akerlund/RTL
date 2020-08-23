#-------------------------------------------------------------------------------
# Select testcase
#-------------------------------------------------------------------------------
#set test_case "tc_positive_divisions";
#set test_case "tc_negative_divisions";
set test_case "tc_random_divisions";
#set test_case "tc_overflow_divisions";

set  script_dir [pwd]
cd   rundir
exec xsim top -testplusarg UVM_TESTNAME=$test_case -testplusarg UVM_VERBOSITY=UVM_LOW -gui
cd   $script_dir
