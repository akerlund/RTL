#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=cdc_bit_sync
uvm_top=cdc_bit_sync

# Source the module's file lists
source ./rtl/files.lst
