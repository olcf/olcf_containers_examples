#!/bin/bash
#SBATCH -q debug
#SBATCH -A stf007
#SBATCH -N 4
#SBATCH -t 01:00:00
#SBATCH -o logs/vllmmult_%j.out
#SBATCH -C nvme

export HF_HOME=/mnt/bb/$USER # Make sure nvme is in use with . Change this location if you want.

MODEL_NAME="$1"
SELECTED_MODEL="gemma-4-31B-it"

if [ "$#" -ne 1 ]; then
	echo "No model provided. Defaulting to gemma."
	MODEL_NAME="gemma"
elif echo "$MODEL_NAME" | grep -iqE "gpt"; then
    echo "Detected GPT keyword. Using 'gpt-oss-120b'."
    SELECTED_MODEL="gpt-oss-120b"
elif echo "$MODEL_NAME" | grep -iqE "gemma"; then
	echo "Detected Gemma keyword. Using 'gemma-4-31B-it'."
fi

if [ ! -d "$SELECTED_MODEL" ]; then
	echo "Model not downloaded. Please download it and try again."
	exit 1
fi

sbcast_start=$SECONDS
sbcast ./$SELECTED_MODEL.tar.gz /mnt/bb/$USER/$SELECTED_MODEL.tar.gz
if [ ! "$?" == "0" ]; then
    # CHECK EXIT CODE. When SBCAST fails, it may leave partial files on the compute nodes, and if you continue to launch srun,
    # your application may pick up partially complete shared library files, which would give you confusing errors.
    echo "SBCAST failed!"
    exit 1
fi
echo "show ls"
ls /mnt/bb/$USER
srun -N4 --tasks-per-node=1 --cpus-per-task=56  tar --use-compress-program="pigz -p 56" -xf /mnt/bb/$USER/$SELECTED_MODEL.tar.gz -C /mnt/bb/$USER

# if we're using gpt, we should sbcast the vocab file too
if echo "$SELECTED_MODEL" | grep -iqE "gpt"; then
    echo "SBCASTing vocab_cache"
    sbcast ./vocab_cache.tar.gz /mnt/bb/$USER/vocab_cache.tar.gz
    # we won't check this because we can fallback later
    if [ -f /mnt/bb/$USER/vocab_cache.tar.gz ]; then
        srun -N4 --tasks-per-node=1 --cpus-per-task=56  tar --use-compress-program="pigz -p 56" -xf /mnt/bb/$USER/vocab_cache.tar.gz -C /mnt/bb/$USER
        export TIKTOKEN_RS_CACHE_DIR=/mnt/bb/$USER/vocab_cache
    else
        echo "SBCASTing vocab_cache failed! Defaulting to Lustre"
        export TIKTOKEN_RS_CACHE_DIR=./vocab_cache
    fi
fi

echo "show ls"
ls /mnt/bb/$USER
sbcast_duration=$(( SECONDS - sbcast_start ))
echo "sbcast_duration: $sbcast_duration"

start=$SECONDS
export HEAD_NODE_ADDR=$(hostname)
echo "HEAD_NODE_ADDR: $HEAD_NODE_ADDR"

export APPTAINERENV_TRITON_CACHE_DIR="/tmp/triton/cache/"  # change write/build location for hip_utils in Triton
APPTAINER_CMD="apptainer exec --fakeroot --writable-tmpfs ./vllm_rocm.sif "
export APPTAINER_BINDPATH=/mnt/bb

# starting head node (head node start also starts a worker)
srun -N1 -n1 -c56 -G8 -w $HEAD_NODE_ADDR $APPTAINER_CMD ./start_head_bb.sh $SLURM_NNODES $SELECTED_MODEL > logs/headnodelog_$SLURM_JOB_ID 2>&1 &

# starting workers on other nodes 
srun -N3 -n3  --tasks-per-node=1 --cpus-per-task=56 --gpus-per-task=8 -x $HEAD_NODE_ADDR $APPTAINER_CMD ./start_worker.sh $HEAD_NODE_ADDR > logs/workernodeslog_$SLURM_JOB_ID 2>&1 &

$APPTAINER_CMD python3 ./testprompt_lustre.py   # the rewritten script should accommodate any setup
duration=$(( SECONDS - start ))
echo "duration: $duration"

