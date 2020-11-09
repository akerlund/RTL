#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=nq_multiplier_axi4s_if
uvm_top="mul_tb_top"

# Source other modules file lists
source $git_root/vip/vip_fixed_point/uvm_files.lst
source $git_root/vip/vip_math/uvm_files.lst
source $git_root/vip/vip_axi4s_agent/uvm_files.lst

# Source the module's file lists
source ./rtl/rtl_files.lst
source ./tb/uvm_files.lst

# Parameter override
parameters+=("AXI_DATA_WIDTH_P=32 ")
parameters+=("AXI_ID_WIDTH_P=4 ")
parameters+=("N_BITS_P=32 ")
parameters+=("Q_BITS_P=17 ")
