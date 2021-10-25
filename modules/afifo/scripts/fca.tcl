set design afifo

set_app_var fml_mode_on true
set_fml_appmode COV

read_covdb -cov_input simv.vdb -cov_dut afifo_tb_top.afifo_i0
read_file -top $design -format verilog -cov all -vcs {-f files.lst}

create_clock clk_wp -period 100
create_clock clk_rp -period 70
create_reset rst_wp_n -low
create_reset rst_rp_n -low

sim_run -stable
sim_save_reset

# batch
#check_fv -block
#report_fv -list > results.txt
#save_covdb -name cov -status covered
#save_cov_exclusion -file unr.el
