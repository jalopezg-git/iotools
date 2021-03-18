function __rntuple_file() {
    export RNTUPLE_CLUSTER_SIZE=$4
    export RNTUPLE_ELTS_PER_PAGE=$5

    echo "==== Running gen_lhcb + lhcb for oclass=$2 comp=$3 cluster_size=$4 page_size=$5 bloat=$6"
    (time ./gen_lhcb -i $INPUT_FILE -o $OUTPUT_FILE -c $3 -b $BLOAT_FACTOR) \
        |& tee ${OUT_DIR}/$1-$2-$3-$4-$5-bloat$6.log
    (time ./lhcb -i $OUTPUT_FILE -p) \
        |& tee -a ${OUT_DIR}/$1-$2-$3-$4-$5-bloat$6.log
    unlink $OUTPUT_FILE
}

function __rntuple_daos() {
    URI="daos://${PUUID}:${SVC/,/_}/${CUUID}"
    export CRT_CREDIT_EP_CTX=0
    export RNTUPLE_DAOS_OCLASS=$2
    export RNTUPLE_CLUSTER_SIZE=$4
    export RNTUPLE_ELTS_PER_PAGE=$5

    echo "==== Running gen_lhcb + lhcb for oclass=$2 comp=$3 cluster_size=$4 page_size=$5 bloat=$6"
    (time ./gen_lhcb -i $INPUT_FILE -o $URI -c $3 -b $BLOAT_FACTOR) \
        |& tee ${OUT_DIR}/$1-$2-$3-$4-$5-bloat$6.log
    (time ./lhcb -i $URI -p) \
        |& tee -a ${OUT_DIR}/$1-$2-$3-$4-$5-bloat$6.log
    daos container destroy --pool=$PUUID --svc=$SVC --cont=$CUUID
}

function run_test_1() {
    echo "==== Test 1: fixed page size (${TEST1_PAGE_SIZE}), varying cluster size"

    FUNC=$1; shift
    for _OC in ${OCLASSES}; do
        for _C in ${COMPRESSIONS}; do
            for _CS in ${TEST1_CLUSTER_SIZES}; do
                ${FUNC} fPSvCS $_OC $_C $_CS $TEST1_PAGE_SIZE $@
            done
        done
    done
}

function run_test_2() {
    echo "==== Test 2: varying cluster size (${TEST2_CLUSTER_SIZES}) == page size"

    FUNC=$1; shift
    for _OC in ${OCLASSES}; do
        for _C in ${COMPRESSIONS}; do
            for _CS in ${TEST2_CLUSTER_SIZES}; do
                ${FUNC} PSeqCS $_OC $_C $_CS $_CS $@
            done
        done
    done
}
