set design fifo_register

set_app_var fml_mode_on true
read_file -top $design -format verilog -sva -vcs {-f files.lst}

create_clock clk -period 100
create_reset rst_n -low

sim_run -stable
sim_save_reset
