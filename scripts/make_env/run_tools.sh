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

  source $git_root/scripts/vivado/vivado_synthesis.sh

else

  echo "ERROR [run_tools] No tool selected"

fi