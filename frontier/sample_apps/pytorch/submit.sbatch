#!/bin/bash
#SBATCH -A stf007
#SBATCH -J ddp_test
#SBATCH -o logs/frontier_apptainer_mltests.%j
#SBATCH -e logs/frontier_apptainer_mltests.%j
#SBATCH -t 00:05:00
#SBATCH -p batch
#SBATCH -N 4

# Only necessary if submitting like: sbatch --export=NONE ... (recommended)
# Do NOT include this line when submitting without --export=NONE
#unset SLURM_EXPORT_ENV

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
srun -N4 --tasks-per-node=8 -c7 --gpus-per-task=1 --gpu-bind=closest apptainer exec --workdir `pwd` --rocm pytorch.sif ./pyrun.sh

