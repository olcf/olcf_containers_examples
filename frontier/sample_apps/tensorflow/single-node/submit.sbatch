#!/bin/bash
#SBATCH -A stf007
#SBATCH -J ddp_test
#SBATCH -o logs/frontier_apptainer_mltests.%j
#SBATCH -e logs/frontier_apptainer_mltests.%j
#SBATCH -t 00:05:00
#SBATCH -p batch
#SBATCH -N 1




#Loading modules 
module load craype-accel-amd-gfx90a

set -ex

#Run Script 
srun --label -N1 --tasks-per-node=1 -c56 --gpus-per-task=1 --gpu-bind=closest apptainer exec --workdir `pwd`  ../tensorflow_latest.sif  ./pyrun.sh
