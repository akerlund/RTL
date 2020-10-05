#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=long_division_axi4s_if
uvm_top="div_tb_top"

# Source the module's file lists
source ./rtl/rtl_files.lst
source ./tb/uvm_files.lst

# Parameter override
parameters+=("AXI_DATA_WIDTH_P=32 ")
parameters+=("AXI_ID_WIDTH_P=4 ")
parameters+=("N_BITS_P=32 ")
parameters+=("Q_BITS_P=17 ")
