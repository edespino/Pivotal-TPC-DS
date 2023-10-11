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

cat << EOF
############################################################################
TPC-DS for Greenplum Database.
----------------------------------------------------------------------------

-- environment options --
ADMIN_USER: ${ADMIN_USER}
BENCH_ROLE: ${BENCH_ROLE}

-- to connect directly to GP --
PGPORT: ${PGPORT}

-- benchmark options --
GEN_DATA_SCALE: ${GEN_DATA_SCALE}
MULTI_USER_COUNT: ${MULTI_USER_COUNT}
RNGSEED: ${RNGSEED}
HEAP_ONLY: ${HEAP_ONLY}

-- step options --
RUN_COMPILE_TPCDS: ${RUN_COMPILE_TPCDS}
RUN_GEN_DATA: ${RUN_GEN_DATA}
GEN_NEW_DATA: ${GEN_NEW_DATA}
RUN_INIT: ${RUN_INIT}
RUN_DDL: ${RUN_DDL}
RUN_LOAD: ${RUN_LOAD}
RUN_SQL: ${RUN_SQL}
RUN_SINGLE_USER_REPORTS: ${RUN_SINGLE_USER_REPORTS}
RUN_QGEN: ${RUN_QGEN}
RUN_MULTI_USER: ${RUN_MULTI_USER}
RUN_MULTI_USER_REPORTS: ${RUN_MULTI_USER_REPORTS}
RUN_SCORE: ${RUN_SCORE}

-- misc options --
SINGLE_USER_ITERATIONS: ${SINGLE_USER_ITERATIONS}
EXPLAIN_ANALYZE: ${EXPLAIN_ANALYZE}
RANDOM_DISTRIBUTION: ${RANDOM_DISTRIBUTION}

-- gpfdist location where gpfdist will run p (primary) or m (mirror) --
GPFDIST_LOCATION: ${GPFDIST_LOCATION}

-- general info --
OSVERSION: ${OSVERSION}
MASTER_HOST: ${MASTER_HOST}
LD_PRELOAD: ${LD_PRELOAD}

############################################################################

EOF

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
    echo "Run ${i}/rollout.sh"
    "${i}"/rollout.sh
  elif [ "${run_flag}" == "false" ]; then
    echo "Skip ${i}/rollout.sh"
  else
    echo "Aborting script because ${flag_name} is not properly specified: must be either \"true\" or \"false\"."
    exit 1
  fi
done
