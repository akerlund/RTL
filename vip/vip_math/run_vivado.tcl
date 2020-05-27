set  script_dir [pwd]
file mkdir "rundir"
cd   rundir

puts "INFO \[xvlog\] Parsing the compile list"
exec xvlog -sv ../vip_math_pkg.sv ../tb_vip_math_pkg.sv

puts "INFO \[xelab\] Elaborating the design"
exec xelab tb_vip_math_pkg -debug all -relax -s top -timescale 1ns/1ps

exec xsim top -gui

cd   $script_dir
