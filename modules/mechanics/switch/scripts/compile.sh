#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=switch_core
uvm_top=""

# Specify other file lists
source $git_root/modules/synchronizers/io/rtl/rtl_files.lst

# Source the module's file lists
source ./rtl/rtl_files.lst

# Parameter override
parameters+=("NR_OF_DEBOUNCE_CLKS_P=100000 ")

