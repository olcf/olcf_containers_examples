#!/bin/bash
#python3 -W ignore -u ./multinode_olcf_mnist_princeton_nompi4py.py --master_addr=$MASTER_ADDR --master_port=3442
python3 -W ignore -u ./microbench_olcf.py --master_addr=$MASTER_ADDR --master_port=3442
