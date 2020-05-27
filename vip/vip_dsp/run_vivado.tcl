set  script_dir [pwd]
file mkdir "rundir"
cd   rundir
exec xvlog -sv ../../vip_math/vip_math_pkg.sv ../biquad_coefficients.svh ../vip_dsp_pkg.sv ../tb_vip_dsp_pkg.sv
exec xelab tb_vip_dsp_pkg -debug all -relax -s top -timescale 1ns/1ps
exec xsim top -gui
cd   $script_dir
