set  git_root   [exec git rev-parse --show-toplevel]
set  script_dir [pwd]
file mkdir "rundir"
cd   rundir
exec xvlog -sv ../../rtl/frequency_enable.sv $git_root/math/division/long_division/rtl/long_division_core.sv $git_root/math/division/long_division/rtl/long_division_axi4s_if.sv ../../tb/tb_clock_enable.sv
exec xelab tb_clock_enable -debug all -relax -s top -timescale 1ns/1ps
exec xsim top -gui
cd   $script_dir
