#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top="arbiter_s2m"
uvm_top="arbiter_s2m"

# ------------------------------------------------------------------------------
# Source submodules
# ------------------------------------------------------------------------------

git_sub_root="$(git rev-parse --show-toplevel)"

git_root="$(git rev-parse --show-toplevel)/submodules/VIP"
source $git_sub_root/submodules/VIP/bool/files.lst
source $git_sub_root/submodules/VIP/vip_axi4s_agent/files.lst
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

parameters+=("NR_OF_MASTERS_P=3 ")
parameters+=("DATA_WIDTH_P=32 ")
parameters+=("ID_WIDTH_P=4 ")

