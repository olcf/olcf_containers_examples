#!/bin/bash
#SBATCH -q debug
#SBATCH -A stf007
#SBATCH -N 4
#SBATCH -t 00:15:00
#SBATCH -o logs/vllmmult_%j.out
#SBATCH -C nvme

export HF_HOME=/mnt/bb/$USER # Make sure nvme is in use with . Change this location if you want.

sbcast_start=$SECONDS
sbcast ./astrollama-2-7b-base_abstract.tar.gz /mnt/bb/$USER/astrollama-2-7b-base_abstract.tar.gz
if [ ! "$?" == "0" ]; then
    # CHECK EXIT CODE. When SBCAST fails, it may leave partial files on the compute nodes, and if you continue to launch srun,
    # your application may pick up partially complete shared library files, which would give you confusing errors.
    echo "SBCAST failed!"
    exit 1
fi
echo "show ls"
ls /mnt/bb/$USER
srun -N4 --tasks-per-node=1 tar -xzf /mnt/bb/$USER/astrollama-2-7b-base_abstract.tar.gz -C /mnt/bb/$USER
echo "show ls"
ls /mnt/bb/$USER
sbcast_duration=$(( SECONDS - sbcast_start ))
echo "sbcast_duration: $sbcast_duration"

start=$SECONDS
export HEAD_NODE_ADDR=$(hostname)
echo "HEAD_NODE_ADDR: $HEAD_NODE_ADDR"

APPTAINERENV_TRITON_CACHE_DIR="/tmp/triton/cache/"  # change write/build location for hip_utils in Triton
APPTAINER_CMD="apptainer exec --fakeroot --writable-tmpfs ./vllm_rocm.sif "
export APPTAINER_BINDPATH=/mnt/bb

# starting head node (head node start also starts a worker)
srun -N1 -n1 -c56 -G8 -w $HEAD_NODE_ADDR $APPTAINER_CMD ./start_head_bb.sh $SLURM_NNODES > logs/headnodelog 2>&1 &

# starting workers on other nodes 
srun -N3 -n3  --tasks-per-node=1 --cpus-per-task=56 --gpus-per-task=8 -x $HEAD_NODE_ADDR $APPTAINER_CMD ./start_worker.sh $HEAD_NODE_ADDR > logs/workernodeslog 2>&1 &

$APPTAINER_CMD python3 ./testprompt_bb.py
duration=$(( SECONDS - start ))
echo "duration: $duration"

