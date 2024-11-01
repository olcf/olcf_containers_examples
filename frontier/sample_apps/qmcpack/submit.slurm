#!/usr/bin/env bash

#SBATCH -A stf007
#SBATCH -J qmcpacksample
#SBATCH -o logs/%j.out
#SBATCH -q debug
#SBATCH -N 2
#SBATCH -t 00:20:00

module reset
module load PrgEnv-amd amd/6.0.0
module load rocm/6.0.0
module unload darshan-runtime
module unload cray-libsci
module load cmake
module load cray-fftw
module load openblas
module load cray-hdf5-parallel
module load olcf-container-tools
module load apptainer-enable-mpi apptainer-enable-gpu

export MPICH_SMP_SINGLE_COPY_MODE=NONE

cd H2O/
srun -N 2 -n 16 --gpus-per-task=1 --gpu-bind=closest --unbuffered  apptainer exec qmcpack.sif /qmcpack/config/install/build_frontier_rocm600_offload_cuda2hip_real/bin/qmcpack ./simple-H2O.xml 

