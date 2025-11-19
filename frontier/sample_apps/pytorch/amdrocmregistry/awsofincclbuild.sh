#!/usr/bin/bash -i
module reset
module load cpe/25.09
module load rocm/6.4.2
module load craype-accel-amd-gfx90a
rocm_version=6.4.2
git clone https://github.com/aws/aws-ofi-nccl
cd aws-ofi-nccl
git checkout 8dc2ce4
libfabric_path=/opt/cray/libfabric/1.22.0
export LD_LIBRARY_PATH=/opt/rocm-$rocm_version/lib:$LD_LIBRARY_PATH
./autogen.sh
CC=cc CFLAGS=-I/opt/rocm-$rocm_version/rccl/include ./configure \
--with-libfabric=$libfabric_path --enable-trace \
--prefix=$PWD --with-mpi=$MPICH_DIR --with-rocm=/opt/rocm-$rocm_version
make
make install
