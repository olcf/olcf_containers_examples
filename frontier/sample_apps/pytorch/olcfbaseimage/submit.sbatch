#!/bin/bash
#SBATCH -A stf007
#SBATCH -J frontier_apptainer_pytorch_test
#SBATCH -o logs/%x.%j
#SBATCH -t 00:05:00
#SBATCH -p batch
#SBATCH -q debug
#SBATCH -N 4

# Load modules
module reset 
module load rocm/6.2.4
module load olcf-container-tools
module load apptainer-enable-mpi



## If you want to use aws-ofi-nccl, then build it with the awsofincclbuild.sh script in this directory, and modify the below line to point to the aws-ofi-nccl/lib location
export APPTAINERENV_LD_LIBRARY_PATH="${PWD}/aws-ofi-nccl/lib:$APPTAINERENV_LD_LIBRARY_PATH"
export APPTAINER_CONTAINLIBS=/usr/lib64/libhwloc.so.15
# see https://docs.olcf.ornl.gov/software/analytics/pytorch_frontier.html#aws-ofi-rccl-plugin
export NCCL_NET_GDR_LEVEL=3           # Typically improves performance, but remove this setting if you encounter a hang/crash.
export NCCL_CROSS_NIC=1               # On large systems, this NCCL setting has been found to improve performance
export NCCL_SOCKET_IFNAME=hsn0        # NCCL/RCCL will use the high speed network to coordinate startup.
# uncomment this only if you need a lot of debug information
#export NCCL_DEBUG=info

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
srun -N4 --label --tasks-per-node=8 -c7 --gpus-per-task=1 --gpu-bind=closest apptainer exec --workdir `pwd` --rocm pytorch.sif ./pyrun.sh
