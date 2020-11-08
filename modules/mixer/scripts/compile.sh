#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=mixer
uvm_top=mix_tb_top

# Source other modules file lists
source $git_root/vip/vip_fixed_point/uvm_files.lst
source $git_root/vip/vip_math/uvm_files.lst
source $git_root/vip/vip_axi4s_agent/uvm_files.lst
source $git_root/modules/math/multiplication/rtl/rtl_files.lst

# Source the module's file lists
source ./rtl/rtl_files.lst
source ./tb/uvm_files.lst

# Parameter override
parameters+=("AUDIO_WIDTH_P=24 ")
parameters+=("GAIN_WIDTH_P=24 ")
parameters+=("NR_OF_CHANNELS_P=4 ")
parameters+=("Q_BITS_P=7 ")
