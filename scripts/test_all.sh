#!/bin/bash

git_root=$(git rev-parse --show-toplevel)

_skip_modules+="
  fifo
  fft
  cdc_bit_sync
  cdc_vector_sync
  io
  reset
  mixer
  rgb_led
  color_hsl_12bit
  led_pwm
  button
  encoder
  switch
  clock_enable_scaler
  delay_enable
  frequency_enable
  clock_enable
"
_skip_modules=${_skip_modules//[$'\t\r\n']}

_all_modules=$(find $git_root/modules -name Makefile | grep -v csrc | xargs dirname)
_run_target=run_all
_compile_only=0

_color_green="$(tput setaf 2)"
_color_red="$(tput setaf 1)"
_color_def="$(tput sgr0)"
_ret=0


while getopts ":hct:" opt; do
  case $opt in
    c )
      _compile_only=1
      ;;
    : )
      echo "ERROR: Flag $OPTARG requires an argument" 1>&2
      exit 1
      ;;
  esac
done
shift $((OPTIND -1))

for mod in $_all_modules; do

  _mod_name=$(basename $mod)
  _match=0
  for _skip_mod in $_skip_modules; do
    if [ "$_skip_mod" == "$_mod_name" ]; then
      _match=1
    fi
  done

  if [ $_match -eq 1 ]; then
    continue
  fi

  cd $mod

  if [ -f "tmp.log" ]; then
    rm tmp.log
  fi

  printf "%-45s" "Compiling $_mod_name:"
  _time_s=-$SECONDS

  make clean build > tmp.log 2>&1
  _status=$?

  _time_s=$((_time_s + SECONDS))
  _time_str=$(date -d@$_time_s -u +%H:%M:%S)

  if [ $_status -eq 0 ]; then

    echo "${_color_green}Passed${_color_def} ($_time_str)"

    if [[ $_compile_only -eq 0 && -d tc ]]; then

      printf "%-45s" "Running tests for $_mod_name: "
      make run_all > /dev/null 2>&1

      if [ $? -eq 0 ]; then
        echo "${_color_green}Passed${_color_def}"
      else

        _ret=-1
        echo "${_color_red}Failed${_color_def}"

        if [ -f "rundir/summary.log" ]; then
          grep Failed rundir/summary.log | awk '{print "  "$1}'
        else
          echo "  make run_all failed for $_mod_name, no logs"
        fi
      fi
    fi
  else
    echo "${_color_red}Failed${_color_def} ($_time_str)"
    _ret=-1
  fi
  rm tmp.log
done

exit $_ret
