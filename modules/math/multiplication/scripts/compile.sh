#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=nq_multiplier_axi4s_if
uvm_top="mul_tb_top"

# ------------------------------------------------------------------------------
# Source submodules
# ------------------------------------------------------------------------------

git_sub_root="$(git rev-parse --show-toplevel)"

git_root="$(git rev-parse --show-toplevel)/submodules/VIP"
source $git_sub_root/submodules/VIP/bool/files.lst
source $git_sub_root/submodules/VIP/vip_axi4s_agent/files.lst
source $git_sub_root/submodules/VIP/vip_clk_rst_agent/files.lst
source $git_sub_root/submodules/VIP/report_server/files.lst
source $git_sub_root/submodules/VIP/vip_fixed_point/files.lst
source $git_sub_root/submodules/VIP/vip_math/files.lst

# ------------------------------------------------------------------------------
# Source modules
# ------------------------------------------------------------------------------

# Restoring the git root
git_root="$(git rev-parse --show-toplevel)"
source ./rtl/files.lst
source ./tb/files.lst

# Parameter override
parameters+=("AXI_DATA_WIDTH_P=32 ")
parameters+=("AXI_ID_WIDTH_P=4 ")
parameters+=("N_BITS_P=32 ")
parameters+=("Q_BITS_P=17 ")

# ------------------------------------------------------------------------------
# FPGA Project
# ------------------------------------------------------------------------------

FPGA_PART="7z020clg484-1"
VIV_THREADS=12
FCLK_T="4.3"
