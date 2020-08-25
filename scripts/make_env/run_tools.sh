# Passed run directory
if [ "$#" -ge 1 ]; then
  rundir=$1
fi

# Passed tool, e.g., Vivado or Verilator
if [ "$#" -ge 2 ]; then
  tool=$2
fi

# Decide which tool to run
if [ "$tool" = "verilator" ]; then

  echo ""
  echo "--------------------------------------------------------------------------------"
  echo "INFO [run_tools] Starting Verilator"
  echo "--------------------------------------------------------------------------------"
  echo ""


  echo "INFO [run_tools] Creating run directory"
  the_time=$(date +'%d_%m_%Y_%H_%M_%S')
  ver_dir=$rundir/verilator/$the_time
  mkdir -p $ver_dir
  cd $ver_dir

  echo "INFO [run_tools] Overriding parameters"
  for p in ${parameters[@]}; do
    verilator_params+="-pvalue+$p "
    echo "-pvalue+$p "
  done

  $VERILATOR $VERILATOR_FLAGS --top-module $rtl_top $verilator_params $rtl_files $rtl_dirs


elif [ "$tool" = "vivado_synthesis" ]; then

  echo ""
  echo "--------------------------------------------------------------------------------"
  echo "INFO [run_tools] Starting Vivado Synthesis"
  echo "--------------------------------------------------------------------------------"
  echo ""


  echo "INFO [run_tools] Creating run directory"
  the_time=$(date +'%d_%m_%Y_%H_%M_%S')
  viv_dir=$rundir/vivado/$the_time
  mkdir -p $viv_dir
  cd $viv_dir


  echo "INFO [run_tools] Copying the script to the run directory"
  echo $rtl_files > rtl_files.lst
  cp   $git_root/scripts/vivado/vivado_synthesis.tcl ./


  echo "INFO [run_tools] Prepending the name of the top module"
  sed -i '1s;^;set top '$rtl_top'\n;' vivado_synthesis.tcl


  echo "INFO [run_tools] Setting the report directory"
  rpt_dir=reports
  sed -i '1s;^;set rpt_dir '$rpt_dir'\n;' vivado_synthesis.tcl

  echo "INFO [run_tools] Overriding parameters"
  for p in ${parameters[@]}; do
    vivado_params+="$p "
  done
  sed -i "1s;^;set parameters {$vivado_params}\n;" vivado_synthesis.tcl

  # Save the start time
  start=`date +%s`

  # Launch Vivado
  vivado -source vivado_synthesis.tcl -mode batch

  # Print utilization report if successful
  status=$?
  if [ $status -ne 0 ]; then
    echo "ERROR [run_tools] Vivado failed"
  else
    echo -e "INFO [run_tools] Vivado Slice Logic Report\n"
    sed -n '/^+-/,/^* Warning/p;/^* Warning/q' $rundir/vivado/$the_time/reports/post_synth_util.rpt

    echo -e "\n\nINFO [run_tools] Post Synthesis Report:"
    echo $rundir/vivado/$the_time/reports/post_synth_util.rpt
  fi

  # Print the runtime
  end=`date +%s`
  runtime=$((end-start))
  echo -e "INFO [run_tools] Execution time = "$runtime"\n"

else

  echo "ERROR [run_tools] No tool selected"

fi