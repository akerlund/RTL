#!/bin/bash

git_root="$(git rev-parse --show-toplevel)"
uvm_tb_top="awa_tb_top"
source ./rtl/rtl_files.lst
source ./tb/uvm_files.lst
source $git_root/scripts/make_env/compile.sh
