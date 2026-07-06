#!/usr/bin/env bash

# Source this file to get the `refuse` helper:
#   source /home/shared/github/RTL/scripts/refuse.sh

_refuse_repo_root() {
  local src_dir
  src_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
  if [[ -d "$src_dir/modules" ]]; then
    printf '%s\n' "$src_dir"
    return
  fi

  git rev-parse --show-toplevel 2>/dev/null
}

_refuse_module_dir() {
  local dir=$PWD

  while [[ "$dir" != "/" ]]; do
    shopt -s nullglob
    local cores=("$dir"/*.core)
    shopt -u nullglob
    if (( ${#cores[@]} == 1 )); then
      printf '%s\n' "$dir"
      return
    fi
    dir=$(dirname -- "$dir")
  done

  return 1
}

_refuse_core_file() {
  local module_dir=$1

  shopt -s nullglob
  local cores=("$module_dir"/*.core)
  shopt -u nullglob

  if (( ${#cores[@]} != 1 )); then
    printf 'refuse: expected exactly one .core file in %s, found %d\n' "$module_dir" "${#cores[@]}" >&2
    return 1
  fi

  printf '%s\n' "${cores[0]}"
}

_refuse_core_name() {
  local core_file=$1

  sed -nE 's/^name:[[:space:]]*"?([^"]+)"?[[:space:]]*$/\1/p' "$core_file" | head -1
}

_refuse_py_core_file() {
  local module_dir=$1

  shopt -s nullglob
  local cores=("$module_dir"/py/*.core)
  shopt -u nullglob

  if (( ${#cores[@]} != 1 )); then
    printf 'refuse: expected exactly one py/*.core file in %s, found %d\n' "$module_dir" "${#cores[@]}" >&2
    return 1
  fi

  printf '%s\n' "${cores[0]}"
}

_refuse_cocotb_test_module() {
  local module_dir=$1
  local test=$2

  if [[ -z "$test" ]]; then
    return 0
  fi

  if [[ -f "$module_dir/py/tc/$test.py" ]]; then
    printf 'tc.%s\n' "$test"
    return 0
  fi

  if [[ "$test" == tb_* && -f "$module_dir/py/tc/tc_${test#tb_}.py" ]]; then
    printf 'tc.tc_%s\n' "${test#tb_}"
    return 0
  fi
}

_refuse_cocotb_results_failed() {
  local results=$1

  [[ -f "$results" ]] && grep -Eq '<(failure|error)([[:space:]/>]|$)' "$results"
}

_refuse_core_stem() {
  local core=$1

  printf '%s\n' "${core//:/_}"
}

_refuse_cores_root_args() {
  local repo_root=$1
  local roots=(
    "$repo_root/modules"
    "$repo_root/submodules/VIP"
    "$repo_root/submodules/PYRG"
  )
  local root

  for root in "${roots[@]}"; do
    if [[ -d "$root" ]]; then
      printf '%s\n' --cores-root "$root"
    fi
  done
}

_refuse_discover_tests() {
  local module_dir=$1

  find "$module_dir/tc" "$module_dir/sv/tc" -maxdepth 1 -name 'tc_*.sv' -printf '%f\n' 2>/dev/null \
    | sed 's/\.sv$//' \
    | sort
}

_refuse_run_root() {
  local module_dir=$1
  local run_root="$module_dir/rundir"

  if mkdir -p "$run_root" 2>/dev/null && [[ -w "$run_root" ]]; then
    printf '%s\n' "$run_root"
    return
  fi

  run_root="$module_dir/rundir.$(id -un)"
  mkdir -p "$run_root"
  printf '%s\n' "$run_root"
}

_refuse_usage() {
  cat <<'USAGE'
Usage, from inside a module directory:
  refuse vcs
  refuse simv -t <test>
  refuse simv --all
  refuse verilator
  refuse cocotb -t <test>

Examples:
  cd /home/shared/github/RTL/modules/afifo
  refuse vcs
  refuse simv -t tc_fi_basic
  refuse simv -t tc_fi_fast_to_slow
  refuse simv --all

VCS builds go to ./rundir/vcs.
VCS logs are written as ./rundir/vcs/<test>.log.
USAGE
}

refuse() {
  local cmd=${1:-}
  shift || true

  case "$cmd" in
    -h|--help|"")
      _refuse_usage
      return 0
      ;;
  esac

  local repo_root module_dir core_file core core_stem
  repo_root=$(_refuse_repo_root) || {
    printf 'refuse: could not find RTL repository root\n' >&2
    return 1
  }
  module_dir=$(_refuse_module_dir) || {
    printf 'refuse: run this from a module directory containing one .core file\n' >&2
    return 1
  }
  core_file=$(_refuse_core_file "$module_dir") || return 1
  core=$(_refuse_core_name "$core_file")
  if [[ -z "$core" ]]; then
    printf 'refuse: could not parse core name from %s\n' "$core_file" >&2
    return 1
  fi
  core_stem=$(_refuse_core_stem "$core")
  local cores_root_args=()
  mapfile -t cores_root_args < <(_refuse_cores_root_args "$repo_root")

  case "$cmd" in
    vcs)
      local run_root
      run_root=$(_refuse_run_root "$module_dir") || return 1
      mkdir -p "$run_root/vcs"
      fusesoc "${cores_root_args[@]}" run \
        --target uvm \
        --tool vcs \
        --work-root "$run_root/vcs" \
        --setup \
        --build \
        "$core" "$@"
      ;;

    simv)
      local test="" run_all=0
      while (($#)); do
        case "$1" in
          -t|--test)
            test=${2:-}
            if [[ -z "$test" ]]; then
              printf 'refuse simv: missing test name after %s\n' "$1" >&2
              return 1
            fi
            shift 2
            ;;
          --all)
            run_all=1
            shift
            ;;
          *)
            printf 'refuse simv: unknown argument %s\n' "$1" >&2
            return 1
            ;;
        esac
      done

      local run_root
      run_root=$(_refuse_run_root "$module_dir") || return 1
      local run_dir="$run_root/vcs"
      local simv="$run_dir/$core_stem"
      if [[ ! -x "$simv" ]]; then
        printf 'refuse: %s not found; building with `refuse vcs` first\n' "$simv"
        refuse vcs || return 1
      fi

      local tests=()
      if (( run_all )); then
        mapfile -t tests < <(_refuse_discover_tests "$module_dir")
        if (( ${#tests[@]} == 0 )); then
          printf 'refuse simv: no tc_*.sv files found in %s/tc or %s/sv/tc\n' \
            "$module_dir" "$module_dir" >&2
          return 1
        fi
      else
        if [[ -z "$test" ]]; then
          printf 'refuse simv: provide -t <test> or --all\n' >&2
          return 1
        fi
        local resolved_test
        resolved_test="$test"
        tests=("$resolved_test")
      fi

      local tc
      for tc in "${tests[@]}"; do
        local log="$run_dir/$tc.log"
        printf 'refuse: running %s -> %s/%s.log\n' "$tc" "$run_dir" "$tc"
        (
          cd "$run_dir" || exit 1
          "./$core_stem" +vcs+lic+wait "+UVM_TESTNAME=$tc" -l "$tc.log"
        ) || return 1

        local errors fatals
        errors=$(sed -nE 's/.*UVM_ERROR[[:space:]]*:[[:space:]]*([0-9]+).*/\1/p' "$log" | tail -1)
        fatals=$(sed -nE 's/.*UVM_FATAL[[:space:]]*:[[:space:]]*([0-9]+).*/\1/p' "$log" | tail -1)
        if [[ "${errors:-0}" != "0" || "${fatals:-0}" != "0" ]]; then
          printf 'refuse: %s failed (UVM_ERROR=%s UVM_FATAL=%s). See %s\n' \
            "$tc" "${errors:-unknown}" "${fatals:-unknown}" "$log" >&2
          return 1
        fi
      done
      ;;

    verilator)
      local run_root
      run_root=$(_refuse_run_root "$module_dir") || return 1
      mkdir -p "$run_root/verilator"
      fusesoc "${cores_root_args[@]}" run \
        --target rtl \
        --tool verilator \
        --work-root "$run_root/verilator" \
        --setup \
        --build \
        "$core" "$@"
      ;;

    cocotb)
      local test=""
      while (($#)); do
        case "$1" in
          -t|--test)
            test=${2:-}
            shift 2
            ;;
          *)
            printf 'refuse cocotb: unknown argument %s\n' "$1" >&2
            return 1
            ;;
        esac
      done

      local run_root
      run_root=$(_refuse_run_root "$module_dir") || return 1
      mkdir -p "$run_root/cocotb"
      local py_core_file py_core filter
      py_core_file=$(_refuse_py_core_file "$module_dir") || return 1
      py_core=$(_refuse_core_name "$py_core_file")
      if [[ -z "$py_core" ]]; then
        printf 'refuse cocotb: could not parse core name from %s\n' "$py_core_file" >&2
        return 1
      fi

      filter=${test:-.*}
      local test_module=""
      test_module=$(_refuse_cocotb_test_module "$module_dir" "$test")

      # vip_axi4_agent/py and vip_axi4s_agent/py each ship a top-level
      # `seq_lib` package with the same name -- if both dirs are ever put on
      # PYTHONPATH together, whichever comes first wins the `seq_lib` name
      # and silently hides the other VIP's sequences (e.g. `seq_lib.vip_axi4s_seq`
      # becomes unimportable). Only add the VIP(s) this module's own SV .core
      # actually depends on, so at most one `seq_lib` is ever on the path.
      local sv_core_file vip_paths=""
      sv_core_file=$(_refuse_core_file "$module_dir" 2>/dev/null) || sv_core_file=""
      if [[ -n "$sv_core_file" ]] && grep -q "vip_axi4s_agent" "$sv_core_file"; then
        vip_paths="$vip_paths:$repo_root/submodules/VIP/vip_axi4s_agent/py"
      fi
      if [[ -n "$sv_core_file" ]] && grep -q '"akerlund::vip_axi4_agent' "$sv_core_file"; then
        vip_paths="$vip_paths:$repo_root/submodules/VIP/vip_axi4_agent/py"
      fi

      (
        export PYTHONPATH="$module_dir/py$vip_paths:$repo_root/submodules/VIP/vip_gauss/py:${PYTHONPATH:-}"
        export COCOTB_TEST_FILTER="$filter"
        if [[ -n "$test_module" ]]; then
          export RTL_COCOTB_TEST_MODULE="$test_module"
        else
          unset RTL_COCOTB_TEST_MODULE
        fi
        fusesoc "${cores_root_args[@]}" run \
          --target sim \
          --tool verilator \
          --work-root "$run_root/cocotb" \
          --setup \
          --build \
          --run \
          "$py_core"
      )
      local cocotb_status=$?
      local results="$run_root/cocotb/results.xml"
      if _refuse_cocotb_results_failed "$results"; then
        printf 'refuse cocotb: failures reported in %s\n' "$results" >&2
        return 1
      fi
      return "$cocotb_status"
      ;;

    *)
      printf 'refuse: unknown command %s\n' "$cmd" >&2
      _refuse_usage >&2
      return 1
      ;;
  esac
}
