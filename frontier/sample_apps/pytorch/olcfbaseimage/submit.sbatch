#!/bin/bash
#SBATCH -A stf007
#SBATCH -J frontier_apptainer_pytorch_test
#SBATCH -o logs/%x.%j
#SBATCH -t 00:05:00
#SBATCH -p batch
#SBATCH -q debug
#SBATCH -N 2

# Load modules
module reset 
module load olcf-container-tools
module load apptainer-enable-mpi
module load apptainer-enable-gpu
module load craype-accel-amd-gfx90a


# Get address of head node
ips=`hostname -I`
read -ra arr <<< ${ips}
export MASTER_ADDR=${arr[0]}
echo "MASTER_ADDR=" $MASTER_ADDR

# Needed to bypass MIOpen, Disk I/O Errors
export MIOPEN_USER_DB_PATH="/tmp/my-miopen-cache"
export MIOPEN_CUSTOM_CACHE_DIR=${MIOPEN_USER_DB_PATH}
rm -rf ${MIOPEN_USER_DB_PATH}
mkdir -p ${MIOPEN_USER_DB_PATH}


# Run script
srun -N2 --label --tasks-per-node=8 -c7 --gpus-per-task=1 --gpu-bind=closest apptainer exec --workdir `pwd` --rocm pytorch.sif ./pyrun.sh
