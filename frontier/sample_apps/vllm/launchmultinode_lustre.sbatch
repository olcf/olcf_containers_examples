#!/bin/bash
#SBATCH -A stf007
#SBATCH -N 4
#SBATCH -t 02:00:00
#SBATCH -o logs/vllmmult_%j.out
#SBATCH -C nvme

module load olcf-container-examples

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

if [ ! -d "$OLCF_CONTAINER_EXAMPLES_DIR/$SELECTED_MODEL" ]; then
	echo "Model not downloaded. Please download it and try again."
	exit 1
fi

export HF_HOME=/mnt/bb/$USER # Make sure nvme is in use with . Change this location if you want.


start=$SECONDS
export HEAD_NODE_ADDR=$(hostname)
echo "HEAD_NODE_ADDR: $HEAD_NODE_ADDR"

export APPTAINERENV_TRITON_CACHE_DIR="/tmp/triton/cache/"  # change write/build location for hip_utils in Triton
APPTAINER_CMD="apptainer exec --fakeroot --writable-tmpfs ./vllm_rocm.sif "
export APPTAINER_BINDPATH=/mnt/bb

# Needed for gpt-oss-120b
export TIKTOKEN_RS_CACHE_DIR=./vocab_cache

# starting head node (head node start also starts a worker)
srun -N1 -n1 -c48 -G8 -w $HEAD_NODE_ADDR $APPTAINER_CMD $OLCF_CONTAINER_EXAMPLES_DIR/start_head_lustre.sh $SLURM_NNODES $SELECTED_MODEL > logs/headnodelog_$SLURM_JOB_ID 2>&1 &

# starting workers on other nodes 
srun -N3 -n3  --tasks-per-node=1 --cpus-per-task=56 --gpus-per-task=8 -x $HEAD_NODE_ADDR $APPTAINER_CMD $OLCF_CONTAINER_EXAMPLES_DIR/start_worker.sh $HEAD_NODE_ADDR > logs/workernodeslog_$SLURM_JOB_ID 2>&1 &

srun -N1 -n1 -c8 $APPTAINER_CMD python3 $OLCF_CONTAINER_EXAMPLES_DIR/testprompt_lustre.py
duration=$(( SECONDS - start ))
echo "duration: $duration"
