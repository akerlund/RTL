#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=oscillator_top
uvm_top="osc_tb_top"

# Specify other file lists
source $git_root/vip/vip_fixed_point/uvm_files.lst
source $git_root/vip/vip_apb3_agent/uvm_files.lst
source $git_root/modules/math/division/long_division/rtl/rtl_files.lst
source $git_root/modules/math/cordic/rtl/rtl_files.lst
source $git_root/modules/clock_enablers/clock_enable/rtl/rtl_files.lst
source $git_root/modules/clock_enablers/clock_enable_scaler/rtl/rtl_files.lst
source $git_root/modules/clock_enablers/delay_enable/rtl/rtl_files.lst
source $git_root/modules/clock_enablers/frequency_enable/rtl/rtl_files.lst

# Source the module's file lists
source ./rtl/rtl_files.lst
source ./tb/uvm_files.lst

# Parameter override
parameters+=("SYS_CLK_FREQUENCY_P=125000000 ")
parameters+=("PRIME_FREQUENCY_P=1000000 ")
parameters+=("WAVE_WIDTH_P=24 ")
parameters+=("DUTY_CYCLE_DIVIDER_P=1000 ")
parameters+=("N_BITS_P=32 ")
parameters+=("Q_BITS_P=11 ")
parameters+=("AXI_DATA_WIDTH_P=32 ")
parameters+=("AXI_ID_WIDTH_P=32 ")
parameters+=("AXI_ID_P=32'hDEADBEA7 ")
parameters+=("APB_BASE_ADDR_P=0 ")
parameters+=("APB_ADDR_WIDTH_P=8 ")
parameters+=("APB_DATA_WIDTH_P=32 ")

