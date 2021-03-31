#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top="fifo"
uvm_top=""

# Specify other file lists
source $git_root/modules/memory/reg/rtl/rtl_files.lst
source $git_root/modules/memory/ram/rtl/rtl_files.lst

# Source the module's file lists
source ./rtl/rtl_files.lst

# Parameter override
parameters+=("DATA_WIDTH_P=32 ")
parameters+=("ADDR_WIDTH_P=3 ")
