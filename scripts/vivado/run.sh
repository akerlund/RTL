#!/bin/bash
set -e

# ------------------------------------------------------------------------------
# Check input parameters
# ------------------------------------------------------------------------------

if [ "$#" -lt 2 ]; then
  echo "ERROR: Vivado run script missing input parameters"
else
  file_list=$1
  rundir=$2
fi

# Vivado Synthesis/Implementation/Bitfile/ZynQ
if [ "$#" -ge 3 ]; then
  viv_run=$3
fi

# Set Vivado to run out-of-context (OOC)
if [ "$#" -ge 4 ]; then
  viv_ooc=$4
fi

# ------------------------------------------------------------------------------
# Source module file list and create the rundir
# ------------------------------------------------------------------------------

echo "INFO [run_tools] Sourcing files"
git_root=$(git rev-parse --show-toplevel)
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
echo "INFO [run_tools] Copying the script to the run directory"
echo $rtl_dirs  > rtl_dirs.lst
echo $rtl_files > rtl_files.lst
echo $uvm_files > uvm_files.lst
echo $uvm_dirs  > uvm_dirs.lst
cp   $git_root/scripts/vivado/build_normal.tcl ./
cp   $git_root/scripts/vivado/start_vivado_notrace.tcl ./


echo "INFO [run_tools] Prepending the name of the top RTL module"
sed -i '1s;^;set rtl_top '$rtl_top'\n;' build_normal.tcl

echo "INFO [run_tools] Prepending the name of the top UVM module"
sed -i '1s;^;set uvm_top '$uvm_top'\n;' build_normal.tcl

echo "INFO [run_tools] Setting the report directory"
rpt_dir=reports
sed -i '1s;^;set rpt_dir '$rpt_dir'\n;' build_normal.tcl

echo "INFO [run_tools] Overriding parameters"
for p in ${parameters[@]}; do
  vivado_params+="$p "
done
sed -i "1s;^;set parameters {$vivado_params}\n;" build_normal.tcl

# Out of Context?
if [ $viv_ooc -ge 1 ]; then
  sed -i '1s;^;set mode out_of_context\n;' build_normal.tcl
else
  sed -i '1s;^;set mode default\n;' build_normal.tcl
fi

# Route and make bitstream?
if [ "$viv_run" -ge 1 ]; then
  sed -i "1s;^;set run_mode 1\n;" build_normal.tcl
else
  sed -i "1s;^;set run_mode 0\n;" build_normal.tcl
fi

# Save the start time
start=`date +%s`

echo -e "\n--------------------------------------------------------------------------------"
echo -e "INFO [run_tools] Starting Vivado"
echo -e "--------------------------------------------------------------------------------\n"

vivado -source start_vivado_notrace.tcl -mode batch

# Print utilization report if successful
status=$?
if [ $status -ne 0 ]; then
  echo "ERROR [run_tools] Vivado failed"
else

  if [ "$viv_run" -ge 1 ]; then
    echo -e "\n--------------------------------------------------------------------------------"
    echo -e "INFO [run_tools] post_synth_util.rpt"
    echo -e "--------------------------------------------------------------------------------\n"
    echo -e ""
    sed -n '/^+-/,/^* Warning/p;/^* Warning/q' $viv_dir/reports/post_synth_util.rpt

    echo -e "\n--------------------------------------------------------------------------------"
    echo -e "INFO [run_tools] Vivado Log"
    echo -e "--------------------------------------------------------------------------------\n"

    grep ^"WARNING:"           $viv_dir/vivado.log
    grep ^"CRITICAL WARNING:"  $viv_dir/vivado.log
    grep ^"ERROR:"             $viv_dir/vivado.log
    echo ""
    grep ^"Synthesis finished" $viv_dir/vivado.log
 fi
fi

# Print the runtime
end=`date +%s`
runtime=$((end-start))
echo -e "INFO [run_tools] Execution time: $(($runtime/3600))h $((($runtime/60)%60 ))m $(($runtime%60))s\n"
