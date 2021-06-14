#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=mixer_top
uvm_top="mix_tb_top"

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

#v_sub_waivers+=""

# Restoring the git root
git_root="$(git rev-parse --show-toplevel)"
source $git_root/modules/arbiter/rtl/files.lst
source $git_root/modules/math/multiplication/rtl/files.lst
source ./rtl/files.lst
source ./tb/files.lst

# Parameter override
parameters+="AUDIO_WIDTH_P=24 "
parameters+="NR_OF_CHANNELS_P=4 "
parameters+="Q_BITS_P=7 "

# ------------------------------------------------------------------------------
# FPGA Project
# ------------------------------------------------------------------------------

FPGA_PART="7z020clg484-1"
VIV_THREADS=12
FCLK_T="2.0"
