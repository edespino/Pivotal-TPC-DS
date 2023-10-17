#!/bin/bash
set -e

VARS_FILE="tpcds_variables.sh"
FUNCTIONS_FILE="functions.sh"

if [ ! -f "./${VARS_FILE}" ]; then
  echo "./${VARS_FILE} does not exist. Please ensure that this file exists before running TPC-DS. Exiting."
  exit 1
else
  # shellcheck source=tpcds_variables.sh
  source ./${VARS_FILE}
fi

# Output the config file (tpcds_variables.sh) to standard output
cat << EOF

############################################################################
TPC-DS for Greenplum Database
----------------------------------------------------------------------------

Contents of ./${VARS_FILE}

$(cat ./${VARS_FILE})

----------------------------------------------------------------------------

EOF

# shellcheck source=functions.sh
source ./${FUNCTIONS_FILE}

# Check that pertinent variables are set in the variable file.
check_variables

source_bashrc

TPC_DS_DIR=$(get_pwd "${BASH_SOURCE[0]}")
export TPC_DS_DIR

# Make sure this is being run as gpadmin
check_admin_user
# Output admin user and multi-user count to standard out
print_header

# run the benchmark
./rollout.sh
