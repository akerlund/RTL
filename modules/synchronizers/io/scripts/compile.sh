#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=io_synchronizer
uvm_top=""

# Source the module's file lists
source ./rtl/rtl_files.lst
