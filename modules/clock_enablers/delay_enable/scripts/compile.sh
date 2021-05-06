#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=delay_enable
uvm_top=delay_enable

# Source the module's file lists
source ./rtl/files.lst

# Parameter override
parameters+=("COUNTER_WIDTH_P=32 ")
