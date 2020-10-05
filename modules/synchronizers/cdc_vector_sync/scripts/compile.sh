#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=cdc_vector_sync
uvm_top=""

# Specify other file lists
source $git_root/modules/synchronizers/cdc_bit_sync/rtl/rtl_files.lst

# Source the module's file lists
source ./rtl/rtl_files.lst
source ./tb/uvm_files.lst

# Parameter override
parameters+=("DATA_WIDTH_P=32 ")
