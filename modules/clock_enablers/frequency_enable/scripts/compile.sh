#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=frequency_enable
uvm_top=""

# Source the module's file lists
source ./rtl/rtl_files.lst

# Parameter override
parameters+=("SYS_CLK_FREQUENCY_P=200000000 ")
parameters+=("AXI_DATA_WIDTH_P=32 ")
parameters+=("AXI_ID_WIDTH_P=4 ")
parameters+=("Q_BITS_P=17 ")
parameters+=("AXI4S_ID_P=1 ")
