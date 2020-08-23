#!/bin/bash

# ------------------------------------------------------------------------------
# Compile script which is called (sourced) from the main Makefile
# (makefile_rtl.mk). This script gathers the file paths and passes them to
# the selected tool for execution, i.e., the 'run_tools' script.
# ------------------------------------------------------------------------------

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=button_core.sv
uvm_top="osc_tb_top"

# Specify other file lists
source $git_root/modules/math/cordic/rtl/rtl_files.lst

# Source the module's file lists
source ./rtl/rtl_files.lst
#source ./tb/uvm_files.lst

# Verilator parameter override
v_params+="-pvalue+SYS_CLK_FREQUENCY_P=250000000 "
v_params+="-pvalue+PRIME_FREQUENCY_P=1000000 "
v_params+="-pvalue+WAVE_WIDTH_P=24 "
v_params+="-pvalue+DUTY_CYCLE_DIVIDER_P=1000 "
v_params+="-pvalue+N_BITS_P=32 "
v_params+="-pvalue+Q_BITS_P=11 "
v_params+="-pvalue+AXI_DATA_WIDTH_P=32 "
v_params+="-pvalue+AXI_ID_WIDTH_P=32 "
v_params+="-pvalue+AXI_ID_P=32'hDEADBEA7 "
v_params+="-pvalue+APB_BASE_ADDR_P=0 "
v_params+="-pvalue+APB_ADDR_WIDTH_P=8 "
v_params+="-pvalue+APB_DATA_WIDTH_P=32 "

# Source the tool script which executes the selected tool
source $git_root/scripts/make_env/run_tools.sh
