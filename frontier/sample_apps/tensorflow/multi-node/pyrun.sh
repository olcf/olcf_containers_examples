#!/bin/bash

#source  /sw/frontier/python/3.10/miniforge3/23.11.0/bin/activate  #/opt/miniforge/bin/activate 
#python -c 'import tensorflow' 2> /dev/null && echo ‘Success’ || echo ‘Failure’

python -W ignore -u ./main.py #mnist_setup.py #multinode_olcf.py 2000 10 --master_addr=$MASTER_ADDR --master_port=3442

