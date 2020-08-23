#!/bin/bash

# ------------------------------------------------------------------------------
# Compile script which is called (sourced) from the main Makefile
# (makefile_rtl.mk). This script gathers the file paths and passes them to
# the selected tool for execution, i.e., the 'run_tools' script.
# ------------------------------------------------------------------------------

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=frequency_enable.sv
uvm_top=""

# Specify other file lists
#source $git_root/other_module/rtl/rtl_files.lst

# Source the module's file lists
source ./rtl/rtl_files.lst
#source ./tb/uvm_files.lst

# Verilator parameter override
v_params+="-pvalue+SYS_CLK_FREQUENCY_P=200000000 "
v_params+="-pvalue+AXI_DATA_WIDTH_P=32 "
v_params+="-pvalue+AXI_ID_WIDTH_P=4 "
v_params+="-pvalue+Q_BITS_P=17 "
v_params+="-pvalue+AXI4S_ID_P=1 "

# Source the tool script which executes the selected tool
source $git_root/scripts/make_env/run_tools.sh