### Adjust the following parameters for your environment ###

# Pool UUID used for the DAOS tests. A container UUID is not required, as
# containers are created on-demand. Leave empty to skip DAOS tests.
PUUID=''

# List of ranks of service replicas, separated by commas, e.g. `1,2,3`
SVC='1'

# TTree file to be imported into RNTuple.
INPUT_FILE='/path/to/B2HHH~none.root'

# Output file for local filesystem tests. Leave empty to skip.
OUTPUT_FILE_LOCAL='/path/to/local/output/file'

# Output file for dfuse filesystem tests. Leave any of these empty to skip.
OUTPUT_FILE_DFUSE__SX='/path/to/file/on/dfuse_sx/mount'
OUTPUT_FILE_DFUSE__RP_XSF='/path/to/file/on/dfuse_rp_xsf/mount'

### In principle, touching values below is not required ###
BLOAT_FACTOR=10
OCLASSES='OC_SX OC_RP_XSF'
COMPRESSIONS='none zstd'

# Test 1 - fixed page size, varying cluster size
TEST1_CLUSTER_SIZES='20000 40000 80000 160000 320000'
TEST1_PAGE_SIZE='10000'

# Test 2 - varying cluster size == page size
TEST2_CLUSTER_SIZES='5000 10000 20000 40000 100000 200000'
