#!/usr/bin/bash -i
module reset
module load rocm
module load craype-accel-amd-gfx90a
rocm_version=6.2.4
git clone --recursive https://github.com/ROCmSoftwarePlatform/aws-ofi-rccl
cd aws-ofi-rccl
libfabric_path=/opt/cray/libfabric/1.22.0
./autogen.sh
export LD_LIBRARY_PATH=/opt/rocm-$rocm_version/hip/lib:$LD_LIBRARY_PATH
CC=cc CFLAGS=-I/opt/rocm-$rocm_version/rccl/include ./configure \
--with-libfabric=$libfabric_path --with-rccl=/opt/rocm-$rocm_version --enable-trace \
--prefix=$PWD --with-hip=/opt/rocm-$rocm_version/hip --with-mpi=$MPICH_DIR
make
make install
