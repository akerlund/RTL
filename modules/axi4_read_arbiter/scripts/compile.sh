#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=axi4_read_arbiter
uvm_top="ara_tb_top"

# Source the module's file lists
source ./rtl/rtl_files.lst
source ./tb/uvm_files.lst

# Parameters
parameters+="AXI_ID_WIDTH_P=4 "
parameters+="AXI_ADDR_WIDTH_P=32 "
parameters+="AXI_DATA_WIDTH_P=16 "
parameters+="NR_OF_MASTERS_P=3 "
