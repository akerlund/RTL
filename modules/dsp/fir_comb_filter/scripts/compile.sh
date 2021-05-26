#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=fir_comb_top
uvm_top="fir_tb_top"

# ------------------------------------------------------------------------------
# Source submodules
# ------------------------------------------------------------------------------

git_sub_root="$(git rev-parse --show-toplevel)"

git_root="$(git rev-parse --show-toplevel)/submodules/VIP"
source $git_sub_root/submodules/VIP/bool/files.lst
source $git_sub_root/submodules/VIP/vip_axi4_agent/files.lst
source $git_sub_root/submodules/VIP/vip_axi4s_agent/files.lst
source $git_sub_root/submodules/VIP/vip_clk_rst_agent/files.lst
source $git_sub_root/submodules/VIP/report_server/files.lst
source $git_sub_root/submodules/VIP/vip_fixed_point/files.lst

git_root="$(git rev-parse --show-toplevel)/submodules/PYRG"
source $git_sub_root/submodules/PYRG/rtl/files.lst

# ------------------------------------------------------------------------------
# Source modules
# ------------------------------------------------------------------------------

# Restoring the git root
git_root="$(git rev-parse --show-toplevel)"

source $git_root/modules/interfaces/axi4/rtl/files.lst
source $git_root/modules/memory/reg/rtl/files.lst
source $git_root/modules/fifo/rtl/files.lst

# Source the module's file lists
source ./rtl/files.lst
source ./tb/files.lst

# Parameter override
parameters+=("N_BITS_P=32 ")
parameters+=("Q_BITS_P=17 ")
parameters+=("MEM_BASE_ADDR_P=0 ")
parameters+=("MEM_HIGH_ADDR_P=44100 ")
parameters+=("MEM_ADDR_WIDTH_P=32 ")
parameters+=("MEM_DATA_WIDTH_P=128 ")
parameters+=("AXI4_ID_P=0 ")
