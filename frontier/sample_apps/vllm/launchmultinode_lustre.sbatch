#!/bin/bash
#SBATCH -q debug
#SBATCH -A stf007
#SBATCH -N 4
#SBATCH -t 00:15:00
#SBATCH -o logs/vllmmult_%j.out
#SBATCH -C nvme


export HF_HOME=/mnt/bb/$USER # Make sure nvme is in use with . Change this location if you want.


start=$SECONDS
export HEAD_NODE_ADDR=$(hostname)
echo "HEAD_NODE_ADDR: $HEAD_NODE_ADDR"

export APPTAINERENV_TRITON_CACHE_DIR="/tmp/triton/cache/"  # change write/build location for hip_utils in Triton
APPTAINER_CMD="apptainer exec --fakeroot --writable-tmpfs ./vllm_rocm.sif "
export APPTAINER_BINDPATH=/mnt/bb

# starting head node (head node start also starts a worker)
srun -N1 -n1 -c56 -G8 -w $HEAD_NODE_ADDR $APPTAINER_CMD ./start_head_lustre.sh $SLURM_NNODES > logs/headnodelog 2>&1 &

# starting workers on other nodes 
srun -N3 -n3  --tasks-per-node=1 --cpus-per-task=56 --gpus-per-task=8 -x $HEAD_NODE_ADDR $APPTAINER_CMD ./start_worker.sh $HEAD_NODE_ADDR > logs/workernodeslog 2>&1 &

$APPTAINER_CMD python3 ./testprompt_lustre.py
duration=$(( SECONDS - start ))
echo "duration: $duration"

