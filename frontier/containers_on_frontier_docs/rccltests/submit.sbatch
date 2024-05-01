#!/bin/bash
#SBATCH -t00:10:00
#SBATCH -Astf243
#SBATCH -N2
#SBATCH -p batch
#SBATCH -J frontier_apptainer_gpu_tests
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.out


module  load cray-mpich/8.1.26
module  load cray-mpich-abi/8.1.26
module load rocm/5.5.1
export BINDS=/usr/share/libdrm,/var/spool/slurmd,/opt/cray,${PWD}

export APPTAINERENV_LD_LIBRARY_PATH="/opt/cray/pe/mpich/8.1.26/ofi/crayclang/14.0/lib-abi-mpich:/opt/cray/pe/mpich/8.1.26/gtl/lib:/opt/rocm/lib:/opt/rocm/lib64:$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH:/opt/cray/pe/lib64"
export APPTAINER_CONTAINLIBS="/usr/lib64/libcxi.so.1,/usr/lib64/libjson-c.so.3,/lib64/libtinfo.so.6,/usr/lib64/libnl-3.so.200"

export APPTAINERENV_LD_PRELOAD=/opt/cray/pe/mpich/8.1.26/gtl/lib/libmpi_gtl_hsa.so.0:


echo "TEST: RCCL MPI Enabled Multi-node test"

echo "RCCL TEST: all_reduce test"
srun -N2 -n4 apptainer exec --rocm  --bind $BINDS rcclmpich342rocm551.sif  /osu-micro-benchmarks-7.2/rccl-tests/build/all_reduce_perf -b 8 -e 128M -f 2 -g 4



echo "RCCL TEST: all_gather test"
srun -N2 -n4 apptainer exec --rocm  --bind $BINDS rcclmpich342rocm551.sif  /osu-micro-benchmarks-7.2/rccl-tests/build/all_gather_perf -b 8 -e 128M -f 2 -g 4

echo "RCCL TEST: alltoall test"
srun -N2 -n4 apptainer exec --rocm  --bind $BINDS rcclmpich342rocm551.sif  /osu-micro-benchmarks-7.2/rccl-tests/build/alltoall_perf -b 8 -e 128M -f 2 -g 4

echo "RCCL TEST: broadcast test"
srun -N2 -n4 apptainer exec --rocm  --bind $BINDS rcclmpich342rocm551.sif  /osu-micro-benchmarks-7.2/rccl-tests/build/broadcast_perf -b 8 -e 128M -f 2 -g 4

echo "RCCL TEST: reduce test"
srun -N2 -n4 apptainer exec --rocm  --bind $BINDS rcclmpich342rocm551.sif  /osu-micro-benchmarks-7.2/rccl-tests/build/reduce_perf -b 8 -e 128M -f 2 -g 4

echo "RCCL TEST: gather test"
srun -N2 -n4 apptainer exec --rocm  --bind $BINDS rcclmpich342rocm551.sif  /osu-micro-benchmarks-7.2/rccl-tests/build/gather_perf -b 8 -e 128M -f 2 -g 4

echo "RCCL TEST: scater test"
srun -N2 -n4 apptainer exec --rocm  --bind $BINDS rcclmpich342rocm551.sif  /osu-micro-benchmarks-7.2/rccl-tests/build/scatter_perf -b 8 -e 128M -f 2 -g 4

echo "RCCL TEST: sendrecv test"
srun -N2 -n4 apptainer exec --rocm  --bind $BINDS rcclmpich342rocm551.sif  /osu-micro-benchmarks-7.2/rccl-tests/build/sendrecv_perf -b 8 -e 128M -f 2 -g 4


