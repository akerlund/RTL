#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top="fifo"
uvm_top="fifo"

# ------------------------------------------------------------------------------
# Source modules
# ------------------------------------------------------------------------------

source $git_root/modules/memory/reg/rtl/files.lst
source $git_root/modules/memory/ram/rtl/files.lst
source $git_root/modules/fifo/rtl/files.lst
source $git_root/modules/fifo/sva/files.lst

# ------------------------------------------------------------------------------
# Parameter override
# ------------------------------------------------------------------------------

parameters+=("DATA_WIDTH_P=32 ")
parameters+=("ADDR_WIDTH_P=3 ")
parameters+=("MAX_REG_BYTES_P=256 ")

# ------------------------------------------------------------------------------
# FPGA Project
# ------------------------------------------------------------------------------

VIV_THREADS=12
FCLK_T="5.0"
