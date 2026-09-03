#!/bin/bash
#SBATCH -t00:10:00
#SBATCH -Astf007uanofn
#SBATCH -N2
#SBATCH --gpus 2
#SBATCH -J gpu_test_riker
#SBATCH -o logs/%x_%j.out
#SBATCH -e logs/%x_%j.out
#SBATCH -p gpu


# below is necessary to avoid ucx permission denied warning messages
# see https://ciq.com/blog/workaround-for-communication-issue-with-mpi-apps-apptainer-without-setuid
export UCX_POSIX_USE_PROC_LINK=n

# These exports are required so that the necessary MPI and Slurm pieces from the host are visible in
# the container and can be used by the application running in the container
export APPTAINER_BIND=/sw,/usr/share/libdrm,/var/spool/slurm,${PWD},${HOME}  
export APPTAINERENV_LD_LIBRARY_PATH=$OLCF_MPICH_ROOT/lib:\$LD_LIBRARY_PATH

export OMP_NUM_THREADS=1
srun -N1 -n1 -G1 --gpus-per-task=1 apptainer exec --nv ./rockylinuxcuda133.sif make
time srun -N2 -n2 -G1 --gpus-per-task=1 apptainer exec --nv ./rockylinuxcuda133.sif ./hello_jobstep

