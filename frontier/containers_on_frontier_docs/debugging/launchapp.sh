#!/bin/bash

# change 0 in the line below to another rank id if you want to debug a different MPI rank
if [[ $SLURM_PROCID -eq 0 ]]; then
    # this will launch a gdbserver with the MPI rank 0
    #gdbserver 0.0.0.0:2345 /opt/mpi_bcast
    gdbserver 0.0.0.0:2345  /opt/lammps/bin/lmp -k on g 1 -sf kk -pk kokkos gpu/aware on -in ij.in
else
    # this launches all the other MPI ranks normally
    #/opt/mpi_bcast
    /opt/lammps/bin/lmp -k on g 1 -sf kk -pk kokkos gpu/aware on -in ij.in
fi
