#!/bin/bash

export VLLM_HOST_IP=$(hostname -I | awk '{print $2}')
echo "VLLM_HOST_IP: $VLLM_HOST_IP"
HEAD_NODE_ADDR=$@
ray start --address=$HEAD_NODE_ADDR:6379 --block
