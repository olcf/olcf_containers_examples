#!/bin/bash
#SBATCH -A stf007
#SBATCH -J ddp_test
#SBATCH -o logs/frontier_apptainer_mltests.%j
#SBATCH -t 00:30:00
#SBATCH -p batch
#SBATCH -N 2


# Load modules

module load cpe/25.09
module load craype-accel-amd-gfx90a
module load olcf-container-tools
module load apptainer-enable-mpi
module load apptainer-enable-gpu-aware-mpi

read -ra arr <<< ${ips}


export MASTER_ADDR=$(getent hosts $(scontrol show hostnames $SLURM_NODELIST | head -n1) | awk '{ print $1 }')
echo "MASTER_ADDR=" $MASTER_ADDR
export MASTER_PORT=3442
export GLOO_SOCKET_IFNAME=hsn0
# Needed to bypass MIOpen, Disk I/O Errors
export MIOPEN_USER_DB_PATH="/tmp/my-miopen-cache"
export MIOPEN_CUSTOM_CACHE_DIR=${MIOPEN_USER_DB_PATH}
rm -rf ${MIOPEN_USER_DB_PATH}
mkdir -p ${MIOPEN_USER_DB_PATH}

hosts=$(scontrol show hostnames $SLURM_JOB_NODELIST)
hosts_array=($hosts)

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

set -ex
# Run script
srun -N2 -n2 --gpus=16 --gpu-bind=closest apptainer exec --workdir `pwd` ../tensorflow_latest.sif  ./pyrun.sh

