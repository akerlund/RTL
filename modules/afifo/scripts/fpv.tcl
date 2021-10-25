set design afifo

set_app_var fml_mode_on true
read_file -top $design -format verilog -sva -vcs {-f files.lst}

create_clock clk_wp -period 6.4
create_clock clk_rp -period 8.0
create_reset rst_wp_n -low
create_reset rst_rp_n -low

sim_run -stable
sim_save_reset
