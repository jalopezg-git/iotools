#!/bin/bash
# chep21_gen_table.sh - Generate a summary table based on the execution logs
#
# Output format:
# CS     localfs dfuse_SX dfuse_RP_XSF libdaos_SX libdaos_RP_XSF
# 20000  0.1     1.0      1.1          2.0        2.1
# ...
THIS_DIR=`dirname $0`
source ${THIS_DIR}/chep21_benchmark_params.sh

if [ $# -lt 3 ]; then
    echo "Usage: $0 [gen_lhcb|lhcb] [fPSvCS|PSeqCS] COMPRESSION"
    exit 1
fi
GENLHCB_OR_LHCB="$1" # Generate table for either 'gen_lhcb' or 'lhcb'
PREFIX="$2"
COMPRESSION="$3"

if [ "$PREFIX" == fPSvCS ]; then
    CLUSTER_SIZES="$TEST1_CLUSTER_SIZES"
    PAGE_SIZE="$TEST1_PAGE_SIZE"
else
    CLUSTER_SIZES="$TEST2_CLUSTER_SIZES"
    PAGE_SIZE=''
fi

# List of filename templates that contain per-column data, in order
FILENAME_TMPL="\
${THIS_DIR}/chep21_results/local/${PREFIX}-NA-${COMPRESSION}- \
${THIS_DIR}/chep21_results/dfuse__SX/${PREFIX}-NA-${COMPRESSION}- \
${THIS_DIR}/chep21_results/dfuse__RP_XSF/${PREFIX}-NA-${COMPRESSION}- \
${THIS_DIR}/chep21_results/libdaos/${PREFIX}-OC_SX-${COMPRESSION}- \
${THIS_DIR}/chep21_results/libdaos/${PREFIX}-OC_RP_XSF-${COMPRESSION}- \
"

echo -e 'CS    localfs    dfuse_SX    dfuse_RP_XSF    libdaos_SX    libdaos_RP_XSF'
for _CS in $CLUSTER_SIZES; do
    printf '%8d' $_CS
    if [ -z "$PAGE_SIZE" ]; then _PS=$_CS; else _PS=$PAGE_SIZE; fi
    for IN in $FILENAME_TMPL; do
        FILENAME=`eval echo $IN`${_CS}-${_PS}-bloat${BLOAT_FACTOR}.log
        if [ ! -r $FILENAME ]; then
            printf '%10s' ?
            continue;
        fi
        
        if [ "$GENLHCB_OR_LHCB" == gen_lhcb ]; then
            grep ^real $FILENAME | head -1 | awk '
BEGIN { elapsed = 0; }
      { match($2, /([0-9]+)m([0-9.]+)s/, m); elapsed = (m[1] * 60) + m[2]; }
END   { printf("%10.5f", elapsed); }'
        else
            grep ^Runtime-Main $FILENAME | awk '
BEGIN { elapsed = 0; }
      { match($2, /([0-9]+)us/, m); elapsed = (m[1] / 1000000.0); }
END   { printf("%10.5f", elapsed); }'
        fi
    done
    echo -ne '\n'
done
