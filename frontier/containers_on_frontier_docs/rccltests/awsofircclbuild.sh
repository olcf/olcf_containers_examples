#!/usr/bin/bash -i
module load rocm
rocm_version=5.7.1
git clone --recursive --depth=1 https://github.com/ROCmSoftwarePlatform/aws-ofi-rccl
cd aws-ofi-rccl
libfabric_path=/opt/cray/libfabric/1.15.2.0
./autogen.sh
export LD_LIBRARY_PATH=/opt/rocm-$rocm_version/hip/lib:$LD_LIBRARY_PATH
CC=cc CFLAGS=-I/opt/rocm-$rocm_version/rccl/include ./configure \
--with-libfabric=$libfabric_path --with-rccl=/opt/rocm-$rocm_version --enable-trace \
--prefix=$PWD --with-hip=/opt/rocm-$rocm_version/hip --with-mpi=$MPICH_DIR
make
make install
