#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=button_core
uvm_top=button_core

# Specify other file lists
source $git_root/modules/synchronizers/io/rtl/files.lst

# Source the module's file lists
source ./rtl/files.lst

# Parameter override
parameters+=("NR_OF_DEBOUNCE_CLKS_P=100000 ")
