#!/bin/bash

#source /opt/miniforge/bin/activate 
#python3 -W ignore -u ./multinode_olcf.py 2000 10 --master_addr=$MASTER_ADDR --master_port=3442
#python3 -W ignore -u ./multinode_olcf_mnist.py 200 10 --master_addr=$MASTER_ADDR --master_port=3442
python3 -W ignore -u ./multinode_olcf_mnist_princeton.py --master_addr=$MASTER_ADDR --master_port=3442

