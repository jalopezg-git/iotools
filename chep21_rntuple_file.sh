#!/bin/bash
source `dirname $0`/chep21_benchmark_params.sh
source `dirname $0`/chep21_benchmark_functions.sh

if [ $# -lt 2 ]; then
    echo "Usage: $0 OUT_DIR OUTPUT_FILE";
    exit 1;
fi
OUT_DIR=$1
mkdir -p "$OUT_DIR"
OCLASSES='NA'
OUTPUT_FILE=$2

echo -e "Using Input file: ${INPUT_FILE}; Output file: ${OUTPUT_FILE}.\n"
run_test_1 __rntuple_file $BLOAT_FACTOR
run_test_2 __rntuple_file $BLOAT_FACTOR
