#!/bin/bash
#SBATCH -t00:10:00
#SBATCH -Astf007
#SBATCH -N2
#SBATCH -q debug
#SBATCH -p batch
#SBATCH -J logs/frontier_apptainer_gpu_tests
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.out


module load rocm/5.7.1
module  load cray-mpich-abi
export MPICH_GPU_SUPPORT_ENABLED=1
export MPICH_SMP_SINGLE_COPY_MODE=NONE

#export NCCL_DEBUG=INFO
export BINDS=/usr/share/libdrm,/var/spool/slurmd,/opt/cray,${PWD}

export APPTAINERENV_LD_LIBRARY_PATH="$CRAY_MPICH_ROOTDIR/gtl/lib:/opt/rocm/lib:/opt/rocm/lib64:$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH:/opt/cray/pe/lib64:/opt/cray/xpmem/2.8.4-1.0_7.3__ga37cbd9.shasta/lib64"

# If you want to use aws-ofi-rccl, then build it with the awsofircclbuild.sh script in this directory, and modify the below line to point to the aws-ofi-rccl/lib location
export APPTAINERENV_LD_LIBRARY_PATH="${PWD}/aws-ofi-rccl/lib:$APPTAINERENV_LD_LIBRARY_PATH"

export APPTAINER_CONTAINLIBS="/usr/lib64/libcxi.so.1,/usr/lib64/libjson-c.so.3,/lib64/libtinfo.so.6,/usr/lib64/libnl-3.so.200,/usr/lib64/libgfortran.so.5,/usr/lib64/libjansson.so.4"

export APPTAINERENV_LD_PRELOAD=$CRAY_MPICH_ROOTDIR/gtl/lib/libmpi_gtl_hsa.so.0:

echo "TEST: RCCL MPI Enabled Multi-node test"

echo "RCCL TEST: all_reduce test"
srun -N2 -n4 apptainer exec --rocm  --bind $BINDS rcclmpich342rocm571.sif  /osu-micro-benchmarks-7.2/rccl-tests/build/all_reduce_perf -b 8 -e 128M -f 2 -g 4

echo "RCCL TEST: all_gather test"
srun -N2 -n4 apptainer exec --rocm  --bind $BINDS rcclmpich342rocm571.sif  /osu-micro-benchmarks-7.2/rccl-tests/build/all_gather_perf -b 8 -e 128M -f 2 -g 4

echo "RCCL TEST: alltoall test"
srun -N2 -n4 apptainer exec --rocm  --bind $BINDS rcclmpich342rocm571.sif  /osu-micro-benchmarks-7.2/rccl-tests/build/alltoall_perf -b 8 -e 128M -f 2 -g 4

echo "RCCL TEST: broadcast test"
srun -N2 -n4 apptainer exec --rocm  --bind $BINDS rcclmpich342rocm571.sif  /osu-micro-benchmarks-7.2/rccl-tests/build/broadcast_perf -b 8 -e 128M -f 2 -g 4

echo "RCCL TEST: reduce test"
srun -N2 -n4 apptainer exec --rocm  --bind $BINDS rcclmpich342rocm571.sif  /osu-micro-benchmarks-7.2/rccl-tests/build/reduce_perf -b 8 -e 128M -f 2 -g 4

echo "RCCL TEST: gather test"
srun -N2 -n4 apptainer exec --rocm  --bind $BINDS rcclmpich342rocm571.sif  /osu-micro-benchmarks-7.2/rccl-tests/build/gather_perf -b 8 -e 128M -f 2 -g 4

echo "RCCL TEST: scater test"
srun -N2 -n4 apptainer exec --rocm  --bind $BINDS rcclmpich342rocm571.sif  /osu-micro-benchmarks-7.2/rccl-tests/build/scatter_perf -b 8 -e 128M -f 2 -g 4

echo "RCCL TEST: sendrecv test"
srun -N2 -n4 apptainer exec --rocm  --bind $BINDS rcclmpich342rocm571.sif  /osu-micro-benchmarks-7.2/rccl-tests/build/sendrecv_perf -b 8 -e 128M -f 2 -g 4


