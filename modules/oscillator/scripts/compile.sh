#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=oscillator_top
uvm_top="osc_tb_top"

# ------------------------------------------------------------------------------
# Source submodules
# ------------------------------------------------------------------------------

git_sub_root="$(git rev-parse --show-toplevel)"

git_root="$(git rev-parse --show-toplevel)/submodules/VIP"
source $git_sub_root/submodules/VIP/bool/files.lst
source $git_sub_root/submodules/VIP/vip_axi4_agent/files.lst
source $git_sub_root/submodules/VIP/vip_clk_rst_agent/files.lst
source $git_sub_root/submodules/VIP/report_server/files.lst

git_root="$(git rev-parse --show-toplevel)/submodules/PYRG"
source $git_sub_root/submodules/PYRG/rtl/files.lst

# ------------------------------------------------------------------------------
# Source modules
# ------------------------------------------------------------------------------

# Restoring the git root
git_root="$(git rev-parse --show-toplevel)"

source $git_root/modules/math/long_division/rtl/files.lst
source $git_root/modules/math/cordic/rtl/files.lst
source $git_root/modules/math/multiplication/rtl/files.lst
source $git_root/modules/clock_enablers/clock_enable/rtl/files.lst
source $git_root/modules/clock_enablers/clock_enable_scaler/rtl/files.lst
source $git_root/modules/clock_enablers/delay_enable/rtl/files.lst
source $git_root/modules/clock_enablers/frequency_enable/rtl/files.lst
source $git_root/modules/mixer/rtl/files.lst

# Source the module's file lists
source ./rtl/files.lst
source ./tb/files.lst

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

