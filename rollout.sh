#!/bin/bash

set -e
PWD=$(get_pwd "${BASH_SOURCE[0]}")

################################################################################
####  Local functions  #########################################################
################################################################################
function create_directories() {
  if [ ! -d "${TPC_DS_DIR}"/log ]; then
    echo "Creating log directory"
    mkdir "${TPC_DS_DIR}"/log
  fi
}

################################################################################
####  Body  ####################################################################
################################################################################
create_directories

# We assume that the flag variable names are consistent with the corresponding directory names.
# For example, `00_compile_tpcds directory` name will be used to get `true` or `false` value from `RUN_COMPILE_TPCDS` in `tpcds_variables.sh`.
for i in "${PWD}"/0*/; do
  # split by the first underscore and extract the step name.
  step_name=${i#*_}
  step_name=${step_name%%/}
  # convert to upper case and concatenate "RUN_" in the front to get the flag name.
  flag_name="RUN_$(echo "${step_name}" | tr "[:lower:]" "[:upper:]")"
  # use indirect reference to convert flag name string to its value as "true" or "false".
  run_flag=${!flag_name}

  if [ "${run_flag}" == "true" ]; then
    echo ""
    echo "Run ${i}rollout.sh"
    "${i}"rollout.sh
  elif [ "${run_flag}" == "false" ]; then
    echo "Skip ${i}rollout.sh"
  else
    echo "Aborting script because ${flag_name} is not properly specified: must be either \"true\" or \"false\"."
    exit 1
  fi
done
