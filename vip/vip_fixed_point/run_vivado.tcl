set  script_dir [pwd]
file mkdir "rundir"
cd   rundir
exec xvlog -sv ../vip_fixed_point_pkg.sv ../tb_vip_fixed_point_pkg.sv
exec xelab tb_fixed_point -debug all -relax -s top -timescale 1ns/1ps
exec xsim top -gui
cd   $script_dir
