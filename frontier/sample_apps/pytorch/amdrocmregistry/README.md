# Pytorch MNIST example using DistributedDataParallel

Pytorch examples borrowed from: [PrincetonUniversity/multi_gpu_training](https://github.com/PrincetonUniversity/multi_gpu_training/tree/main)
and from the OLCF docs.

To switch between running the two available examples `./multinode_olcf_mnist_princeton_nompi4py.py`
and `./microbench_olcf.py`, uncomment the appropriate line in the `pyrun.sh`.

AMD maintains several ML and AI containers on DockerHub at https://hub.docker.com/u/rocm . Here we
show how to run a Pytorch example using their Pytorch container.


To pull the pytorch container from the official ROCm container registry
```
apptainer build pytorch_rocm642.sif docker://docker.io/rocm/pytorch:rocm6.4.2_ubuntu24.04_py3.12_pytorch_release_2.6.0
```

Download the MNIST dataset first before submitting the job (not required if you are running
`./microbench_olcf.py`):
```
./downloadmnist.sh
```

Submit the job with: 
```
sbatch submit.sbatch
```

For better performance, you can build the [aws-ofi-nccl](https://github.com/aws/aws-ofi-nccl) library by running the
`./awsofincclbuild.sh` script. There is an environment variable `APPTAINERENV_LD_LIBRARY_PATH` in
the `submit.sbatch` that is set so that RCCL will be able to find and load the library during the Pytorch run.

NOTE: This image is built by AMD and does not include MPI or matches any of the software provided by the
Cray Programming Environment. OLCF has no control of what is included in the images, updates to the
images etc.
