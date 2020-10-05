#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=rgb_led_pwm
uvm_top=""

# Source the module's file lists
source ./rtl/rtl_files.lst

# Parameter override
parameters+=("COLOR_WIDTH_P=12 ")
parameters+=("TID_BIT_WIDTH_P=2 ")
parameters+=("CR_AXI4S_TID_P=0 ")
