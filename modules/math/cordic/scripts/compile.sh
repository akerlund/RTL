#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=cordic_axi4s_if
uvm_top="cor_tb_top"

# Source the module's file lists
source ./rtl/rtl_files.lst
source ./tb/uvm_files.lst

# Parameter override
parameters+=("AXI_DATA_WIDTH_P=16 ")
parameters+=("AXI_ID_WIDTH_P=4 ")
parameters+=("NR_OF_STAGES_P=16 ")
