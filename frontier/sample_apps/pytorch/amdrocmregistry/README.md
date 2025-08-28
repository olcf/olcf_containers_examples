# Pytorch MNIST example using DistributedDataParallel

Pytorch example borrowed from: [PrincetonUniversity/multi_gpu_training](https://github.com/PrincetonUniversity/multi_gpu_training/tree/main)

AMD maintains several ML and AI containers on DockerHub at https://hub.docker.com/u/rocm . Here we
show how to run a Pytorch example using their Pytorch container.


To pull the pytorch container from the official ROCm container registry
```
apptainer build pytorch_rocm642.sif docker://docker.io/rocm/pytorch:rocm6.4.2_ubuntu24.04_py3.12_pytorch_release_2.6.0
```

Download the MNIST dataset first before submitting the job:
```
./downloadmnist.sh
```

Submit the job with: 
```
sbatch submit.sbatch
```

NOTE: This image is built by AMD and does not include MPI or matches any of the software provided by the
Cray Programming Environment. OLCF has no control of what is included in the images, updates to the
images etc.
