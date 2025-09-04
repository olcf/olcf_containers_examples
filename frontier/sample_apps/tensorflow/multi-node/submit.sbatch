#!/bin/bash
#SBATCH -A stf016
#SBATCH -J ddp_test
#SBATCH -o logs/frontier_apptainer_mltests.%j
#SBATCH -e logs/frontier_apptainer_mltests.%j
#SBATCH -t 00:30:00
#SBATCH -p batch
#SBATCH -N 2

# Only necessary if submitting like: sbatch --export=NONE ... (recommended)
# Do NOT include this line when submitting without --export=NONE
#unset SLURM_EXPORT_ENV

# Load modules

module load cray-mpich-abi/8.1.31
module load craype-accel-amd-gfx90a
module load rocm/5.7.1
module load miniforge3

read -ra arr <<< ${ips}

export NCCL_SOCKET_IFNAME=hsn0

export MASTER_ADDR=$(getent hosts $(scontrol show hostnames $SLURM_NODELIST | head -n1) | awk '{ print $1 }')
#export MASTER_ADDR=$(hostname -i)
echo "MASTER_ADDR=" $MASTER_ADDR
export MASTER_PORT=3442
export NCCL_SOCKET_IFNAME=hsn0
export GLOO_SOCKET_IFNAME=hsn0
# Needed to bypass MIOpen, Disk I/O Errors
export MIOPEN_USER_DB_PATH="/tmp/my-miopen-cache"
export MIOPEN_CUSTOM_CACHE_DIR=${MIOPEN_USER_DB_PATH}
rm -rf ${MIOPEN_USER_DB_PATH}
mkdir -p ${MIOPEN_USER_DB_PATH}

#export NCCL_IB_DISABLE=1
##export NCCL_DEBUG=INFO
#export TF_CPP_MIN_LOG_LEVEL=0
##export GRPC_VERBOSITY=debug
#export GRPC_TRACE=all
#export GRPC_ENABLE_FORK_SUPPORT=true
#export TF_FORCE_GPU_ALLOW_GROWTH=true
#export GRPC_ARG_ENABLE_IPV4_ONLY=true
#
#rm -rf ${MIOPEN_USER_DB_PATH}
#mkdir -p ${MIOPEN_USER_DB_PATH}
#
hosts=$(scontrol show hostnames $SLURM_JOB_NODELIST)
hosts_array=($hosts)
#
## Setup TF_CONFIG for each worker

TF_CONFIG=$(cat <<EOF
{
  "cluster": {
    "worker": ["${hosts_array[0]}:12345", "${hosts_array[1]}:23456"]
  },
  "task": {"type": "worker", "index": $rank}
}
EOF
)
#
#export TF_CONFIG="$TF_CONFIG"
#echo TF_CONFIG="$TF_CONFIG"
#
export MPICH_GPU_SUPPORT_ENABLED=1
export BINDS=/usr/share/libdrm,/var/spool/slurmd,/opt/cray,${PWD}
export APPTAINERENV_LD_LIBRARY_PATH="/opt/cray/pe/mpich/8.1.31/ofi/crayclang/17.0/lib-abi-mpich:/opt/cray/pe/mpich/8.1.31/gtl/lib:/opt/rocm-5.7.1/lib:$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH:/opt/cray/pe/lib64"
export APPTAINER_CONTAINLIBS="/usr/lib64/libcxi.so.1,/usr/lib64/libjson-c.so.3,/lib64/libtinfo.so.6,/usr/lib64/libnl-3.so.200"

set -ex
# Run script
#
srun -N2 -n2 --gpus=16 --gpu-bind=closest apptainer exec --workdir `pwd` --rocm --bind $BINDS tensorflow_latest.sif  ./pyrun.sh

