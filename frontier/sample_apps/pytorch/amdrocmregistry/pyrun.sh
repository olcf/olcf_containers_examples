#!/bin/bash
if [[ -f /opt/miniforge/bin/activate ]]; then
    source /opt/miniforge/bin/activate
fi
python3 -W ignore -u ./multinode_olcf_mnist_princeton_nompi4py.py --master_addr=$MASTER_ADDR --master_port=3442
