#-------------------------------------------------------------------------------
# Select testcase
#-------------------------------------------------------------------------------
set test_case       "tc_arb_simple_test";

cd   rundir
exec xsim top -maxdeltaid 100000 -testplusarg UVM_TESTNAME=$test_case -testplusarg UVM_VERBOSITY=UVM_LOW -gui
