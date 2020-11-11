#!/bin/bash
set -e

# ------------------------------------------------------------------------------
# Check input parameters
# ------------------------------------------------------------------------------

if [ "$#" -lt 3 ]; then
  echo "ERROR: Vivado run script missing input parameters"
else
  make_root=$1
  file_list=$2
  rundir=$3
fi

# ------------------------------------------------------------------------------
# Source module file list and create the rundir
# ------------------------------------------------------------------------------

echo "INFO [run_tools] Sourcing files"
source $file_list

echo "INFO [run_tools] Creating run directory"
the_time=$(date +'%d_%m_%Y_%H_%M_%S')
viv_dir=$rundir/vivado

if [[ ! -d "$viv_dir" ]]; then
  mkdir -p $viv_dir
fi

# ------------------------------------------------------------------------------
# Writing the file lists and prepending variables to copied scripts
# ------------------------------------------------------------------------------
cd $viv_dir
echo "INFO [run_tools] Copying the scripts to the run directory"
echo $rtl_dirs  > rtl_dirs.lst
echo $rtl_files > rtl_files.lst
cp   $make_root/scripts/vivado/build_zynq.tcl ./
cp   $make_root/scripts/vivado/start_zynq_notrace.tcl ./
cp   $bd_project ./

# Save the start time
start=`date +%s`

echo -e "\n--------------------------------------------------------------------------------"
echo -e "INFO [run_tools] Starting Vivado"
echo -e "--------------------------------------------------------------------------------\n"

vivado -source start_zynq_notrace.tcl
# -mode batch


# Print the runtime
end=`date +%s`
runtime=$((end-start))
echo -e "INFO [run_tools] Execution time: $(($runtime/3600))h $((($runtime/60)%60 ))m $(($runtime%60))s\n"
