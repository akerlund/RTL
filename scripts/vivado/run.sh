#!/bin/bash
set -e

# Check input paramters
if [ "$#" -lt 2 ]; then
  echo "ERROR: Vivado run script missing input parameters"
else
  file_list=$1
  rundir=$2
fi

# Vivado Synthesis/Implementation/Bitfile
if [ "$#" -ge 3 ]; then
  viv_run=$3
fi

# Set Vivado to run out-of-context (OOC)
if [ "$#" -ge 4 ]; then
  viv_ooc=$4
fi

# Source module file list
git_root=$(git rev-parse --show-toplevel)
echo $git_root
source $file_list


echo "INFO [run_tools] Creating run directory"
the_time=$(date +'%d_%m_%Y_%H_%M_%S')
viv_dir=$rundir/vivado/$the_time
mkdir -p $viv_dir
cd $viv_dir


echo "INFO [run_tools] Copying the script to the run directory"
#echo $rtl_dirs  > rtl_files.lst
echo $rtl_files > rtl_files.lst
cp   $git_root/scripts/vivado/vivado_implementation_flow.tcl ./
cp   $git_root/scripts/vivado/start_vivado_notrace.tcl ./


echo "INFO [run_tools] Prepending the name of the top module"
sed -i '1s;^;set top '$rtl_top'\n;' vivado_implementation_flow.tcl


echo "INFO [run_tools] Setting the report directory"
rpt_dir=reports
sed -i '1s;^;set rpt_dir '$rpt_dir'\n;' vivado_implementation_flow.tcl


echo "INFO [run_tools] Overriding parameters"
for p in ${parameters[@]}; do
  vivado_params+="$p "
done
sed -i "1s;^;set parameters {$vivado_params}\n;" vivado_implementation_flow.tcl

if [ $viv_ooc -ge 1 ]; then
  sed -i '1s;^;set mode out_of_context\n;' vivado_implementation_flow.tcl
else
  sed -i '1s;^;set mode default\n;' vivado_implementation_flow.tcl
fi


# Passed argument decides if we set the "run_implementation" variable
if [ "$viv_run" -ge 1 ]; then
  sed -i "1s;^;set run_implementation 1\n;" vivado_implementation_flow.tcl
else
  sed -i "1s;^;set run_implementation 0\n;" vivado_implementation_flow.tcl
fi


# Passed argument decides if we set the "run_bitstream" variable
if [ "$viv_run" -ge 2 ]; then
  sed -i "1s;^;set run_bitstream 1\n;" vivado_implementation_flow.tcl
else
  sed -i "1s;^;set run_bitstream 0\n;" vivado_implementation_flow.tcl
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

  echo -e "\n--------------------------------------------------------------------------------"
  echo -e "INFO [run_tools] post_synth_util.rpt"
  echo -e "--------------------------------------------------------------------------------\n"
  echo -e ""
  sed -n '/^+-/,/^* Warning/p;/^* Warning/q' $rundir/vivado/$the_time/reports/post_synth_util.rpt

  #if [ $viv_run -ge 1 ]; then
  #  echo -e "\n--------------------------------------------------------------------------------"
  #  echo -e "INFO [run_tools] post_place_util.rpt"
  #  echo -e "--------------------------------------------------------------------------------\n"
  #  echo -e ""
  #  sed -n '/^+-/,/^* calculated/p;/^* calculated/q' $rundir/vivado/$the_time/reports/post_place_util.rpt
  #fi

fi

echo -e "\n--------------------------------------------------------------------------------"
echo -e "INFO [run_tools] Vivado Log"
echo -e "--------------------------------------------------------------------------------\n"

grep ^"WARNING:"           $rundir/vivado/$the_time/vivado.log
grep ^"CRITICAL WARNING:"  $rundir/vivado/$the_time/vivado.log
grep ^"ERROR:"             $rundir/vivado/$the_time/vivado.log
echo ""
grep ^"Synthesis finished" $rundir/vivado/$the_time/vivado.log

# Print the runtime
end=`date +%s`
runtime=$((end-start))
echo -e "INFO [run_tools] Execution time: $(($runtime/3600))h $((($runtime/60)%60 ))m $(($runtime%60))s\n"
