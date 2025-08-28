#!/usr/bin/env bash

#SBATCH -A  stf007uanofn
#SBATCH -J lammps_container_gpu
#SBATCH -o %j.out
#SBATCH -N 2
#SBATCH -t 00:20:00

module reset
module load PrgEnv-gnu
module load olcf-container-tools
module load apptainer-enable-mpi apptainer-enable-gpu

srun -N 2 -n 16 --gpus-per-task=1 --gpu-bind=closest --unbuffered  apptainer exec lammps.sif lmp -k on g 1 -sf kk -pk kokkos gpu/aware on -in ij.in

