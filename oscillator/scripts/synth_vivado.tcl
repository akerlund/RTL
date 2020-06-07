set report_dir      "./vivado_synth"
set fpga_part       "7z020clg484-1"
set git_root        [exec git rev-parse --show-toplevel];
set module_path     $git_root/oscillator/rtl
set wrapper         $git_root/oscillator/scripts/oscillator_top_synth_wrapper.sv
set top_module_name "oscillator_top_synth_wrapper"

file mkdir $report_dir

read_verilog -sv $module_path/osc_apb_slave_addr_pkg.sv
read_verilog -sv $module_path/oscillator_types_pkg.sv
read_verilog -sv $git_root/math/cordic/rtl/cordic_atan_radian_table_pkg.sv
read_verilog -sv $git_root/math/cordic/rtl/cordic_axi4s_types_pkg.sv
read_verilog -sv [ glob $git_root/clock_enable/rtl/*.sv]
read_verilog -sv [ glob $module_path/*.sv]
read_verilog -sv $wrapper

synth_design -mode out_of_context -top $top_module_name -part $fpga_part

write_checkpoint      -force $report_dir/post_synth.dcp
report_timing_summary -file  $report_dir/post_synth_timing_summary.rpt
report_utilization    -file  $report_dir/post_synth_util.rpt

report_utilization -cells [get_cells oscillator_top_i0]
