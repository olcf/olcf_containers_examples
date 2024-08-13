#!/bin/bash 
#SBATCH -t00:15:00 
#SBATCH -Astf007
#SBATCH -N2
#SBATCH -J frontier_gpu_aware_mpi_example
#SBATCH -o logs/%x_%j.out
#SBATCH -e logs/%x_%j.out

# Loading rocm/5.7.1 since that is what is installed in the container
module  load rocm/5.7.1

# The cray-mpich-abi module contains the libmpi.so that the MPI application in
# the container (that wasn't compiled with a Cray compiler) will look for.
module load craype-network-ofi
module  load cray-mpich-abi

# This is set so to turn on GPU aware MPI
export MPICH_GPU_SUPPORT_ENABLED=1

# We are setting this as a convenience that we pass to apptainer's --bind flag. 
# What this does is mount the given directories from the host into the container so that they are visible # within the container. So any application inside the container are able to reach the files in these 
# locations on the host.
# We are binding these specific locations as they are required for the Cray MPICH libraries 
# to be visible inside the container and for MPI to work with good 
# performance. The application in the container will be able to see and link to the Cray MPICH
# libraries instead of using the MPICH libraries we install in the container.
export BINDS=/usr/share/libdrm,/var/spool/slurmd,/opt/cray,${PWD}

# What APPTAINERENV_* does is set that environment variable inside the container environment. 
# For example, if you `export APPTAINERENV_BLAH=foo` before you do an `apptainer (run|exec|shell)`,
# within your container the environment variable BLAH=foo will be set.
# So here, we are setting the value of LD_LIBRARY_PATH inside the container to include the Cray
# MPICH locations (which we have access to because we mount /opt/cray into the container, see 
# the BINDS environment variable), the host's LD_LIBRARY_PATH and CRAY_LD_LIBRARY_PATH contents, 
# and the container's (not host's) rocm location. This will replace any preexisting LD_LIBRARY_PATH
# that might've been defined as part of the container build, so make sure to explicitly include 
# any paths from within the container's file tree that you want available to the application 
# in the container.
export APPTAINERENV_LD_LIBRARY_PATH="$CRAY_MPICH_DIR/lib-abi-mpich:$CRAY_MPICH_ROOTDIR/gtl/lib:/opt/rocm/lib:/opt/rocm/lib64:$CRAY_LD_LIBRARY_PATH:$LD_LIBRARY_PATH:/opt/cray/pe/lib64:/opt/cray/xpmem/2.6.2-2.5_2.40__gd067c3f.shasta/lib64"

# APPTAINER_CONTAINLIBS allows you to specify individual libraries from the host that you want
# visible inside the container and added to the LD_LIBRARY_PATH inside the container.
# In this GPU aware MPI example, Some specific libraries from the host's /usr/lib64 need to 
# be visible inside the container for the Cray MPICH libraries (that we are making visible 
# inside the container with the earlier steps) to work as the Cray MPICH libraries are linked
# linked to them.
export APPTAINER_CONTAINLIBS="/usr/lib64/libcxi.so.1,/usr/lib64/libjson-c.so.3,/lib64/libtinfo.so.6,/usr/lib64/libnl-3.so.200,/usr/lib64/libgfortran.so.5,/usr/lib64/libjansson.so.4"

# This is required when you have an application that is compiled inside a container that 
# doesn't have access to the Cray MPICH libraries during the container build process (such as our
# example opensusempich342rocm571.def). The libmpi_gtl_hsa.so is what provides GPU aware MPI,
# but the application is not linked to it because it wasn't available in the container when the 
# application was being built during the container build process. So we
# need to make sure it is preloaded so that the application uses it.
export APPTAINERENV_LD_PRELOAD=$CRAY_MPICH_ROOTDIR/gtl/lib/libmpi_gtl_hsa.so.0:


# This is executing the ping_ping_gpu_aware.exe in the container with `apptainer exec`. 
# The program passes data allocated on GPU memory of increasing size back and forth between 
# two MPI processes across two nodes.
# The --rocm flag is required to support AMD GPUs inside the container.
srun  -N2  --tasks-per-node 1 --gpus-per-task=1 apptainer exec --bind $BINDS --workdir `pwd` --rocm  opensusempich342rocm571.sif /ping_pong_gpu_aware.exe

