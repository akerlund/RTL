#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=iir_biquad_top
uvm_top="iir_tb_top"

# Specify other file lists
source $git_root/modules/math/cordic/rtl/rtl_files.lst

# Source the module's file lists
source ./rtl/rtl_files.lst
source ./tb/uvm_files.lst

# Parameter override
parameters+=("AXI_DATA_WIDTH_P=32 ")
parameters+=("AXI_ID_WIDTH_P=4 ")
parameters+=("AXI4S_ID_P=1 ")
parameters+=("APB_DATA_WIDTH_P=32 ")
parameters+=("N_BITS_P=32 ")
parameters+=("Q_BITS_P=17 ")
