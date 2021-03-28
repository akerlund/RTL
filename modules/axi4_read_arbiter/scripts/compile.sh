#!/bin/bash

# Specify the top files
rtl_top=axi4_read_arbiter
uvm_top="ara_tb_top"

# ------------------------------------------------------------------------------
# Source submodules
# ------------------------------------------------------------------------------

git_sub_root="$(git rev-parse --show-toplevel)"

git_root="$(git rev-parse --show-toplevel)/submodules/VIP"
source $git_sub_root/submodules/VIP/bool/files.lst
source $git_sub_root/submodules/VIP/vip_axi4_agent/files.lst
source $git_sub_root/submodules/VIP/vip_clk_rst_agent/files.lst
source $git_sub_root/submodules/VIP/report_server/files.lst

# ------------------------------------------------------------------------------
# Source modules
# ------------------------------------------------------------------------------

# Restoring the git root
git_root="$(git rev-parse --show-toplevel)"
source ./rtl/files.lst
source ./tb/files.lst

# ------------------------------------------------------------------------------
# Parameter override
# ------------------------------------------------------------------------------

# Parameters
parameters+="AXI_ID_WIDTH_P=4 "
parameters+="AXI_ADDR_WIDTH_P=32 "
parameters+="AXI_DATA_WIDTH_P=16 "
parameters+="NR_OF_MASTERS_P=3 "
