#!/bin/bash
#SBATCH -t00:20:00
#SBATCH -p batch
#SBATCH -A stf007uanofn
#SBATCH -N4
#SBATCH --ntasks-per-node 16
#SBATCH -c 1
#SBATCH -J gaea_mpi_test
#SBATCH -o logs/%x_%j.out
#SBATCH -e logs/%x_%j.out

# below is necessary to avoid ucx permission denied warning messages
# see https://ciq.com/blog/workaround-for-communication-issue-with-mpi-apps-apptainer-without-setuid
export UCX_POSIX_USE_PROC_LINK=n

# These exports are required so that the necessary MPI and Slurm pieces from the host are visible in
# the container and can be used by the application running in the container
export APPTAINER_BIND=/sw,/usr/share/libdrm,/var/spool/slurm,${PWD},${HOME}
export APPTAINERENV_LD_LIBRARY_PATH=$OLCF_MPICH_ROOT/lib:\$LD_LIBRARY_PATH

srun  -N4 -n16 --tasks-per-node 4 apptainer exec ./mpicontainer.sif  /osu-micro-benchmarks-7.5.2/c/mpi/collective/blocking/osu_allgather

