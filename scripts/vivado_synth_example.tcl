set output_dir "./vivado_output"

file mkdir $output_dir

read_verilog  [ glob ./*.sv ]
read_xdc ./top.xdc

synth_design -top top -part 7z020clg484-1

write_checkpoint      -force $output_dir/post_synth.dcp
report_timing_summary -file $output_dir/post_synth_timing_summary.rpt
report_utilization    -file $output_dir/post_synth_util.rpt

opt_design
place_design

report_clock_utilization -file $output_dir/clock_util.rpt

if {[get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]] < 0} {
  puts "Found setup timing violations => running physical optimization"
  phys_opt_design
}

write_checkpoint      -force $output_dir/post_place.dcp
report_utilization    -file $output_dir/post_place_util.rpt
report_timing_summary -file $output_dir/post_place_timing_summary.rpt

route_design

write_checkpoint      -force $output_dir/post_route.dcp
report_route_status   -file $output_dir/post_route_status.rpt
report_timing_summary -file $output_dir/post_route_timing_summary.rpt
report_power          -file $output_dir/post_route_power.rpt
report_drc            -file $output_dir/post_imp_drc.rpt

write_verilog   -force $output_dir/cpu_impl_netlist.v -mode timesim -sdf_anno true
write_bitstream -force $output_dir/cpu.bit