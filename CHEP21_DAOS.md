# Instructions to run RNTuple/DAOS benchmark
This file contains instructions to run the RNTuple/DAOS benchmarks whose results were included in the CHEP21 paper. The last steps produces a set of files suitable for use as data files in pgfplots.

1. Build ROOT with DAOS support. Note that you need a C++14-compliant compiler.
```
$ git clone -b jalopezg-rntuple-daos-CHEP21eval --depth=1 https://github.com/jalopezg-r00t/root
$ mkdir build/ && cd build/

$ # If DAOS is not installed system-wide, please specify the install directory by adding the option -DCMAKE_PREFIX_PATH=/path/to/daos/install
$ cmake -Droot7=ON -Ddaos=ON ../root

$ # Ensure that DAOS support has been enabled before continuing. CMake output should show something similar to '-- Found DAOS: ...'
$ make      # -jN

$ source bin/thisroot.sh
$ cd ../
```

2. Download the [B2HHH~none.root](https://cernbox.cern.ch/index.php/s/fVT9JicZHCUDGqn) and store it, if possible in a tmpfs. This will ensure that the entire file is kept in the page cache.

3. Get a copy of this branch and build the `gen_lhcb` and `lhcb` programs.
```
$ git clone -b daos-tests --depth=1 https://github.com/jalopezg-r00t/iotools
$ cd iotools/
$ make gen_lhcb lhcb
```

4. Create a pool that is large enough for running the benchmarks.
```
# dmg -i -l host-xxx pool create -s 250G -n 500G -g root -u root
host-xxx:10001: connected
Pool-create command SUCCEEDED: UUID: 9c6abe9e-6c68-4255-b52a-7fd5d8561b5a, Service replicas: 1
```

5. Create a pair of POSIX-type containers for dfuse use. Set object class `OC_SX` as default for the first container; `OC_RP_XSF` for the second.
```
# daos cont create --pool=9c6abe9e-6c68-4255-b52a-7fd5d8561b5a --svc=1 --type=POSIX --oclass=SX
Successfully created container 0a46fc33-16e8-40de-932d-07ccdd63bb6b

# daos cont create --pool=9c6abe9e-6c68-4255-b52a-7fd5d8561b5a --svc=1 --type=POSIX --oclass=RP_XSF
Successfully created container ff4b9da4-f618-46ce-8df9-d4049682e406
```

6. Mount the dfuse filesystems. Change the pool/container UUIDs and the mountpoint below as appropriate.
```
# dfuse --pool=9c6abe9e-6c68-4255-b52a-7fd5d8561b5a --svc=1 --container=0a46fc33-16e8-40de-932d-07ccdd63bb6b -m /mnt/dfuse_SX/ -f &
# dfuse --pool=9c6abe9e-6c68-4255-b52a-7fd5d8561b5a --svc=1 --container=ff4b9da4-f618-46ce-8df9-d4049682e406 -m /mnt/dfuse_RP_XSF/ -f &
```

7. Edit the `chep21_benchmark_params.sh` file and set `PUUID`, `SVC`, `INPUT_FILE`, `OUTPUT_FILE_LOCAL`, and `OUTPUT_FILE_DFUSE__*` variables as appropriate.

`OUTPUT_FILE_LOCAL` is a path to a file that will be created on a local filesystem (for measuring RNTuple performance on local fs). Similarly, `OUTPUT_FILE_DFUSE__*` are paths on the mounted dfuse filesystems.

For instance, for the commands executed above, the variables should be set as:
```
PUUID='9c6abe9e-6c68-4255-b52a-7fd5d8561b5a'

# List of ranks of service replicas, separated by commas, e.g. `1,2,3`
SVC='1'

# TTree file to be imported into RNTuple.
INPUT_FILE='/tmp/B2HHH~none.root'

# Output file for local filesystem tests. Leave empty to skip.
OUTPUT_FILE_LOCAL='/home/jalopezg/tmp_outfile.ntuple'

# Output file for dfuse filesystem tests. Leave any of these empty to skip.
OUTPUT_FILE_DFUSE__SX='/mnt/dfuse_SX/tmp_outfile.ntuple'
OUTPUT_FILE_DFUSE__RP_XSF='/mnt/dfuse_RP_XSF/tmp_outfile.ntuple'
```

8. Run the benchmarks. This step should generate a set of files named `chep21_summary_*.dat`.
```
# ./chep21_benchmark_run.sh
```
