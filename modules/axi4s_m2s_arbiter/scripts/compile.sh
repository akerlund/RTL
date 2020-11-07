#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=axi4s_m2s_arbiter
uvm_top=arb_tb_top

source $git_root/vip/vip_axi4s_agent/uvm_files.lst

# Source the module's file lists
source ./rtl/rtl_files.lst
source ./tb/uvm_files.lst

# Parameter override
parameters+=("NR_OF_MASTERS_P=3 ")
parameters+=("AXI_DATA_WIDTH_P=32 ")
parameters+=("AXI_STRB_WIDTH_P=4 ")
parameters+=("AXI_KEEP_WIDTH_P=4 ")
parameters+=("AXI_ID_WIDTH_P=4 ")
parameters+=("AXI_DEST_WIDTH_P=4 ")
parameters+=("AXI_USER_WIDTH_P=4 ")
