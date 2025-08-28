#!/usr/bin/env bash

#SBATCH -A stf007
#SBATCH -J lammps_cpu_container
#SBATCH -o %j.out
#SBATCH -N 2
#SBATCH -t 00:20:00

module reset
module load PrgEnv-gnu
module load olcf-container-tools
module load apptainer-enable-mpi

export MPICH_SMP_SINGLE_COPY_MODE=NONE

srun -u -N 2 -n 112 --ntasks-per-node=56 apptainer exec lammps.sif lmp -in ij.in

