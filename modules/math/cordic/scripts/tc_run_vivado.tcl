#-------------------------------------------------------------------------------
# Select testcase
#-------------------------------------------------------------------------------
#set test_case "tc_cor_360_angles";
#set test_case "tc_positive_radian_spin";
set test_case "tc_negative_radian_spin";

set  script_dir [pwd]
cd   rundir
exec xsim top -testplusarg UVM_TESTNAME=$test_case -testplusarg UVM_VERBOSITY=UVM_LOW -gui
cd   $script_dir
