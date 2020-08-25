#!/bin/bash

# ------------------------------------------------------------------------------
# Compile script which is called (sourced) from the main Makefile
# (makefile_rtl.mk). This script gathers the file paths and passes them to
# the selected tool for execution, i.e., the 'run_tools' script.
# ------------------------------------------------------------------------------

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=oscillator_top
uvm_top="osc_tb_top"

# Specify other file lists
source $git_root/modules/math/cordic/rtl/rtl_files.lst
source $git_root/modules/clock_enablers/clock_enable/rtl/rtl_files.lst
source $git_root/modules/clock_enablers/clock_enable_scaler/rtl/rtl_files.lst
source $git_root/modules/clock_enablers/delay_enable/rtl/rtl_files.lst
source $git_root/modules/clock_enablers/frequency_enable/rtl/rtl_files.lst

# Source the module's file lists
source ./rtl/rtl_files.lst
#source ./tb/uvm_files.lst

# Verilator parameter override
parameters+=("SYS_CLK_FREQUENCY_P=250000000")
parameters+=("PRIME_FREQUENCY_P=1000000")
parameters+=("WAVE_WIDTH_P=24")
parameters+=("DUTY_CYCLE_DIVIDER_P=1000")
parameters+=("N_BITS_P=32")
parameters+=("Q_BITS_P=11")
parameters+=("AXI_DATA_WIDTH_P=32")
parameters+=("AXI_ID_WIDTH_P=32")
parameters+=("AXI_ID_P=32'hDEADBEA7")
parameters+=("APB_BASE_ADDR_P=0")
parameters+=("APB_ADDR_WIDTH_P=8")
parameters+=("APB_DATA_WIDTH_P=32")

# Source the tool script which executes the selected tool
source $git_root/scripts/make_env/run_tools.sh
