#!/bin/bash

NNODES=$@
export VLLM_HOST_IP=$(hostname -I | awk '{print $2}')
echo "VLLM_HOST_IP: $VLLM_HOST_IP"
ray start --node-ip-address=$VLLM_HOST_IP --head --port=6379 

sleep 10
echo "head node: slurm nnodes - $NNODES"

ray status

vllm serve --chat-template "./chattemplate.jinja" --tensor-parallel-size 8 --pipeline-parallel-size $NNODES --distributed-executor-backend ray "./astrollama-2-7b-base_abstract" --host 0.0.0.0 --port 8000 
