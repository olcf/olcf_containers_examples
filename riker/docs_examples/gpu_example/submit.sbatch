#!/bin/bash
#SBATCH -t00:10:00
#SBATCH -Astf007uanofn
#SBATCH -N1
#SBATCH --gpus 1
#SBATCH -J gpu_test_riker
#SBATCH -o logs/%x_%j.out
#SBATCH -e logs/%x_%j.out
#SBATCH -p gpu


srun  -N1 -n1 -G1 --gpus-per-task=1  apptainer exec --nv ../containers/rockylinuxcuda133.sif /usr/local/cuda/bin/nvcc  -o cuda-test.o ./cuda-test.cu
time srun  -N1 -n1 -G1 --gpus-per-task=1  apptainer exec --nv ../containers/rockylinuxcuda133.sif  ./cuda-test.o

