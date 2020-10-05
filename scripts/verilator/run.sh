#!/bin/bash

# Check input paramters
if [ "$#" -lt 2 ]; then
  echo "ERROR: Verilator run script missing input parameters"
else
  file_list=$1
  rundir=$2
fi

# Locate configuration and waiver file
module_path=$(pwd)
v_config=$module_path/verilator/configuration.vlt
v_waiver=$module_path/verilator/waiver.wv

# Source module file list
git_root=$(git rev-parse --show-toplevel)
source $file_list
echo $file_list
echo $rtl_files

################################################################################
# Verilator variables
################################################################################
# Common flags
verilator_flags+="-cc --exe "                     # Generate C++ in executable form
verilator_flags+="-Os -x-assign 0 "               # Optimize
verilator_flags+="-sv "                           # Enable SystemVerilog parsing
verilator_flags+="--assert "                      # Check SystemVerilog assertions
verilator_flags+="--lint-only "                   # Lint, but do not make output
verilator_flags+="--stats "
verilator_flags+="-Wno-fatal "                    # Disable fatal exit on warnings
verilator_flags+="--waiver-output all_waived.wv " # Write a waiver template
#verilator_flags+="-MMD "                         # Generate makefile dependencies (not shown as complicates the Makefile)
#verilator_flags+="-Wall "                        # Warn abount lint issues; may not want this on less solid designs
#verilator_flags+="--trace "                      # Make waveforms
#verilator_flags+="--quiet-exit "                 # Don't print the command on failure
#verilator_flags+="--clk clk "                    # Define the clock port
#verilator_flags+="--coverage "                   # Generate coverage analysis
#verilator_flags+="--debug "                      # Run Verilator in debug mode
#verilator_flags+="--gdbbt "                      # Add this trace to get a backtrace in gdb

echo ""
echo "--------------------------------------------------------------------------------"
echo "INFO [run_verilator] Starting Verilator"
echo "--------------------------------------------------------------------------------"
echo ""

the_time=$(date +'%d_%m_%Y_%H_%M_%S')
ver_dir=$rundir/verilator/$the_time
mkdir -p $ver_dir
cd $ver_dir

echo "INFO [run_verilator] Created run directory: $ver_dir"

for p in ${parameters[@]}; do
  verilator_params+="-pvalue+$p "
done

verilator $verilator_flags $v_config $v_waiver --top-module $rtl_top $verilator_params $rtl_files $rtl_dirs

echo -e "\nINFO [run_verilator] Suggested waivers are written to:\n$rundir/verilator/$the_time/all_waived.wv\n"
