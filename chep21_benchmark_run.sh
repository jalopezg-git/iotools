#!/bin/bash
THIS_DIR=`dirname $0`
source ${THIS_DIR}/chep21_benchmark_params.sh
function print_hdr() {
    echo "[`date`] ==== $1 ===="
}

if [ -n "$PUUID" ]; then
    print_hdr 'Running RNTuple/libdaos benchmark'
    ${THIS_DIR}/chep21_rntuple_daos.sh ${THIS_DIR}/chep21_results/libdaos/
fi

if [ -n "$OUTPUT_FILE_LOCAL" ]; then
    print_hdr 'Running RNTuple/local benchmark'
    ${THIS_DIR}/chep21_rntuple_file.sh ${THIS_DIR}/chep21_results/local/ "$OUTPUT_FILE_LOCAL"
fi

if mountpoint -q `dirname "$OUTPUT_FILE_DFUSE__SX"` && mountpoint -q `dirname "$OUTPUT_FILE_DFUSE__RP_XSF"`; then
    if [ -n "$OUTPUT_FILE_DFUSE__SX" ]; then
        print_hdr 'Running RNTuple/dfuse(OC_SX) benchmark'
        ${THIS_DIR}/chep21_rntuple_file.sh ${THIS_DIR}/chep21_results/dfuse__SX/ "$OUTPUT_FILE_DFUSE__SX"
    fi

    if [ -n "$OUTPUT_FILE_DFUSE__RP_XSF" ]; then
        print_hdr 'Running RNTuple/dfuse(OC_RP_XSF) benchmark'
        ${THIS_DIR}/chep21_rntuple_file.sh ${THIS_DIR}/chep21_results/dfuse__RP_XSF/ "$OUTPUT_FILE_DFUSE__RP_XSF"
    fi
else
    echo 'WARNING: skiping dfuse tests; directory is not a mountpoint'
fi

print_hdr 'Generating pgfplots data file'
for _CMD in gen_lhcb lhcb; do
    for _TEST in fPSvCS PSeqCS; do
        for _C in none zstd; do
            ${THIS_DIR}/chep21_gen_table.sh $_CMD $_TEST $_C \
                       > ${THIS_DIR}/chep21_summary_${_CMD}-${_TEST}-${_C}.dat
        done
    done
done
