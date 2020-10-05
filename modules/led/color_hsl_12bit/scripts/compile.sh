#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=axi4s_hsl_if
uvm_top="hsl_tb_top"

# Source the module's file lists
source ./rtl/rtl_files.lst
source ./tb/uvm_files.lst

# Parameter override
parameters+=("AXI_ID_WIDTH_P=4 ")
