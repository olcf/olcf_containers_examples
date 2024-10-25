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
#export MPICH_GPU_SUPPORT_ENABLED=1
#export APPTAINER_WRAPPER_LD_PRELOAD=$CRAY_MPICH_ROOTDIR/gtl/lib/libmpi_gtl_hsa.so.0

# the below bindpath is necessary because the libmpich-abi libraries we bind in from the host
# through the apptainer-enable-mpi depends on libflang from /opt/rocm-6.0.0/llvm/lib. Now, the
# container does have its own /opt/rocm-6.0.0/llvm/lib but that doesn't have libflang for some
# reason. Not sure how to install that. 
#export APPTAINER_BINDPATH=/opt/rocm-6.0.0/llvm/lib #,`pwd`/testing  ##,/qmcpack/config/build_frontier_rocm600_offload_cuda2hip_real/Testing
#export APPTAINERENV_LD_LIBRARY_PATH=/opt/rocm-6.0.0/llvm/lib
export CONTAINERPATH=$PWD/qmcpack.sif
export MPICH_SMP_SINGLE_COPY_MODE=NONE

srun -N 1 -n 1  --unbuffered  apptainer exec $CONTAINERPATH ldd /qmcpack/config/build_frontier_rocm600_offload_cuda2hip_real/bin/qmcpack  
cd H2O/
srun -N 2 -n 16 --gpus-per-task=1 --gpu-bind=closest --unbuffered  apptainer exec $CONTAINERPATH /qmcpack/config/build_frontier_rocm600_offload_cuda2hip_real/bin/qmcpack ./simple-H2O.xml 

