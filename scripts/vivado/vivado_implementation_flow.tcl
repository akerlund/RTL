puts "INFO \[flow\] Vivado running in:"
puts "[pwd]"

puts "\nINFO \[flow\] Parameters:\n"
foreach p $parameters {
  puts "  $p"
}
puts ""

file mkdir "reports"

puts "INFO \[flow\] Reading the System Verilog files"

set file_list_path ./rtl_files.lst
set file_ref  [open $file_list_path r]
set file_data [read $file_ref]
close $file_ref

puts "INFO \[flow\] Parsing out the System Verilog file paths"

set sv_files [split $file_data "\n"]

foreach row $sv_files {
  if { ![regexp {^$} $row] && ![regexp {^\s*#.*} $row]} {
    read_verilog $row
  }
}

puts "INFO \[flow\] Override parameters of the top module"

set_property generic $parameters [current_fileset]

puts "\n--------------------------------------------------------------------------------"
puts "INFO \[flow\] synth_design"
puts "--------------------------------------------------------------------------------\n"

synth_design -top $top -part 7z020clg484-1 -mode $mode

write_checkpoint      -force $rpt_dir/post_synth.dcp
report_timing_summary -file  $rpt_dir/post_synth_timing_summary.rpt
report_utilization    -file  $rpt_dir/post_synth_util.rpt

if { $run_implementation != 1 } {
  quit
}

puts "\n--------------------------------------------------------------------------------"
puts "INFO \[flow\] opt_design"
puts "--------------------------------------------------------------------------------\n"

opt_design

puts "\n--------------------------------------------------------------------------------"
puts "INFO \[flow\] place_design"
puts "--------------------------------------------------------------------------------\n"

place_design

puts "\n--------------------------------------------------------------------------------"
puts "INFO \[flow\] report_clock_utilization"
puts "--------------------------------------------------------------------------------\n"

report_clock_utilization -file $rpt_dir/clock_util.rpt
if {[get_property SLACK [get_timing_paths -max_paths 1 -nworst 1 -setup]] < 0} {
puts "Found setup timing violations => running physical optimization"
  phys_opt_design
}

write_checkpoint      -force $rpt_dir/post_place.dcp
report_utilization    -file  $rpt_dir/post_place_util.rpt
report_timing_summary -file  $rpt_dir/post_place_timing_summary.rpt

if { $run_bitstream != 1 } {
  quit
}

puts "\n--------------------------------------------------------------------------------"
puts "INFO \[flow\] route_design"
puts "--------------------------------------------------------------------------------\n"

#route_design
#write_checkpoint      -force $rpt_dir/post_route.dcp

#report_route_status   -file $rpt_dir/post_route_status.rpt
#report_timing_summary -file $rpt_dir/post_route_timing_summary.rpt
#report_power          -file $rpt_dir/post_route_power.rpt
#report_drc            -file $rpt_dir/post_imp_drc.rpt

puts "\n--------------------------------------------------------------------------------"
puts "INFO \[flow\] write_bitstream"
puts "--------------------------------------------------------------------------------\n"

#write_verilog   -force $rpt_dir/cpu_impl_netlist.v -mode timesim -sdf_anno true
#write_bitstream -force $rpt_dir/cpu.bit

quit