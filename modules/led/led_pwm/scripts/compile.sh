#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"

# Specify the top files
rtl_top=led_pwm
uvm_top=""

# Source the module's file lists
source ./rtl/rtl_files.lst

# Parameter override
v_params+=("COUNTER_WIDTH_P=32 ")
