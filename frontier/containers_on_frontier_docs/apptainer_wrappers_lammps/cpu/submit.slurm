#!/usr/bin/env bash

#SBATCH -A stf243
#SBATCH -J lammps_container_cpu
#SBATCH -o %j.out
#SBATCH -N 2
#SBATCH -t 00:10:00

module reset
module load PrgEnv-gnu
module load apptainer-wrappers
module load apptainer-enable-mpi

srun -N 2 -n 112 --ntasks-per-node=56 appexec lammps.sif lmp -in in.ij
