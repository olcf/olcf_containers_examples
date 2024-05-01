#!/bin/bash
#SBATCH -t00:10:00
#SBATCH -Astf243
#SBATCH -N2
#SBATCH -p batch
#SBATCH -J frontier_apptainer_gpu_tests
#SBATCH -o %x_%j.out
#SBATCH -e %x_%j.out


module load cray-mpich
module load rocm/5.5.1




echo "TEST: RCCL MPI Enabled Multi-node test"

echo "RCCL TEST: all_reduce test"
srun -N2 -n4 apptainer exec --rocm  --bind /usr/share/libdrm rcclmpich342rocm551.sif  /osu-micro-benchmarks-7.2/rccl-tests/build/all_reduce_perf -b 8 -e 128M -f 2 -g 4



echo "RCCL TEST: all_gather test"
srun -N2 -n4 apptainer exec --rocm  --bind /usr/share/libdrm rcclmpich342rocm551.sif  /osu-micro-benchmarks-7.2/rccl-tests/build/all_gather_perf -b 8 -e 128M -f 2 -g 4

echo "RCCL TEST: alltoall test"
srun -N2 -n4 apptainer exec --rocm  --bind /usr/share/libdrm rcclmpich342rocm551.sif  /osu-micro-benchmarks-7.2/rccl-tests/build/alltoall_perf -b 8 -e 128M -f 2 -g 4

echo "RCCL TEST: broadcast test"
srun -N2 -n4 apptainer exec --rocm  --bind /usr/share/libdrm rcclmpich342rocm551.sif  /osu-micro-benchmarks-7.2/rccl-tests/build/broadcast_perf -b 8 -e 128M -f 2 -g 4

echo "RCCL TEST: reduce test"
srun -N2 -n4 apptainer exec --rocm  --bind /usr/share/libdrm rcclmpich342rocm551.sif  /osu-micro-benchmarks-7.2/rccl-tests/build/reduce_perf -b 8 -e 128M -f 2 -g 4

echo "RCCL TEST: gather test"
srun -N2 -n4 apptainer exec --rocm  --bind /usr/share/libdrm rcclmpich342rocm551.sif  /osu-micro-benchmarks-7.2/rccl-tests/build/gather_perf -b 8 -e 128M -f 2 -g 4

echo "RCCL TEST: scater test"
srun -N2 -n4 apptainer exec --rocm  --bind /usr/share/libdrm rcclmpich342rocm551.sif  /osu-micro-benchmarks-7.2/rccl-tests/build/scatter_perf -b 8 -e 128M -f 2 -g 4

echo "RCCL TEST: sendrecv test"
srun -N2 -n4 apptainer exec --rocm  --bind /usr/share/libdrm rcclmpich342rocm551.sif  /osu-micro-benchmarks-7.2/rccl-tests/build/sendrecv_perf -b 8 -e 128M -f 2 -g 4


