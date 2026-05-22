#!/bin/bash

NNODES=$1
RUN_MODEL="$2"
export HIP_VISIBLE_DEVICES=$SLURM_STEP_GPUS
export VLLM_HOST_IP=$(hostname -I | awk '{print $2}')

echo "VLLM_HOST_IP: $VLLM_HOST_IP"
ray start --node-ip-address=$VLLM_HOST_IP --head --port=6379

sleep 10
echo "head node: slurm nnodes - $NNODES"

ray status

vllm serve --chat-template "./chattemplate.jinja" --tensor-parallel-size 8 --pipeline-parallel-size $NNODES --distributed-executor-backend ray "./$RUN_MODEL" --host 0.0.0.0 --port 8000 --gpu-memory-utilization 0.75