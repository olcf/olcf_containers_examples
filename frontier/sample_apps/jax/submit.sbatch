#!/bin/bash
#SBATCH -A stf007
#SBATCH -J ddp_test
#SBATCH -o logs/frontier_apptainer_mltests.%j
#SBATCH -e logs/frontier_apptainer_mltests.%j
#SBATCH -t 00:05:00
#SBATCH -p batch
#SBATCH -N 1

export all_proxy=socks://proxy.ccs.ornl.gov:3128/
export ftp_proxy=ftp://proxy.ccs.ornl.gov:3128/
export http_proxy=http://proxy.ccs.ornl.gov:3128/
export https_proxy=http://proxy.ccs.ornl.gov:3128/
export no_proxy='localhost,127.0.0.0/8,*.ccs.ornl.gov'

# Only necessary if submitting like: sbatch --export=NONE ... (recommended)
# Do NOT include this line when submitting without --export=NONE
#unset SLURM_EXPORT_ENV

# Load modules

module load rocm/6.4.0
module load craype-accel-amd-gfx90a

set -ex

echo "About to Run Apptainer Exec"
# Run script
cd examples
srun -N1 --tasks-per-node=8 -c7 --gpus-per-task=1 --gpu-bind=closest apptainer exec --workdir `pwd` ../jax_latest.sif  ../pyrun.sh
