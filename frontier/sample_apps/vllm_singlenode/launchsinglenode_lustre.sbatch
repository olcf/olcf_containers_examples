#!/bin/bash
#SBATCH -A stf007
#SBATCH -N 1
#SBATCH -p batch
#SBATCH -q debug
#SBATCH -t 00:30:00
#SBATCH -o logs/vllmsingle_%j.out
#SBATCH -C nvme


export HF_HOME=/mnt/bb/$USER # Make sure nvme is in use with #SBATCH -C nvme. Change this location if you want.

export VLLM_LOGGING_LEVEL=DEBUG
export all_proxy=socks://proxy.ccs.ornl.gov:3128/
export ftp_proxy=ftp://proxy.ccs.ornl.gov:3128/
export http_proxy=http://proxy.ccs.ornl.gov:3128/
export https_proxy=http://proxy.ccs.ornl.gov:3128/
export no_proxy='localhost,127.0.0.0/8,*.ccs.ornl.gov'


start=$SECONDS

export APPTAINERENV_TRITON_CACHE_DIR="/tmp/triton/cache/"  # change write/build location for hip_utils in Triton
#APPTAINER_CMD="apptainer exec --fakeroot --writable-tmpfs ./vllm0102rocm71.sif "
#APPTAINER_CMD="apptainer exec --fakeroot --writable-tmpfs ./vllmci.sif"
APPTAINER_CMD="apptainer exec --fakeroot --writable-tmpfs vllm0141rocm72.sif "
#APPTAINER_CMD="apptainer exec --fakeroot --writable-tmpfs ./vllmmainrocm71.sif "
#APPTAINER_CMD="apptainer exec --fakeroot --writable-tmpfs ./vllm_rocm6.4.1_vllm_0.10.1_20250909.sif"
export APPTAINER_BINDPATH=/mnt/bb

# Needed to bypass MIOpen, Disk I/O Errors
export MIOPEN_USER_DB_PATH="/tmp/my-miopen-cache"
export MIOPEN_CUSTOM_CACHE_DIR=${MIOPEN_USER_DB_PATH}
rm -rf ${MIOPEN_USER_DB_PATH}
mkdir -p ${MIOPEN_USER_DB_PATH}

# starting head node (head node start also starts a worker)
export HIP_VISIBLE_DEVICES=0,1,2,3,4,5,6,7

# For OLMo models: necessary to prevent HIP error: operation not permitted when stream is capturing 
#export TORCH_NCCL_BLOCKING_WAIT=true
#MODEL="$PWD/Olmo-3.1-32B-Instruct"

#MODEL="$PWD/Llama-4-Scout-17B-16E-Instruct"

MODEL="$PWD/gpt-oss-20b"

srun -N1 -n1 -c56 -G8  $APPTAINER_CMD vllm serve --tensor-parallel-size 8 $MODEL --host 0.0.0.0 --port 8000 &


unset all_proxy
unset ftp_proxy
unset http_proxy
unset https_proxy
unset no_proxy
$APPTAINER_CMD python3 ./testprompt_lustre.py > logs/inference_output_$SLURM_JOBID.out
duration=$(( SECONDS - start ))
echo "duration: $duration"
