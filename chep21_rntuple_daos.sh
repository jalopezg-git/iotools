#!/bin/bash
source `dirname $0`/chep21_benchmark_params.sh
source `dirname $0`/chep21_benchmark_functions.sh

if [ $# -lt 1 ]; then
    echo "Usage: $0 OUT_DIR";
    exit 1;
fi
OUT_DIR=$1
mkdir -p "$OUT_DIR"
CUUID=`uuidgen`

echo -e "Using DAOS pool ${PUUID}, container ${CUUID}.\nInput file: ${INPUT_FILE}.\n"
run_test_1 __rntuple_daos $BLOAT_FACTOR
run_test_2 __rntuple_daos $BLOAT_FACTOR
