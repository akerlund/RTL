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

  $VERILATOR $VERILATOR_FLAGS $v_params $rtl_files $rtl_dirs

elif [ "$tool" = "vivado_synthesis" ]; then

  echo ""
  echo "--------------------------------------------------------------------------------"
  echo "INFO [run_tools] Starting Vivado Synthesis"
  echo "--------------------------------------------------------------------------------"
  echo ""

  the_time=$(date +'%d_%m_%Y_%H_%M_%S')

  if [ ! -e $rundir/vivado ]; then
    mkdir -p $rundir/vivado/$the_time
  the_time=$(date +'%d_%m_%Y_%H_%M_%S')
  fi

  cd $rundir/vivado/$the_time

  # Copying the script to the run directory
  echo $rtl_files > rtl_files.lst
  cp   $git_root/scripts/vivado/vivado_synthesis.tcl ./

  # Prepending the name of the top module
  sed -i.old '1s;^;set top '$rtl_top'\n;' vivado_synthesis.tcl

  start=`date +%s`

  # Launch Vivado
  vivado -source vivado_synthesis.tcl -mode batch

  # Print utilization report if successful
  status=$?
  if [ $status -ne 0 ]; then
    echo "ERROR [run_tools] Vivado failed"
  else
    echo -e "INFO [run_tools] Vivado Slice Logic Report\n"
    sed -n '/^+-/,/^* Warning/p;/^* Warning/q' vivado_output/post_synth_util.rpt
  fi

  end=`date +%s`

  runtime=$((end-start))
    echo -e "INFO [run_tools] Execution time = "$runtime"\n"

else

  echo "ERROR [run_tools] No tool selected"

fi