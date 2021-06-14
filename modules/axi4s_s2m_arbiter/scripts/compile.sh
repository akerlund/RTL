#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=axi4s_s2m_arbiter
uvm_top=arb_tb_top

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
parameters+=("AXI_DATA_WIDTH_P=32 ")
parameters+=("AXI_STRB_WIDTH_P=4 ")
parameters+=("AXI_KEEP_WIDTH_P=4 ")
parameters+=("AXI_ID_WIDTH_P=4 ")
parameters+=("AXI_DEST_WIDTH_P=4 ")
parameters+=("AXI_USER_WIDTH_P=4 ")

# ------------------------------------------------------------------------------
# FPGA Project
# ------------------------------------------------------------------------------

FPGA_PART="7z020clg484-1"
VIV_THREADS=12
FCLK_T="2.5"