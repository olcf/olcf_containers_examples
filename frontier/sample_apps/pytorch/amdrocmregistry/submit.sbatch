#!/bin/bash
#SBATCH -A stf007
#SBATCH -J frontier_apptainer_pytorch_prebuilt_test
#SBATCH -o logs/%x.%j
#SBATCH -t 00:05:00
#SBATCH -p batch
#SBATCH -q debug
#SBATCH -N 4

# Load modules
module reset 
module load cpe/25.09
# if you want to use aws-ofi-rccl, then load the rocm module that matches the rocm version in your
# container and then load the rccl-net-plugin module
module load rocm/6.4.2
module load rccl-net-plugin

module load olcf-container-tools
module load apptainer-enable-mpi


# This must be set if you are loading the rccl-net-plugin to make sure that the plugin library is
# visible in the running container
export APPTAINERENV_LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$APPTAINERENV_LD_LIBRARY_PATH

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

srun -N4 --tasks-per-node=8 -c7 --gpus-per-task=1 --gpu-bind=closest apptainer exec --workdir `pwd`  pytorch_rocm642.sif ./pyrun.sh
