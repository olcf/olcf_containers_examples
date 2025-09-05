#!/bin/bash 
#SBATCH -t00:10:00 
#SBATCH -A stf007
#SBATCH -p batch-cpu
#SBATCH -N2
#SBATCH -J mpiexample
#SBATCH -o logs/%x_%j.out
#SBATCH -e logs/%x_%j.out

module reset
module load cray-mpich-ucx-abi

export MPICH_SMP_SINGLE_COPY_MODE=NONE
export APPTAINERENV_LD_LIBRARY_PATH="/opt/cray/pe/mpich/8.1.32/ucx/crayclang/18.0/lib-abi-mpich:/opt/cray/pe/mpich/8.1.32/gtl/lib:$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH:/opt/cray/pe/lib64:/usr/lib64/libibverbs:/opt/cray/pals/1.6/lib:/usr/lib64/ucx"
export APPTAINER_CONTAINLIBS="/usr/lib64/libjansson.so.4,/usr/lib64/libdrm.so.2,/lib64/libtinfo.so.6,/usr/lib64/libnl-3.so.200,/usr/lib64/librdmacm.so.1,/usr/lib64/libibverbs.so.1,/usr/lib64/libibverbs/libmlx5-rdmav57.so,/lib64/libucs.so.0,/lib64/libucp.so.0,/lib64/libuct.so.0,/lib64/libucm.so.0"
export APPTAINER_BIND=/usr/share/libdrm,/var/spool/slurm,/opt/cray,/opt/mellanox,/etc/libibverbs.d,/usr/lib64/ucx,${PWD}



srun -N2 -n4 --tasks-per-node 2 apptainer exec --fakeroot  --workdir `pwd` mpiexample.sif /app/mpiexample
