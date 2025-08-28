#!/bin/bash

apptainer exec --workdir `pwd` --rocm pytorch_rocm642.sif python3 -c "from torchvision import datasets; dataset1 = datasets.MNIST('./data', download=True)"
